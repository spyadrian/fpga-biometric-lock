#include "xparameters.h"
#include <stdint.h>

#define VGA_WIDTH 640
#define VGA_HEIGHT 480
#define FRAMEBUFFER_BASEADDR XPAR_AXI_BRAM_CTRL_0_BASEADDR

// Couleurs en BGR444
#define RED 0x00F
#define GREEN 0x0F0
#define BLUE 0xF00
#define WHITE 0xFFF
#define BLACK 0x000
#define YELLOW 0x0FF
#define CYAN 0xFF0
#define MAGENTA 0xF0F

int main() {
  volatile uint16_t *framebuffer = (uint16_t *)FRAMEBUFFER_BASEADDR;

  for (int y = 0; y < VGA_HEIGHT; ++y) {
    for (int x = 0; x < VGA_WIDTH; ++x) {
      framebuffer[y * VGA_WIDTH + x - 1] = 0x000;
    }
  }

  uint16_t color = WHITE;
for (int y = 0; y < 480; y++) {
    framebuffer[y * 640 + 0] = 0xFFF;  // colonne x=0
    framebuffer[y * 640 + 1] = 0xFFF;  // colonne x=1
    framebuffer[y * 640 + 2] = 0xFFF;  // colonne x=1
    framebuffer[y * 640 + 3] = 0xFFF;  // colonne x=1
    framebuffer[y * 640 + 4] = 0xFFF;  // colonne x=1
    framebuffer[y * 640 + 5] = 0xFFF;  // colonne x=1
}


  //   for (int y = 0 + 100; y < VGA_HEIGHT - 100; ++y) {
  //     uint16_t color;
  //     // Alterne tous les 16 pixels verticaux
  //     if ((y / 16) % 2 == 0)
  //       color = RED;
  //     else
  //       color = BLUE;

  //     for (int x = 0 + 100; x < VGA_WIDTH- 100; ++x) {
  //       int index = y * VGA_WIDTH + x+3;
  //       framebuffer[index] = color;
  //     }
  //   }

  while (1)
    ; // Boucle infinie pour maintenir l'affichage
  return 0;
}
