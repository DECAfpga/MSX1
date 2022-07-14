# MSX1FPGA - DECA port 

DECA top level by Somhic & Shaeon & Rampa (11/08/21) adapted from Multicore2 port by Fabio Belavenuto  (MSX1 FPGA project   https://github.com/fbelavenuto/msx1fpga ).

**Now compatible with [Deca Retro Cape 2](https://github.com/somhi/DECA_retro_cape_2)** (new location for 3 pins of old SDRAM modules). Otherwise see pinout below to connect everything through GPIOs.

**Features:**

* HDMI video output (640x480@60)
* VGA 444 video output is available through GPIO (see pinout below). 
* Line out (3.5 jack green connector) and HDMI audio output
* PWM audio is available through GPIO 
* Joystick available through GPIO  (see pinout below).  **Joystick power pin must be 2.5 V**
  * **DANGER: Connecting power pin above 2.6 V may damage the FPGA**
  * This core is prepared for Megadrive 6 button gamepads as it outputs a permanent high level on pin 7 of DB9

**Additional hardware required**:

- SDRAM module. Tested with 32 MB SDRAM board for MiSTer (extra slim) XS_2.2 ([see connections](https://github.com/SoCFPGA-learning/DECA/tree/main/Projects/sdram_mister_deca))
- PS/2 Keyboard connected to GPIO  (see pinout below)

**Versions**:

- current version: 1.3
- see changelog in top level file /synth/DECA/msx_deca.vhd

**Compiling:**

* Load project from /synth/DECA/msx_deca.qpf

* sof/svf files already included in /synth/DECA/output_files/

  

**Pinout connections:**

![pinout_deca](pinout_deca.png)

MIDI and UART pins are not used in this core.

**Others:**

* Button KEY0 & KEY1 are reset buttons

### STATUS

* Working fine

* HDMI video outputs special resolution so will not work on all monitors. 




### Keyboard Controls & original README files:

* English        [README.EN.md](README.EN.md)
* Castellano  [README.ES.md](README.ES.md)