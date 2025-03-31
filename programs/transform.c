#include <stdio.h>
#include <stdint.h>

#define IMG_HEIGHT 640
#define IMG_WIDTH  480

typedef uint8_t pixel_t;
typedef uint8_t lbp_value_t;

// Image arrays
pixel_t image[IMG_HEIGHT][IMG_WIDTH];
lbp_value_t lbp_image[IMG_HEIGHT][IMG_WIDTH];

// Compute LBP value at (x, y) like your VHDL function
lbp_value_t compute_lbp_value(int x, int y) {
    pixel_t center = image[y][x];
    lbp_value_t lbp = 0;

    lbp |= (image[y - 1][x - 1] >= center) << 7;
    lbp |= (image[y - 1][x    ] >= center) << 6;
    lbp |= (image[y - 1][x + 1] >= center) << 5;
    lbp |= (image[y    ][x + 1] >= center) << 4;
    lbp |= (image[y + 1][x + 1] >= center) << 3;
    lbp |= (image[y + 1][x    ] >= center) << 2;
    lbp |= (image[y + 1][x - 1] >= center) << 1;
    lbp |= (image[y    ][x - 1] >= center) << 0;

    return lbp;
}

void run_lbp_transform() {
    for (int y = 1; y < IMG_HEIGHT - 1; ++y) {
        for (int x = 1; x < IMG_WIDTH - 1; ++x) {
            lbp_image[y][x] = compute_lbp_value(x, y);
        }
    }
}

void initialize_image() {
    // Example pattern similar to your VHDL TB
    for (int y = 0; y < IMG_HEIGHT; ++y) {
        for (int x = 0; x < IMG_WIDTH; ++x) {
            if (x == IMG_WIDTH / 2 && y == IMG_HEIGHT / 2)
                image[y][x] = 128; // center pixel
            else
                image[y][x] = 64; // surrounding pixels
        }
    }
}

void print_lbp_center_region() {
    printf("LBP output (center 3x3 region):\n");
    int cy = IMG_HEIGHT / 2;
    int cx = IMG_WIDTH / 2;
    for (int y = cy - 1; y <= cy + 1; ++y) {
        for (int x = cx - 1; x <= cx + 1; ++x) {
            printf("LBP(%d,%d) = 0x%02X\n", y, x, lbp_image[y][x]);
        }
    }
}

int main() {
    initialize_image();
    run_lbp_transform();
    print_lbp_center_region();
    return 0;
}
