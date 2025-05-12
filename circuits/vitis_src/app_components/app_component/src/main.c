#include "xgpio.h"
#include "xparameters.h"
#include "sleep.h"  // pour usleep

#define GPIO_DEVICE_ID 0
#define DELAY_US 10000  // 10 ms entre chaque changement (~100 FPS)

int main() {
    XGpio gpio;
    int status;

    // Initialisation du GPIO
    status = XGpio_Initialize(&gpio, GPIO_DEVICE_ID);
    if (status != XST_SUCCESS) {
        return XST_FAILURE;
    }

    // GPIO direction : canal 1 en sortie (12 bits)
    XGpio_SetDataDirection(&gpio, 1, 0x000);

    // Animation : variation douce des couleurs en BGR (Blue-Green-Red)
    u8 r = 0, g = 0, b = 0;
    int phase = 0;

    while (1) {
        // Construction du pixel 12 bits : [11:8]=B, [7:4]=G, [3:0]=R
        u16 pixel = ((b & 0xF) << 8) | ((g & 0xF) << 4) | (r & 0xF);
        XGpio_DiscreteWrite(&gpio, 1, pixel);

        // Animation simple en 3 phases
        switch (phase) {
            case 0: r++; if (r >= 15) phase++; break;
            case 1: g++; if (g >= 15) phase++; break;
            case 2: b++; if (b >= 15) phase = 0; break;
        }

        usleep(DELAY_US);
    }

    return 0;
}
