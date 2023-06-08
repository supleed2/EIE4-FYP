// This file is Copyright (c) 2020 Florent Kermarrec <florent@enjoy-digital.fr>
// License: BSD

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <generated/csr.h>
#include <irq.h>
#include <libbase/console.h>
#include <libbase/uart.h>

#include "audio"
#include "can"

/*-----------------------------------------------------------------------*/
/* Uart                                                                  */
/*-----------------------------------------------------------------------*/

static char *readstr(void) {
	char c[2];
	static char s[64];
	static unsigned int ptr = 0;

	if (readchar_nonblock()) {
		c[0] = getchar();
		c[1] = 0;
		switch (c[0]) {
			case 0x7f:
			case 0x08:
				if (ptr > 0) {
					ptr--;
					fputs("\x08 \x08", stdout);
				}
				break;
			case 0x07:
				break;
			case '\r':
			case '\n':
				s[ptr] = 0x00;
				fputs("\n", stdout);
				ptr = 0;
				return s;
			default:
				if (ptr >= (sizeof(s) - 1))
					break;
				fputs(c, stdout);
				s[ptr] = c[0];
				ptr++;
				break;
		}
	}

	return NULL;
}

static char *get_token(char **str) {
	char *c, *d;

	c = (char *)strchr(*str, ' ');
	if (c == NULL) {
		d = *str;
		*str = *str + strlen(*str);
		return d;
	}
	*c = 0;
	d = *str;
	*str = c + 1;
	return d;
}

static void prompt(void) {
	printf("\e[92;1mStackSynth\e[0m> ");
}

/*-----------------------------------------------------------------------*/
/* Help                                                                  */
/*-----------------------------------------------------------------------*/

static void help(void) {
	puts("\nLiteX custom demo app built " __DATE__
		 " " __TIME__
		 "\n");
	puts("Available commands:");
	puts("help               - Show this command");
	puts("reboot             - Reboot CPU");
	puts("donut              - Spinning Donut demo");
#ifdef CSR_LEDS_BASE
	puts("led                - Led demo");
	puts("leds               - Led set demo");
#endif
#ifdef CSR_AUDIO_BASE
	puts("saw                - Sawtooth Wave (osc, freq)");
	puts("square             - Square Wave (osc, freq)");
	puts("triangle           - Triangle Wave (osc, freq)");
	puts("sine               - Sine Wave (osc, freq)");
	puts("imperial           - Imperial March demo");
	puts("roll               - Music demo");
#endif
#ifdef CSR_DAC_VOL_BASE
	puts("volume             - Get / Set DAC Volume");
#endif
#ifdef CSR_CAN_BASE
	puts("can_id             - Get / Set CAN ID");
	puts("can_mask           - Get / Set CAN Mask");
	puts("can_read           - Receive CAN Frames and print (delay in s)");
	puts("can_watch          - Watch CAN Frames at 2Hz");
#ifdef CSR_AUDIO_BASE
	puts("can_listen         - Play CAN Frames as Audio");
#endif
#endif
}

/*-----------------------------------------------------------------------*/
/* Commands                                                              */
/*-----------------------------------------------------------------------*/

static void reboot_cmd(void) {
	ctrl_reset_write(1);
}

#ifdef CSR_LEDS_BASE
void led(void);

static void led_cmd(void) {
	led();
}

static void leds_cmd(char **val) {
	int value = (int)strtol(get_token(val), NULL, 0);
	printf("Setting LED to %6x\n", value);
	leds_out_write(value);
}
#endif
#ifdef CSR_AUDIO_BASE
static void saw_cmd(char **val) {
	uint32_t osc = static_cast<uint32_t>(strtol(get_token(val), NULL, 10));
	uint32_t freq = static_cast<uint32_t>(strtol(get_token(val), NULL, 10));
	printf("Setting Oscillator %d to Sawtooth: %dHz\n", osc, freq);
	audio(osc, WAVE_SAWTOOTH, freq);
}

static void square_cmd(char **val) {
	uint32_t osc = static_cast<uint32_t>(strtol(get_token(val), NULL, 10));
	uint32_t freq = static_cast<uint32_t>(strtol(get_token(val), NULL, 10));
	printf("Setting Oscillator %d to Square: %dHz\n", osc, freq);
	audio(osc, WAVE_SQUARE, freq);
}

static void triangle_cmd(char **val) {
	uint32_t osc = static_cast<uint32_t>(strtol(get_token(val), NULL, 10));
	uint32_t freq = static_cast<uint32_t>(strtol(get_token(val), NULL, 10));
	printf("Setting Oscillator %d to Triangle: %dHz\n", osc, freq);
	audio(osc, WAVE_TRIANGLE, freq);
}

static void sine_cmd(char **val) {
	uint32_t osc = static_cast<uint32_t>(strtol(get_token(val), NULL, 10));
	uint32_t freq = static_cast<uint32_t>(strtol(get_token(val), NULL, 10));
	printf("Setting Oscillator %d to Sine: %dHz\n", osc, freq);
	audio(osc, WAVE_SINE, freq);
}

static void imperial_cmd() {
	timed_freq(0, G4, 400);
	timed_freq(0, NONE, 400);
	timed_freq(0, G4, 400);
	timed_freq(0, NONE, 400);
	timed_freq(0, G4, 600);
	timed_freq(0, NONE, 600);
	timed_freq(0, D4S, 200);
	timed_freq(0, A4S, 200);
	timed_freq(0, G4, 600);
	timed_freq(0, NONE, 200);
	timed_freq(0, D4S, 400);
	timed_freq(0, NONE, 200);
	timed_freq(0, A4S, 200);
	timed_freq(0, G4, 1000);
	timed_freq(0, D4S, 600);
	timed_freq(0, NONE, 200);
	timed_freq(0, D5, 600);
	timed_freq(0, NONE, 200);
	timed_freq(0, D5, 600);
	timed_freq(0, NONE, 200);
	timed_freq(0, D5, 600);
	timed_freq(0, NONE, 200);
	timed_freq(0, D5S, 400);
	timed_freq(0, NONE, 200);
	timed_freq(0, A4S, 200);
	timed_freq(0, F4S, 600);
	timed_freq(0, NONE, 200);
	timed_freq(0, D4S, 400);
	timed_freq(0, NONE, 200);
	timed_freq(0, A4S, 200);
	timed_freq(0, G4, 800);
}

static void roll_cmd() {
	timed_freq(0, C4S, 450);
	timed_freq(0, D4S, 600);
	timed_freq(0, G3S, 150);
	timed_freq(0, D4S, 450);
	timed_freq(0, F4, 450);
	timed_freq(0, G4S, 90);
	timed_freq(0, F4S, 90);
	timed_freq(0, F4, 90);
	timed_freq(0, C4S, 510);
	timed_freq(0, D4S, 600);
	timed_freq(0, G3S, 1500);
	timed_freq(0, C4S, 450);
	timed_freq(0, D4S, 600);
	timed_freq(0, G3S, 150);
	timed_freq(0, D4S, 450);
	timed_freq(0, F4, 450);
	timed_freq(0, G4S, 90);
	timed_freq(0, F4S, 90);
	timed_freq(0, F4, 90);
	timed_freq(0, C4S, 510);
	timed_freq(0, D4S, 600);
	timed_freq(0, G3S, 1500);
}
#endif
#ifdef CSR_DAC_VOL_BASE
static void dac_vol_cmd(char **val) {
	char *token = get_token(val);
	if (token == *val) {
		printf("DAC volume is %d (of 128)\n", dac_vol_volume_read());
	} else {
		int value = (int)strtol(token, NULL, 0);
		printf("Setting DAC volume to %d (of 128)\n", value);
		dac_vol_volume_write(value);
	}
}
#endif

#ifdef CSR_CAN_BASE
static void can_id_cmd(char **val) {
	char *token = get_token(val);
	if (token == *val) {
		printf("Current CAN ID (filter) is 0x%03X (max 0x7FF)\n", can_id_read());
	} else {
		int value = (int)strtol(token, NULL, 0);
		printf("Setting CAN ID (filter) to 0x%03X (max 0x7FF)\n", value);
		can_id_write(value);
	}
}

static void can_mask_cmd(char **val) {
	char *token = get_token(val);
	if (token == *val) {
		printf("Current CAN mask is 0x%03X (max 0x7FF)\n", can_mask_read());
	} else {
		int value = (int)strtol(token, NULL, 0);
		printf("Setting CAN mask to 0x%03X (max 0x7FF)\n", value);
		can_mask_write(value);
	}
}

static void can_read_cmd(char **val) {
	char *token = get_token(val);
	int loop_delay;
	if (token == *val) {
		loop_delay = 10;
	} else {
		loop_delay = (int)strtol(token, NULL, 0) * 10;
	}
	while (true) {
		can_frame frame = can_read();
		printf("CAN ID: 0x%03X, data:", frame.id);
		for (int i = 0; i < 8; i++) {
			printf(" 0x%02X", frame.data[i]);
		}
		printf("\n");
		for (int i = 0; i < loop_delay; i++) {
			if (readchar_nonblock()) {
				getchar();
				return;
			}
			busy_wait(100);
		}
	}
}

static void can_watch_cmd() {
	while (true) {
		can_frame frame = can_read();
		printf("CAN ID: 0x%03X, data:", frame.id);
		for (int i = 0; i < 8; i++) {
			printf(" 0x%02X", frame.data[i]);
		}
		printf("\r");
		if (readchar_nonblock()) {
			getchar();
			printf("\n");
			return;
		}
		busy_wait(200);
	}
}

#ifdef CSR_AUDIO_BASE
const char *notes[85] = {"None", "C1", "C1#", "D1", "D1#", "E1", "F1", "F1#", "G1", "G1#", "A1", "A1#", "B1", "C2", "C2#", "D2", "D2#", "E2", "F2", "F2#", "G2", "G2#", "A2", "A2#", "B2", "C3", "C3#", "D3", "D3#", "E3", "F3", "F3#", "G3", "G3#", "A3", "A3#", "B3", "C4", "C4#", "D4", "D4#", "E4", "F4", "F4#", "G4", "G4#", "A4", "A4#", "B4", "C5", "C5#", "D5", "D5#", "E5", "F5", "F5#", "G5", "G5#", "A5", "A5#", "B5", "C6", "C6#", "D6", "D6#", "E6", "F6", "F6#", "G6", "G6#", "A6", "A6#", "B6", "C7", "C7#", "D7", "D7#", "E7", "F7", "F7#", "G7", "G7#", "A7", "A7#", "B7"};
const uint32_t freqs[85] = {0, 33, 35, 37, 39, 41, 44, 46, 49, 52, 55, 58, 62, 65, 69, 73, 78, 82, 87, 93, 98, 104, 110, 117, 123, 131, 139, 147, 156, 165, 175, 185, 196, 208, 220, 233, 247, 262, 277, 294, 311, 330, 349, 370, 392, 415, 440, 466, 494, 523, 554, 587, 622, 659, 698, 740, 784, 831, 880, 932, 988, 1047, 1109, 1175, 1245, 1319, 1397, 1480, 1568, 1661, 1760, 1865, 1976, 2093, 2217, 2349, 2489, 2637, 2794, 2960, 3136, 3322, 3520, 3729, 3951};
static void can_listen_cmd() {
	set_wave(0, WAVE_SINE);
	int old_note = 0;
	while (true) {
		can_frame frame = can_read();
		switch (frame.data[0]) {
			case 'P': {
				int note = (frame.data[1] - 1) * 12 + frame.data[2];
				if (note != old_note) {
					set_freq(0, freqs[note]);
					printf("Playing note %s\n", notes[note]);
					old_note = note;
				}
				break;
			}
			case 'R': {
				// TODO: Add polyphony
				if (old_note != 0) {
					printf("Stopping notes\n");
					old_note = 0;
					set_freq(0, 0);
				}
				break;
			}
			default: {
				// printf("Unknown command, data[0]: 0x%2X", frame.data[0]);
				break;
			}
		}
		if (readchar_nonblock()) {
			getchar();
			return;
		}
	}
}
#endif
#endif

void donut(void);

static void donut_cmd(void) {
	printf("Donut demo...\n");
	donut();
}

/*-----------------------------------------------------------------------*/
/* Console service / Main                                                */
/*-----------------------------------------------------------------------*/

static void console_service(void) {
	char *str;
	char *token;

	str = readstr();
	if (str == NULL)
		return;
	token = get_token(&str);
	if (strcmp(token, "help") == 0)
		help();
	else if (strcmp(token, "reboot") == 0)
		reboot_cmd();
	else if (strcmp(token, "donut") == 0)
		donut_cmd();
#ifdef CSR_LEDS_BASE
	else if (strcmp(token, "led") == 0)
		led_cmd();
	else if (strcmp(token, "leds") == 0)
		leds_cmd(&str);
#endif
#ifdef CSR_AUDIO_BASE
	else if (strcmp(token, "saw") == 0)
		saw_cmd(&str);
	else if (strcmp(token, "square") == 0)
		square_cmd(&str);
	else if (strcmp(token, "triangle") == 0)
		triangle_cmd(&str);
	else if (strcmp(token, "sine") == 0)
		sine_cmd(&str);
	else if (strcmp(token, "imperial") == 0)
		imperial_cmd();
	else if (strcmp(token, "roll") == 0)
		roll_cmd();
#endif
#ifdef CSR_DAC_VOL_BASE
	else if (strcmp(token, "volume") == 0)
		dac_vol_cmd(&str);
#endif
#ifdef CSR_CAN_BASE
	else if (strcmp(token, "can_id") == 0)
		can_id_cmd(&str);
	else if (strcmp(token, "can_mask") == 0)
		can_mask_cmd(&str);
	else if (strcmp(token, "can_read") == 0)
		can_read_cmd(&str);
	else if (strcmp(token, "can_watch") == 0)
		can_watch_cmd();
#ifdef CSR_AUDIO_BASE
	else if (strcmp(token, "can_listen") == 0)
		can_listen_cmd();
#endif
#endif
	prompt();
}

int main(void) {
#ifdef CONFIG_CPU_HAS_INTERRUPT
	irq_setmask(0);
	irq_setie(1);
#endif
	uart_init();

	help();
	prompt();

	while (1) {
		console_service();
	}
}
