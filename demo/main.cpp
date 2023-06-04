// This file is Copyright (c) 2020 Florent Kermarrec <florent@enjoy-digital.fr>
// License: BSD

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <generated/csr.h>
#include <irq.h>
#include <libbase/console.h>
#include <libbase/uart.h>

#include "can"
#include "note"

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
	puts("saw                - Sawtooth Wave demo");
	puts("square             - Square Wave demo");
	puts("triangle           - Triangle Wave demo");
	puts("sine               - Sine Wave demo");
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
	int value = (int)strtol(get_token(val), NULL, 0);
	printf("Setting Oscillator 0 to Sawtooth: %dHz\n", value);
	wave(WAVE_SAW);
	audio_targ0_write(value);
}

static void square_cmd(char **val) {
	int value = (int)strtol(get_token(val), NULL, 0);
	printf("Setting Oscillator 0 to Square: %dHz\n", value);
	wave(WAVE_SQUARE);
	audio_targ0_write(value);
}

static void triangle_cmd(char **val) {
	int value = (int)strtol(get_token(val), NULL, 0);
	printf("Setting Oscillator 0 to Triangle: %dHz\n", value);
	wave(WAVE_TRIANGLE);
	audio_targ0_write(value);
}

static void sine_cmd(char **val) {
	int value = (int)strtol(get_token(val), NULL, 0);
	printf("Setting Oscillator 0 to Sine: %dHz\n", value);
	wave(WAVE_SINE);
	audio_targ0_write(value);
}

static void imperial_cmd() {
	note(NOTE_G4, 400);
	note(NOTE_NONE, 400);
	note(NOTE_G4, 400);
	note(NOTE_NONE, 400);
	note(NOTE_G4, 600);
	note(NOTE_NONE, 600);
	note(NOTE_D4S, 200);
	note(NOTE_A4S, 200);
	note(NOTE_G4, 600);
	note(NOTE_NONE, 200);
	note(NOTE_D4S, 400);
	note(NOTE_NONE, 200);
	note(NOTE_A4S, 200);
	note(NOTE_G4, 1000);
	note(NOTE_D4S, 600);
	note(NOTE_NONE, 200);
	note(NOTE_D5, 600);
	note(NOTE_NONE, 200);
	note(NOTE_D5, 600);
	note(NOTE_NONE, 200);
	note(NOTE_D5, 600);
	note(NOTE_NONE, 200);
	note(NOTE_D5S, 400);
	note(NOTE_NONE, 200);
	note(NOTE_A4S, 200);
	note(NOTE_F4S, 600);
	note(NOTE_NONE, 200);
	note(NOTE_D4S, 400);
	note(NOTE_NONE, 200);
	note(NOTE_A4S, 200);
	note(NOTE_G4, 800);
}

static void roll_cmd() {
	note(NOTE_C4S, 450);
	note(NOTE_D4S, 600);
	note(NOTE_G3S, 150);
	note(NOTE_D4S, 450);
	note(NOTE_F4, 450);
	note(NOTE_G4S, 90);
	note(NOTE_F4S, 90);
	note(NOTE_F4, 90);
	note(NOTE_C4S, 510);
	note(NOTE_D4S, 600);
	note(NOTE_G3S, 1500);
	note(NOTE_C4S, 450);
	note(NOTE_D4S, 600);
	note(NOTE_G3S, 150);
	note(NOTE_D4S, 450);
	note(NOTE_F4, 450);
	note(NOTE_G4S, 90);
	note(NOTE_F4S, 90);
	note(NOTE_F4, 90);
	note(NOTE_C4S, 510);
	note(NOTE_D4S, 600);
	note(NOTE_G3S, 1500);
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
