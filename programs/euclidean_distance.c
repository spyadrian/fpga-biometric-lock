#include <stdint.h>
#include <stdio.h>

#define LBP_BINS 256
#define GRID_LEN_X 8
#define GRID_LEN_Y 8

typedef uint16_t bin_t;      // 13-bit in VHDL, so use 16-bit unsigned
typedef uint64_t distance_t; // 40-bit in VHDL, so use 64-bit unsigned

typedef bin_t hist_t[LBP_BINS];
typedef hist_t concat_hist_t[GRID_LEN_Y][GRID_LEN_X];

// Squared difference function
distance_t squared_diff(bin_t a, bin_t b) {
  int32_t diff = (int32_t)a - (int32_t)b;
  return (distance_t)(diff * diff);
}

int main() {
  concat_hist_t hist1 = {0};
  concat_hist_t hist2 = {0};

  distance_t result = 0;

  // Initialize histograms with 0..255 and 255..0
  for (int y = 0; y < GRID_LEN_Y; ++y) {
    for (int x = 0; x < GRID_LEN_X; ++x) {
      for (int i = 0; i < LBP_BINS; ++i) {
        hist1[y][x][i] = i;
        hist2[y][x][i] = 255 - i;
        result += squared_diff(hist1[y][x][i], hist2[y][x][i]);
      }
    }
  }

  printf("Euclidean distance (sum of squared differences): %lu\n", result);
  return 0;
}
