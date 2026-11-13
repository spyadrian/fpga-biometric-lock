#include <xgpio.h>
#include "xparameters.h"
#include "xtmrctr.h"
#include "xintc.h"
#include "xiic.h"
#include "xil_exception.h"


// --- DEFINES ---
#define LED_CHANNEL            1
#define INT_GPIO_CHANNEL       1
#define VCNL4040_ADDR          0x60
#define IIC_DEVICE_ID          0
#define INT_IRQ_ID             XPAR_FABRIC_XGPIO_1_INTR
#define MS_TO_CYCLES(ms)       (0xFFFFFFFF - ((XPAR_XTMRCTR_0_CLOCK_FREQUENCY / 1000) * (ms)) + 1)


// --- GLOBALS ---
static XGpio gpio;             // LED GPIO
static XTmrCtr timer;
static XIntc intc;
static XGpio int_gpio;         // GPIO pour interruption VCNL4040
static XIic iic;

volatile u8 led_value = 0x00;
volatile u8 interrupt_triggered = 1;
volatile u8 interrupt_count = 0;
volatile u8 interrupt_count_flag = 0;

extern XGpio_Config XGpio_ConfigTable[];


// --- FUNCTIONS ---

// -- Utils --
void i2c_check_and_recover(XIic *iic_ptr) {
    u32 status = XIic_ReadReg(iic_ptr->BaseAddress, XIIC_SR_REG_OFFSET);
    u32 ctrl = XIic_ReadReg(iic_ptr->BaseAddress, XIIC_CR_REG_OFFSET);

    if ((status & XIIC_SR_BUS_BUSY_MASK) ||
        !(ctrl & XIIC_CR_MSMS_MASK) ||              // pas en master
        (ctrl & XIIC_CR_REPEATED_START_MASK) ||     // stuck en RSTA
        (status & XIIC_SR_RX_FIFO_FULL_MASK)) {     // FIFO pleine

        xil_printf("I2C reset (status=0x%08X, ctrl=0x%08X)\n", status, ctrl);
        XIic_Stop(iic_ptr);
        XIic_Reset(iic_ptr);
        XIic_Start(iic_ptr);
        XIic_SetAddress(iic_ptr, XII_ADDR_TO_SEND_TYPE, VCNL4040_ADDR);
    }
}

int vcnl4040_write_reg(u8 reg, u16 data) {
    u8 buf[3];
    buf[0] = reg;
    buf[1] = data & 0xFF;         // LSB
    buf[2] = (data >> 8) & 0xFF;  // MSB
    return XIic_Send(XPAR_XIIC_0_BASEADDR, VCNL4040_ADDR, buf, 3, XIIC_STOP);
}

int vcnl4040_read_reg(u8 reg, u16 *data) {
    u8 buf[2];

    i2c_check_and_recover(&iic);

    if (XIic_Send(XPAR_XIIC_0_BASEADDR, VCNL4040_ADDR, &reg, 1, XIIC_REPEATED_START) != 1)
        return XST_FAILURE;

    if (XIic_Recv(XPAR_XIIC_0_BASEADDR, VCNL4040_ADDR, buf, 2, XIIC_STOP) != 2)
        return XST_FAILURE;

    *data = ((u16)buf[1] << 8) | buf[0];
    return XST_SUCCESS;
}

// -- Handlers --
void timer_handler(void *CallBackRef, u8 TmrCtrNumber) {
    
    if (interrupt_count_flag == 1) {
        interrupt_count += 1;

        if (interrupt_count == 6) {
            interrupt_count = 0;
            interrupt_count_flag = 0;  
        }
    }

    led_value ^= 0x80;
    XGpio_DiscreteWrite(&gpio, LED_CHANNEL, led_value | interrupt_count_flag);
}

void int_handler(void *InstancePtr) {
    
    interrupt_count = 0;
    interrupt_count_flag = 1;
    
    interrupt_triggered = 1;

    (void)XGpio_InterruptClear(&int_gpio, INT_GPIO_CHANNEL); // Nettoyage de l’interruption
}


// --- MAIN ---
int main() {
    int status;

    // -- Initialisation GPIO LED --
    status = XGpio_Initialize(&gpio, 0);
    if (status != XST_SUCCESS) return XST_FAILURE;
    XGpio_SetDataDirection(&gpio, LED_CHANNEL, 0x00);

    // -- Initialisation Timer --
    status = XTmrCtr_Initialize(&timer, 0);
    if (status != XST_SUCCESS) return XST_FAILURE;
    XTmrCtr_SetOptions(&timer, 0, XTC_INT_MODE_OPTION | XTC_AUTO_RELOAD_OPTION);
    XTmrCtr_SetResetValue(&timer, 0, MS_TO_CYCLES(500));
    XTmrCtr_SetHandler(&timer, timer_handler, &timer);

    // -- Initialisation I2C --
    status = XIic_Initialize(&iic, IIC_DEVICE_ID);
    if (status != XST_SUCCESS) return XST_FAILURE;
    XIic_Start(&iic);
    XIic_SetAddress(&iic, XII_ADDR_TO_SEND_TYPE, VCNL4040_ADDR);

    // -- Configuration VCNL4040 --
    vcnl4040_write_reg(0x03, 0x0100); // PS_CONF1
    vcnl4040_write_reg(0x04, 0x0380); // PS_CONF3 + PS_MS
    vcnl4040_write_reg(0x06, 0x0010); // THDL = 16
    vcnl4040_write_reg(0x07, 0x0080); // THDH = 128

    // -- Initialisation Contrôleur d'interruptions --
    status = XIntc_Initialize(&intc, 0);
    if (status != XST_SUCCESS) return XST_FAILURE;

    status = XIntc_Connect(&intc, XPAR_FABRIC_XTMRCTR_0_INTR,
                           (Xil_ExceptionHandler)XTmrCtr_InterruptHandler,
                           (void *)&timer);
    if (status != XST_SUCCESS) return XST_FAILURE;

    // -- Configuration GPIO interruption (VCNL4040) --
    XGpio_CfgInitialize(&int_gpio, &XGpio_ConfigTable[1], XGpio_ConfigTable[1].BaseAddress);
    XGpio_SetDataDirection(&int_gpio, INT_GPIO_CHANNEL, 0xFF);
    XGpio_InterruptEnable(&int_gpio, 1);
    XGpio_InterruptGlobalEnable(&int_gpio);

    status = XIntc_Connect(&intc, INT_IRQ_ID,
                           (Xil_ExceptionHandler)int_handler,
                           (void *)&int_gpio);
    if (status != XST_SUCCESS) return XST_FAILURE;

    // -- Activation exceptions globales --
    Xil_ExceptionInit();
    Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
                                 (Xil_ExceptionHandler)XIntc_InterruptHandler,
                                 &intc);
    Xil_ExceptionEnable();

    // -- Lancement des interruptions --
    XIntc_Enable(&intc, INT_IRQ_ID);
    XIntc_Start(&intc, XIN_REAL_MODE);
    XIntc_Enable(&intc, XPAR_FABRIC_XTMRCTR_0_INTR);

    // -- Démarrage du timer --
    XTmrCtr_Start(&timer, 0);

    // -- Boucle principale --
    while (1) {

        if (interrupt_triggered) {
            interrupt_triggered = 0;
            u16 flag;
            vcnl4040_read_reg(0x0B, &flag);
        }

        u16 prox;
        vcnl4040_read_reg(0x08, &prox);
    }
}
