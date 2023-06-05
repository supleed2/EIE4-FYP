# Bare Metal Demo App

This directory provides a basic bare metal demo app that demonstrates how to communicate / drive the custom logic in this project.

## Build and Load over LiteX-Term

The project is built with: ``BUILD_DIR=`realpath -eL build/gsd_orangecrab/` WITH_CXX=1 make -C demo``

The project board does not provide extra interfaces to connect to the board, so serial is used here: `$ litex_term --kernel demo/demo.bin /dev/ttyACMX` (ACM due to the use of `usb_acm` UART)

You should see the demo app running and should be able to interact with it:

```bash
$ litex_term --kernel demo/demo.bin /dev/ttyACM0
        __   _ __      _  __
       / /  (_) /____ | |/_/
      / /__/ / __/ -_)>  <
     /____/_/\__/\__/_/|_|
   Build your hardware, easily!

 (c) Copyright 2012-2022 Enjoy-Digital
 (c) Copyright 2007-2015 M-Labs

 BIOS built on Jun  5 2023 13:37:57
 BIOS CRC passed (f2f2af2d)

 LiteX git sha1: 310bc777

--=============== SoC ==================--
CPU:            VexRiscv @ 48MHz
BUS:            WISHBONE 32-bit @ 4GiB
CSR:            32-bit data
ROM:            128KiB
SRAM:           8KiB
L2:             8KiB
SDRAM:          131072KiB 16-bit @ 192MT/s (CL-6 CWL-5)

--========== Initialization ============--
Initializing SDRAM @0x40000000...
Switching SDRAM to software control.
Read leveling:
  m0, b00: |01110000| delays: 02+-01
  m0, b01: |00000000| delays: -
  m0, b02: |00000000| delays: -
  m0, b03: |00000000| delays: -
  best: m0, b00 delays: 02+-01
  m1, b00: |01110000| delays: 02+-01
  m1, b01: |00000000| delays: -
  m1, b02: |00000000| delays: -
  m1, b03: |00000000| delays: -
  best: m1, b00 delays: 02+-01
Switching SDRAM to hardware control.
Memtest at 0x40000000 (2.0MiB)...
  Write: 0x40000000-0x40200000 2.0MiB
   Read: 0x40000000-0x40200000 2.0MiB
Memtest OK
Memspeed at 0x40000000 (Sequential, 2.0MiB)...
  Write speed: 11.7MiB/s
   Read speed: 17.5MiB/s

--============== Boot ==================--
Booting from serial...
Press Q or ESC to abort boot completely.
sL5DdSMmkekro
[LITEX-TERM] Received firmware download request from the device.
[LITEX-TERM] Uploading kernel.bin to 0x40000000 (11248 bytes)...
[LITEX-TERM] Upload calibration... (inter-frame: 10.00us, length: 64)
[LITEX-TERM] Upload complete (54.1KB/s).
[LITEX-TERM] Booting the device.
[LITEX-TERM] Done.
Executing booted program at 0x40000000

--============= Liftoff! ===============--

LiteX custom demo app built Jun  5 2023 13:40:19

Available commands:
help               - Show this command
reboot             - Reboot CPU
donut              - Spinning Donut demo
saw                - Sawtooth Wave demo
square             - Square Wave demo
triangle           - Triangle Wave demo
sine               - Sine Wave demo
imperial           - Imperial March demo
roll               - Music demo
can_id             - Get / Set CAN ID
can_mask           - Get / Set CAN Mask
can_read           - Receive CAN Frames and print (delay in s)
can_watch          - Watch CAN Frames at 2Hz
can_listen         - Play CAN Frames as Audio
StackSynth>
```
