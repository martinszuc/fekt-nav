/* 
 * Autor: Martin Szuc, VUTID:231284
 * Datum: 16.04.2025
 * Testovaci program pre MMX funkcie v C
 * Kompilacia: gcc test.c -o test.exe -L. -ldetect
 */

#include <stdio.h>
#include <stdint.h>
#include "blend.h"

typedef unsigned int uint;

int main() {
    // Test, ci procesor podporuje MMX
    int mmx_supported = MMXsupport();
    
    if (mmx_supported) {
        printf("MMX je podporovane!\n");
        
        // Test blendovania dvoch pixelov
        uint pixel_a = 0xFF0000FF;  // ARGB: 255, 0, 0, 255 (modra)
        uint pixel_b = 0xFFFF0000;  // ARGB: 255, 255, 0, 0 (cervena)
        uint blend_factor = 0x80808080;  // 128 pre vsetky zlozky (50% blend)
        uint result_pixel = 0;
        
        // Volanie blend funkcie
        blend(&pixel_a, &result_pixel, &blend_factor);
        
        // Zobrazenie vysledku
        printf("Pixel A (modry):      0x%08X\n", pixel_a);
        printf("Pixel B (cerveny):    0x%08X\n", pixel_b);
        printf("Faktor prolnutia:     0x%08X\n", blend_factor);
        printf("Vysledny pixel:       0x%08X\n", result_pixel);
    } else {
        printf("MMX nie je podporovane!\n");
    }
    
    return 0;
}