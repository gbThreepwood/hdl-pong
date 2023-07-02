# HDL-Pong
A realization of the classic Pong game using pure HDL (Verilog). Mostly a stepping stone for me to learn Verilog, but also a fun demonstration of the capabilities of FPGAs.

The project is heavily inspired by the tutorials on https://nandland.com/ and tested on the Go Board https://nandland.com/the-go-board/

## Hardware

* Go Board
* DIY game controller with push button and encoder

## Open source toolchain

All the tools required for synthesis and testing of the Verilog code are open source (although the official tools are proprietary). GNU Make (https://www.gnu.org/software/make/) is used to simplify the build process, and pyinvoke (https://www.pyinvoke.org/) is used to save me from typing the long commands to invoke the various tools.

For synthesis:

* yosys
* nextpnr
* Project IceStorm

For simulation and testing:

* iverilog
* verilator
* GTKWave


`yosys -p 'synth_ice40 -json vga_demo_top.json -top vga_demo_top' vga_demo_top.v vga_sync_pulses.v vga_test_pattern_generator.v vga_sync_add_porch.v debounce_switch.v block_ram.v bin_to_7_seg.v pong/pong_top.v pong/pong_score_display.v pong/pong_paddle_control.v pong/pong_ball_control.v`

`nextpnr-ice40 --hx1k --package vq100 --pcf nandland.pcf --json vga_demo_top.json --asc vga_demo_top.asc`

`icepack vga_demo_top.asc vga_demo_top.bin`

`iceprog vga_demo_top.bin`

## Structure

The project is split it to many modules with various purposes.

TODO: Beautiful block diagram of the module structure

On a higher level we have:

* Push button handling
* 7-segment display handling
* VGA handling
* UART handling
* Pong game logic
* Pong score and text display

