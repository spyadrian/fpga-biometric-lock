#include <stdint.h>
#include "xparameters.h"

#define FRAMEBUFFER_BASEADDR XPAR_XBRAM_0_BASEADDR
#define WIDTH 640

#define BGR(r, g, b) (((b & 0xF) << 8) | ((g & 0xF) << 4) | (r & 0xF))

void draw_pixel(int x, int y, uint16_t color) {
    uintptr_t addr = FRAMEBUFFER_BASEADDR + ((y * WIDTH + x) * 4);
    *((volatile uint32_t*)addr) = (uint32_t)color;
}

int main() {
    draw_pixel(0, 0, BGR(0xF, 0xF, 0xF));          // coin haut gauche
    draw_pixel(639, 0, BGR(0xF, 0xF, 0xF));        // coin haut droit
    draw_pixel(0, 479, BGR(0xF, 0xF, 0xF));        // coin bas gauche
    draw_pixel(639, 479, BGR(0xF, 0xF, 0xF));      // coin bas droit

    while (1);
    return 0;
}
