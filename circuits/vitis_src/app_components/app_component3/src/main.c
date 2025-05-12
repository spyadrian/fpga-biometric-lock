#include "xparameters.h"
#include <stdint.h>

#define FRAMEBUFFER_BASE_ADDR XPAR_AXI_BRAM_CTRL_0_BASEADDR
#define SCREEN_WIDTH  640
#define SCREEN_HEIGHT 480

// Couleurs en BGR 4-4-4
#define COLOR_RED    0xF00
#define COLOR_GREEN  0x0F0
#define COLOR_BLUE   0x00F
#define COLOR_WHITE  0xFFF
#define COLOR_BLACK  0x000

int main() {
    volatile uint16_t* framebuffer = (uint16_t*) FRAMEBUFFER_BASE_ADDR;

    // Efface l'écran (fond noir)
    for (int i = 0; i < SCREEN_WIDTH * SCREEN_HEIGHT; i++) {
        framebuffer[i] = COLOR_BLACK;
    }

    // Affiche une bande colorée tous les 40 pixels (10 lignes par bande)
    for (int band = 0; band < SCREEN_HEIGHT / 40; band++) {
        uint16_t color;
        switch (band % 4) {
            case 0: color = COLOR_RED; break;
            case 1: color = COLOR_GREEN; break;
            case 2: color = COLOR_BLUE; break;
            case 3: color = COLOR_WHITE; break;
        }

        int y_start = band * 40;
        for (int y = y_start; y < y_start + 10; y++) {
            for (int x = 0; x < SCREEN_WIDTH; x++) {
                framebuffer[y * SCREEN_WIDTH + x] = color;
            }
        }
    }

    while (1); // Laisser l'affichage
}
