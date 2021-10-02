# MSX1FPGA - DECA port 

DECA top level by Somhic & Shaeon & Rampa (11/08/21) adapted from Multicore2 port by Fabio Belavenuto  (MSX1 FPGA project   https://github.com/fbelavenuto/msx1fpga ).

**Features:**

* HDMI video output (640x480@60)
* VGA video output is available through GPIO
* Line out, HDMI audio output
* PWM audio is available through GPIO
* Joystick 1 available through GPIO .  **Joystick power pin must be 2.5 V**. 
  * **DANGER: Connecting power pin above 2.6 V may damage the FPGA**

**Additional hardware required**:

- SDRAM module. Tested with 32 MB SDRAM board for MiSTer (extra slim) XS_2.2 ([see connections](https://github.com/SoCFPGA-learning/DECA/tree/main/Projects/sdram_mister_deca)).
- PS/2 Keyboard connected to GPIO. See connections below

**Versions**:

- current version: 1.2
- see changelog in top level file /synth/DECA/msx_deca.vhd

**Compiling:**

* Load project  in /synth/DECA/msx_deca.qpf

* sof file already included in /synth/DECA/output_files/msx_deca.sof

  

**Pinout connections:**

![pinout_deca](pinout_deca.png)

**Others:**

* Button KEY0 & KEY1 are reset buttons

### STATUS

* Working fine

* HDMI video outputs special resolution so will not work on all monitors. 




### Keyboard Controls & original README files:

* English        [README.EN.md](README.EN.md)
* Castellano  [README.ES.md](README.ES.md)