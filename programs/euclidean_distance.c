#include <stdio.h>
#include <stdint.h>

#define LBP_BINS 256

typedef uint16_t hist_bin_t;
typedef uint32_t distance_t;

int main() {

    hist_bin_t hist1[LBP_BINS];
    hist_bin_t hist2[LBP_BINS];
    distance_t diff_squared[LBP_BINS];
    uint64_t sum = 0;

    // Fill histograms same as VHDL testbench
    for (int i = 0; i < LBP_BINS; i++) {
        hist1[i] = i;             // same pattern as VHDL testbench
        hist2[i] = 255 - i;
    }

    // Compute squared differences and sum
    for (int i = 0; i < LBP_BINS; i++) {
        int32_t diff = (int32_t)hist1[i] - (int32_t)hist2[i];
        diff_squared[i] = (distance_t)(diff * diff);
        sum += diff_squared[i];
    }

    // Final Euclidean distance (sum of squared differences, no square root in VHDL)
    printf("Euclidean distance (sum of squared differences): %lu\n", sum);
    printf("Top 32 bits of sum (matching VHDL result_o width): 0x%08X\n", (uint32_t)(sum & 0xFFFFFFFF));

    return 0;
}
