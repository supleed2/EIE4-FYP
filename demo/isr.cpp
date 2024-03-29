// This file is Copyright (c) 2013-2014 Sebastien Bourdeauducq <sb@m-labs.hk>
// This file is Copyright (c) 2019 Gabriel L. Somlo <gsomlo@gmail.com>
// This file is Copyright (c) 2020 Raptor Engineering, LLC <sales@raptorengineering.com>
// License: BSD

#include "can"
#include <generated/csr.h>
#include <generated/soc.h>
#include <irq.h>
#include <libbase/uart.h>
#include <stdio.h>

#ifdef CONFIG_CPU_HAS_INTERRUPT
void isr(void) {
	__attribute__((unused)) unsigned int irqs;

	irqs = irq_pending() & irq_getmask();

#ifdef CSR_UART_BASE
#ifndef UART_POLLING
	if (irqs & (1 << UART_INTERRUPT))
		uart_isr();
#endif
#ifdef CAN_INTERRUPT
	if (irqs & (1 << CAN_INTERRUPT))
		can_isr();
#endif
#endif
}
#endif
