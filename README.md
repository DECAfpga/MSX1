# MSX1FPGA - DECA port 

DECA top level by Somhic & Shaeon & Rampa (11/08/21) adapted from Multicore2 port by Fabio Belavenuto  (MSX1 FPGA project   https://github.com/fbelavenuto/msx1fpga ).

**Features:**

* HDMI video output (640x480@60)
  * VGA video output is available through GPIO
* Line out, HDMI audio output
  * PWM audio is possible through GPIO

**Additional hardware required**:

- SDRAM module. Tested with 32 MB SDRAM board for MiSTer (extra slim) XS_2.2 ([see connections](https://github.com/SoCFPGA-learning/DECA/tree/main/Projects/sdram_mister_deca)).
- PS/2 Keyboard connected to GPIO. See connections below

**Versions**:

- current version: 1.0
- see changelog in top level file /synth/DECA/msx_deca.vhd

**Compiling:**

* Load project  in /synth/DECA/msx_deca.qpf

* sof file already included in /synth/DECA/output_files/msx_deca.sof

  

**Keyboard connections:**

* It is needed to connect PS2 keyboard to GPIO P9 connector (next to HDMI connector):
  * P9:11 PS2CLK 
  * P9:12 PS2DAT 

**Others:**

* Button KEY0 & KEY1 are reset buttons

### STATUS

* Working

* HDMI video not tested on many monitors. Might not work on all.




### Keyboard Controls & original README files

* English        [README.EN.md](README.EN.md)
* Castellano  [README.ES.md](README.ES.md)