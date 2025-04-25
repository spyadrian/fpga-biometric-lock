#include <stdint.h>
#include <stdio.h>

#define IMG_WIDTH 480
#define IMG_HEIGHT 640
#define NUM_PIXELS (IMG_WIDTH * IMG_HEIGHT)

#define PXL_SIZE 8
#define LBP_BINS 256

#define GRID_LEN_X 8
#define GRID_LEN_Y 8
#define GRID_WIDTH (IMG_WIDTH / GRID_LEN_X)
#define GRID_HEIGHT (IMG_HEIGHT / GRID_LEN_Y)

typedef uint8_t pixel_t;
typedef uint16_t bin_t;      // 13-bit bins
typedef uint64_t distance_t; // 40-bit result

typedef bin_t hist_t[LBP_BINS];
typedef hist_t concat_hist_t[GRID_LEN_Y][GRID_LEN_X];

pixel_t image[NUM_PIXELS];
concat_hist_t ref_hist;
concat_hist_t img_hist;

void init_flat_image() {
  for (int i = 0; i < NUM_PIXELS; i++) {
    image[i] = 128; // Flat mid-gray
  }
}

void init_ref_hist() {
  for (int y = 0; y < GRID_LEN_Y; y++) {
    for (int x = 0; x < GRID_LEN_X; x++) {
      for (int i = 0; i < LBP_BINS; i++) {
        ref_hist[y][x][i] = i;
      }
    }
  }
}

void compute_image_histogram() {
  // Zero histograms
  for (int y = 0; y < GRID_LEN_Y; y++) {
    for (int x = 0; x < GRID_LEN_X; x++) {
      for (int i = 0; i < LBP_BINS; i++) {
        img_hist[y][x][i] = 0;
      }
    }
  }

  // Fill histograms (assuming each pixel maps to a single bin based on value)
  for (int row = 1; row < IMG_HEIGHT - 1; row++) {
    for (int col = 1; col < IMG_WIDTH - 1; col++) {
      int idx = row * IMG_WIDTH + col;
      pixel_t px = image[idx];
      int gx = col / GRID_WIDTH;
      int gy = row / GRID_HEIGHT;
      img_hist[gy][gx][px]++;
    }
  }

  for (int y = 0; y < GRID_LEN_Y; y++) {
    for (int x = 0; x < GRID_LEN_Y; x++) {

      printf("img_hist(%d)(%d)(128) : %d\n", x, y, img_hist[x][y][128]);
    }
  }
}

distance_t squared_diff(bin_t a, bin_t b) {
  int32_t diff = (int32_t)a - (int32_t)b;
  distance_t d = (distance_t)(diff * diff);
  return d;
}

distance_t compute_distance() {
  distance_t total = 0;

  for (int y = 0; y < GRID_LEN_Y; y++) {
    for (int x = 0; x < GRID_LEN_X; x++) {

      distance_t tmp = 0;
      for (int i = 0; i < LBP_BINS; i++) {
        tmp += squared_diff(img_hist[y][x][i], ref_hist[y][x][i]);
      }

      printf("sum at (%d, %d) : %lu\n", x, y, tmp);
      total += tmp;
    }
  }

  return total;
}

int main() {
  init_flat_image();
  init_ref_hist();
  compute_image_histogram();

  // img_hist[7][7][128] = 4660;
  distance_t result = compute_distance();
  for (int i = 0; i < 255; i++) {

    printf("hist_img(7,7)(%d) : %d\n", i, img_hist[7][7][i]);
  }
  printf("Result: %llu\n", (unsigned long long)result);
  return 0;
}
