#include <generated/csr.h>
#include <stdio.h>

void leds(int v) {
	leds_out_write(v);
}