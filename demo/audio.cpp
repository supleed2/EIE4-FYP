#include <generated/csr.h>
#include <stdio.h>

extern "C" void audio(int);
void audio(int v) {
	audio_targ_write(v);
}