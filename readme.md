# StackSynth Final Year Project

## Project Notes

- [Guide on adding a new core (incomplete)](https://github.com/enjoy-digital/litex/wiki/Add-A-New-Core)
  - [Using LiteEth on ECP5](https://github.com/enjoy-digital/liteeth/issues/66)
  - [Adding HW modules](https://github.com/enjoy-digital/litex/issues/746), lots more info in issue
    - Possible useful info in [soc.py](litex/litex/soc/integration/soc.py), Lines 1311 - 2106
- [CORDIC Block Development Repository](https://github.com/supleed2/cordic)

### Useful links

- [FreeRTOS Quick Start Guide](https://www.freertos.org/FreeRTOS-quick-start-guide.html)
- CAN Bus Implementation
  - [CAN bus: Base Frame Format - Wikipedia](https://en.wikipedia.org/wiki/CAN_bus#Base_frame_format)
  - [Texas Instruments: Introduction to CAN](https://www.ti.com/lit/an/sloa101b/sloa101b.pdf)
  - [Bosch CAN Specification 2.0](http://esd.cs.ucr.edu/webres/can20.pdf)
  - [CAN Tx Frame Implementation using Verilog](https://jusst.org/wp-content/uploads/2021/07/CAN-Tx-Frame.pdf), reference for timing diagrams?
  - [Datasheet for CAN Transceiver](https://www.digikey.co.uk/en/products/detail/microchip-technology/ATA6561-GAQW-N/9453180)
  - [Understanding Microchip’s CAN Module Bit Timing](https://ww1.microchip.com/downloads/en/Appnotes/00754.pdf)
- Sine Approximation for Sawtooth - Sine Conversion
  - Polynomial Approximation
    - [Desmos Demonstration (Screenshot)](sine_poly_approx.png)
  - CORDIC Research
    - [Area/Energy Efficient CORDIC Accelerator](https://www.researchgate.net/publication/309549123_Area_and_Energy_efficient_CORDIC_Accelerator_for_Embedded_Processor_Datapaths)
    - [Doulos SNUG Europe 2004 Paper](https://www.doulos.com/knowhow/systemverilog/a-users-experience-with-systemverilog/), [local copy of Verilog](doulos_CORDIC.v)
    - ZIPcpu: [Using a CORDIC to calculate sines and cosines in an FPGA](https://zipcpu.com/dsp/2017/08/30/cordic.html)
- [API Reference migen, AsyncFIFO](https://m-labs.hk/migen/manual/reference.html#module-migen.genlib.fifo)
- [Guide on adding a new core (incomplete)](https://github.com/enjoy-digital/litex/wiki/Add-A-New-Core)
  - [Using LiteEth on ECP5](https://github.com/enjoy-digital/liteeth/issues/66)
  - [Adding HW modules](https://github.com/enjoy-digital/litex/issues/746), lots more info in issue
    - Possible useful info in [soc.py](litex/litex/soc/integration/soc.py), Lines 1311 - 2106
    - Also [generic_platform.py](litex/litex/build/generic_platform.py), Lines 324 - 522
  - [Migen Guide](https://m-labs.hk/migen/manual/fhdl.html)
  - [LiteX SPI Core](https://github.com/litex-hub/litespi)
  - [FoMu Example of using external Verilog](https://github.com/im-tomu/foboot/blob/c7ee25b3d10dba0c1df67e793c4e2585577e7a39/hw/foboot-bitstream.py#L507-L537)
  - [Automatic LiteX Documentation](https://github.com/enjoy-digital/litex/wiki/SoC-Documentation)
- [Migen (base for litex) GitHub Repository](https://github.com/m-labs/migen)
- [Litex Wiki: reusing SV or other cores](https://github.com/enjoy-digital/litex/wiki/Reuse-a-(System)Verilog,-VHDL,-(n)Migen,-Spinal-HDL,-Chisel-core)
- [Litex for Hardware Engineers](https://github.com/enjoy-digital/litex/wiki/LiteX-for-Hardware-Engineers)
- [Example of RTOS on LiteX](https://numato.com/kb/running-zephyr-rtos-on-mimas-a7-using-litex-and-risc-v/)
- [Blog on using FreeRTOS on stock VexRiscV Core](https://hackmd.io/@4a740UnwQE6K9pc5tNlJpg/H1olFPOCD)
- [FreeRTOS on RiscV Blog Post](https://hackmd.io/@oscarshiang/freertos_on_riscv)
- [Video on FreeRTOS on RiscV](https://www.youtube.com/watch?v=tM0hiBVP728)
- [VexRiscV Source](https://github.com/SpinalHDL/VexRiscv)
- [Summon FPGA Tools Repo](https://github.com/open-tool-forge/summon-fpga-tools)
- [Broken Flag issue when building litex](https://github.com/enjoy-digital/litex/issues/825)
- [On-board DAC Datasheet](https://www.ti.com/product/PCM1780)
- Definitely reference when talking about sending PCM data from the 48MHz RISC-V domain to the ~38MHz DAC domain
  - [CDC Design Techniques - Sunburst Design](http://www.sunburst-design.com/papers/CummingsSNUG2008Boston_CDC.pdf)
  - [Async FIFO Design - Sunburst Design](http://www.sunburst-design.com/papers/CummingsSNUG2002SJ_FIFO1.pdf)
  - [Dual-Clock Async FIFO in SV - Verilog Pro](https://www.verilogpro.com/asynchronous-fifo-design/)
  - [CDC Design 3 Part Series - Verilog Pro](https://www.verilogpro.com/clock-domain-crossing-part-1/)
  - [Simple CDC - ZipCPU](https://zipcpu.com/blog/2017/10/20/cdc.html)
  - [CDC with an Async FIFO - ZipCPU](https://zipcpu.com/blog/2018/07/06/afifo.html)
    - [Source on GitHub - afifo.v](https://github.com/ZipCPU/website/blob/master/examples/afifo.v)
  - [CDC with an FPGA - NandLand](https://nandland.com/lesson-14-crossing-clock-domains/)
    - Contained recommendations on signals, including using Almost-Empty/Full signals to avoid situations where the signal is invalid due to signal propegation & timing requirements
- [LiteScope GitHub Repository](https://github.com/enjoy-digital/litescope) - Scope to record signals internal to the FPGA Fabric
  - [GitHub Wiki - Use LiteScope To Debug A SoC](https://github.com/enjoy-digital/litex/wiki/Use-LiteScope-To-Debug-A-SoC)
  - [litex-buildenv wiki on using LiteX](https://github.com/timvideos/litex-buildenv/wiki/Notes-and-Tips#litescope)
  - [Posible irc discusions on LiteScope?](https://freenode.irclog.whitequark.org/litex/search?q=litescope)

### Cool Things To Note

- `python -m litex.tools.litex_read_verilog ./rtl/flipPwm.sv` allows for auto-gen of the LiteX `Class` needed to create an instance, however it does not set up the `CSRStorage`.
- [Load Application Code To CPU](https://github.com/enjoy-digital/litex/wiki/Load-Application-Code-To-CPU)
- [Use LiteScope To Debug A SoC](https://github.com/enjoy-digital/litex/wiki/Use-LiteScope-To-Debug-A-SoC)
- [Use GDB with VexRiscv CPU](https://github.com/enjoy-digital/litex/wiki/Use-GDB-with-VexRiscv-CPU)
- [Run Zephyr On Your SoC](https://github.com/enjoy-digital/litex/wiki/Run-Zephyr-On-Your-SoC)

### Possible reference links

- [OrangeCrab FPGA Product Page](https://www.latticesemi.com/products/developmentboardsandkits/orangecrab)
- [OrangeCrab FPGA Hardware Repo](https://github.com/orangecrab-fpga/orangecrab-hardware)
- [OrangeCrab FPGA Example Repo](https://github.com/orangecrab-fpga/orangecrab-examples)
  - Use both the Verilog and Blink examples, the CircuitPython example did not work due to the version of CircuitPython needed (I think?)
- [OrangeCrab FPGA Store Listing](https://1bitsquared.com/products/orangecrab)
- [OrangeCrab FPGA Github Docs](https://orangecrab-fpga.github.io/orangecrab-hardware/r0.2/)
- [Hackster post on OrangeCrab FPGA](https://www.hackster.io/news/orangecrab-a-formidable-feature-packed-fpga-feather-04fd6c99eb0f)
- [element14 post on OrangeCrab FPGA](https://community.element14.com/products/roadtest/rv/roadtest_reviews/1481/summer_of_fpgas_oran_1)
- [CNX Software post on OrangeCrab FPGA](https://www.cnx-software.com/2019/08/28/orangecrab-is-an-open-source-hardware-feather-compatible-lattice-ecp5-fpga-board/)
- [Example writeup of using OrangeCrab FPGA](https://codeconstruct.com.au/docs/microwatt-orangecrab/)
- [Amaranth / Migen Crash Course](https://cfu-playground.readthedocs.io/en/latest/crash-course/gateware.html)
- [LiteX Soft-CPU, FPGA and Firmware Support](https://docs.google.com/spreadsheets/d/e/2PACX-1vRavhDreE8bIVYJGl6nKMut_hneywklO9EHSfusXk4Txy3U_l_Ld7ssVO9roR0bTElYEny-DuNLtxAw/pubhtml?gid=0&single=true)
- [FPGA MicroPython (FμPy)](https://fupy.github.io/)
- [FuPy (FPGA MicroPython) on Mimas v2 and Arty](https://ewen.mcneill.gen.nz/blog/entry/2018-01-17-fupy-fpga-micropython-on-mimas-v2-and-arty-a7/)
- [enjoy-digital/litex GitHub](https://github.com/enjoy-digital/litex)
- [litex/boot.c · enjoy-digital/litex](https://github.com/enjoy-digital/litex/blob/master/litex/soc/software/bios/boot.c#L386)
- [litex/litex_setup.py · enjoy-digital/litex](https://github.com/enjoy-digital/litex/blob/master/litex_setup.py)
- [picolibc switch Issue #1045 · enjoy-digital/litex](https://github.com/enjoy-digital/litex/issues/1045)
- [Vexriscv secure CPU Issue #1585 · enjoy-digital/litex](https://github.com/enjoy-digital/litex/issues/1585)
- [LD_FLAGS Issue #825 · enjoy-digital/litex](https://github.com/enjoy-digital/litex/issues/825)
- [Home · enjoy-digital/litex Wiki](https://github.com/enjoy-digital/litex/wiki)
- [gregdavill/linux-on-litex-vexriscv](https://github.com/gregdavill/linux-on-litex-vexriscv/tree/orangecrab)
- [OrangeCrab-test-sw/hw](https://github.com/gregdavill/OrangeCrab-test-sw/tree/main/hw)
- [gregdavill:orangecrab vs upstream · litex-hub/linux-on-litex-vexriscv](https://github.com/litex-hub/linux-on-litex-vexriscv/compare/master...gregdavill:linux-on-litex-vexriscv:orangecrab)
- [Prebuilt Bitstreams and Linux/OpenSBI images for linux on litex](https://github.com/litex-hub/linux-on-litex-vexriscv/issues/164)
- [linux-on-litex-vexriscv/buildroot/board](https://github.com/litex-hub/linux-on-litex-vexriscv/tree/master/buildroot/board)
- [litex-hub/litex-boards: LiteX boards files](https://github.com/litex-hub/litex-boards)
- [litex-boards/lattice_ecp5_evn.py](https://github.com/litex-hub/litex-boards/blob/master/litex_boards/targets/lattice_ecp5_evn.py)
- [litex-boards/lattice_ecp5_vip.py](https://github.com/litex-hub/litex-boards/blob/master/litex_boards/targets/lattice_ecp5_vip.py)
- [litex-boards/litex_boards/targets](https://github.com/litex-hub/litex-boards/tree/master/litex_boards/targets)
- [mwelling/orangecrab-test](https://github.com/mwelling/orangecrab-test)
- [Use read_verilog in Yosys orangecrab example command](https://github.com/orangecrab-fpga/orangecrab-examples/commit/32a8c075bbcdb2d8bb7da99e4cde6d9997d88463)
- [litex example cannot find Yosys or nextpnr-ecp5 programs](https://github.com/orangecrab-fpga/orangecrab-examples/issues/10)
- [Migrate nMigen examples to Amaranth in orangecrab example](https://github.com/orangecrab-fpga/orangecrab-examples/pull/30)
- [RISC-V with custom gateware Issue #35 · orangecrab-fpga/orangecrab-hardware](https://github.com/orangecrab-fpga/orangecrab-hardware/issues/35)
- [Lattice Diamond Compatibility Issue #41 · orangecrab-fpga/orangecrab-hardware](https://github.com/orangecrab-fpga/orangecrab-hardware/issues/41)
- [timvideos/litex-buildenv](https://github.com/timvideos/litex-buildenv)
- [Bare Metal · timvideos/litex-buildenv Wiki](https://github.com/timvideos/litex-buildenv/wiki/Bare-Metal)
- [YosysHQ/nextpnr: nextpnr portable FPGA place and route tool](https://github.com/YosysHQ/nextpnr)
- [Lattice FPGA SBCs can run Linux on RISC-V softcore](https://linuxgizmos.com/lattice-fpga-sbcs-can-run-linux-on-risc-v-softcore/)
- [litex_liteeth.c:undefined reference to `devm_platform_ioremap_resource_byname'](https://lore.kernel.org/lkml/202202070822.w4rpU462-lkp@intel.com/T/)
- [Linux on LiteX-Vexriscv - Hacker News](https://news.ycombinator.com/item?id=25726356)
- [Running Zephyr RTOS on Mimas A7 using LiteX and RISC-V](https://numato.com/kb/running-zephyr-rtos-on-mimas-a7-using-litex-and-risc-v/)
- [Downloads | OrangeCrab Docs](https://orangecrab-fpga.github.io/orangecrab-hardware/r0.2/docs/downloads/)
- [Zephyr on Fomu FPGA](https://workshop.fomu.im/en/latest/renode-zephyr.html)
- [Building a SoC with Litex. – controlpaths blog](https://www.controlpaths.com/2022/01/17/building-a-soc-with-litex/)
- [Running Linux on a Litex SoC. – controlpaths blog](https://www.controlpaths.com/2022/03/28/running-linux-on-a-litex-soc/)
- [Say “Hello” to the OrangeCrab - Hackster.io](https://www.hackster.io/news/say-hello-to-the-orangecrab-16835001f36a)
- [LiteX Research Paper???](https://www.researchgate.net/publication/341202045_LiteX_an_open-source_SoC_builder_and_library_based_on_Migen_Python_DSL)
- [learn-fpga/toolchain.md · BrunoLevy/learn-fpga](https://github.com/BrunoLevy/learn-fpga/blob/master/FemtoRV/TUTORIALS/toolchain.md)
- [Testing the OrangeCrab r0.1 Blog](https://whatnicklife.blogspot.com/2020/01/testing-orangecrab-r01.html)
- [FOSS-for_FPGA Slideshow](https://indico.ictp.it/event/9443/session/258/contribution/587/material/slides/0.pdf)
- [FPGA Tooling on Ubuntu 20.04 - FPGA Dev](https://projectf.io/posts/fpga-dev-ubuntu-20.04/)
- [Reddit question on riscv core on fpga](https://www.reddit.com/r/RISCV/comments/t1raxb/is_it_possible_to_build_a_riscv_core_on_fpga/)
- [linux-on-litex-vexriscv/orangecrab_with_enc28j60_on_spi.md](https://github.com/niw/linux-on-litex-vexriscv/blob/add_enc28j60_to_orange_crab/orangecrab_with_enc28j60_on_spi.md)
- [Previous paper using LiteX](https://www.martin-schreiber.info/data/student_projects/BA_2021_martin_troiber.pdf)
