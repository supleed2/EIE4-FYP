#include <generated/csr.h>
#include <stdio.h>

#ifdef CSR_LEDS_BASE
void led(void) {
	int i;
	int j;
	int k;
	printf("Led demo...\n");

	printf("Counter mode...\n");
	for (i = 0; i < 4; i++) {
		for (j = 0; j < 4; j++) {
			for (k = 0; k < 4; k++) {
				leds_out_write(0x3F0000 * i + 0x003F00 * j + 0x00003F * k);
				busy_wait(100);
			}
		}
	}

	printf("Shift mode...\n");
	for (i = 0; i < 24; i++) {
		leds_out_write(1 << i);
		busy_wait(100);
	}
	for (i = 0; i < 24; i++) {
		leds_out_write(1 << (23 - i));
		busy_wait(100);
	}

	printf("Dance mode...\n");
	for (i = 0; i < 16; i++) {
		leds_out_write(0x000055);
		busy_wait(200);
		leds_out_write(0xAAAA00);
		busy_wait(200);
	}

	printf("Clearing led...\n");
	leds_out_write(0);
}
#endif
