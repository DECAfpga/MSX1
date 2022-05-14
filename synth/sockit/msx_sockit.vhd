-------------------------------------------------------------------------------
--
-- SOCKIT top level by Somhic (08/05/22) 
-- 
-- adapted from Multicore2 port by Fabio Belavenuto  (MSX1 FPGA project https://github.com/fbelavenuto/msx1fpga ).
--
-- v1.0 initial release
-- v1.1 added joystick 1 functionality
-- v1.2 qsf & pin locations revised, changed pinout of joystick, audio level to maximum, pinout added
-- v1.3 VGA444 pinout 
--
-------------------------------------------------------------------------------
--
-- MSX1 FPGA project     https://github.com/fbelavenuto/msx1fpga
--
-- Copyright (c) 2016, Fabio Belavenuto (belavenuto@gmail.com)
-- 
-- TOP created by Victor Trucco (c) 2018
--
-- All rights reserved
--
-- Redistribution and use in source and synthezised forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
-- Redistributions of source code must retain the above copyright notice,
-- this list of conditions and the following disclaimer.
--
-- Redistributions in synthesized form must reproduce the above copyright
-- notice, this list of conditions and the following disclaimer in the
-- documentation and/or other materials provided with the distribution.
--
-- Neither the name of the author nor the names of other contributors may
-- be used to endorse or promote products derived from this software without
-- specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.
--
-- Please report bugs to the author, but before you do so, please
-- make sure that this is not a derivative work and that
-- you have the latest version of this file.
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.msx_pack.all;

entity msx_sockit is
	port (
		-- Clocks
		clock_50_i			: in    std_logic;

		-- Buttons
		KEY				: in    std_logic_vector(3 downto 0);

		-- Leds
		LED			: out    std_logic_vector(3 downto 0);

		-- SDRAM	(32MB)
		sdram_clk_o			: out   std_logic								:= '0';
		sdram_cke_o			: out   std_logic								:= '0';
		sdram_ad_o			: out   std_logic_vector(12 downto 0)	:= (others => '0');
		sdram_da_io			: inout std_logic_vector(15 downto 0)	:= (others => 'Z');
		sdram_ba_o			: out   std_logic_vector( 1 downto 0)	:= (others => '0');
		sdram_dqm_o			: out   std_logic_vector( 1 downto 0)	:= (others => '1');
		sdram_ras_o			: out   std_logic								:= '1';
		sdram_cas_o			: out   std_logic								:= '1';
		sdram_cs_o			: out   std_logic								:= '1';
		sdram_we_o			: out   std_logic								:= '1';

		-- PS2
		ps2_clk_io			: inout std_logic								:= 'Z';
		ps2_data_io			: inout std_logic								:= 'Z';
		ps2_mouse_clk_io  	: inout std_logic								:= 'Z';
		ps2_mouse_data_io 	: inout std_logic								:= 'Z';

		-- SD Card
		sd_cs_n_o			: out   std_logic								:= '1';
		sd_sclk_o			: out   std_logic								:= '0';
		sd_mosi_o			: out   std_logic								:= '0';
		sd_miso_i			: in    std_logic;
	
		-- Joysticks
		joy1_up_i			: in    std_logic 	:= 'Z';
		joy1_down_i			: in    std_logic  	:= 'Z';
		joy1_left_i			: in    std_logic  	:= 'Z';
		joy1_right_i		: in    std_logic  	:= 'Z';
		joy1_p6_i			: in    std_logic  	:= 'Z';
		joy1_p9_i			: in    std_logic  	:= 'Z';
		joy2_up_i			: in    std_logic  	:= 'Z';
		joy2_down_i			: in    std_logic  	:= 'Z';
		joy2_left_i			: in    std_logic  	:= 'Z';
		joy2_right_i		: in    std_logic  	:= 'Z';
		joy2_p6_i			: in    std_logic  	:= 'Z';
		joy2_p9_i			: in    std_logic  	:= 'Z';
		joyX_p7_o			: out   std_logic 	:= 'Z';		

		-- Audio
		-- dac_l_o				: out   std_logic								:= '0';
		-- dac_r_o				: out   std_logic								:= '0';
		-- ear_i				: in    std_logic;
		--mic_o				: out   std_logic								:= '0';

		-- VGA
		VGA_HS			: OUT STD_LOGIC := '1';
		VGA_VS			: OUT STD_LOGIC := '1';
		VGA_R			: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		VGA_G			: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		VGA_B			: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		VGA_SYNC_n		: OUT STD_LOGIC;
		VGA_BLANK_n		: OUT STD_LOGIC;
		VGA_CLK			: OUT STD_LOGIC;
 
		-- AUDIO CODEC   
		AUD_ADCDAT   : in std_logic;
		AUD_ADCLRCK  : inout std_logic;
		AUD_BCLK     : inout std_logic;
		AUD_DACDAT   : out std_logic;
		AUD_DACLRCK  : inout std_logic;
		AUD_I2C_SCLK : out std_logic;
		AUD_I2C_SDAT : inout std_logic;
		AUD_MUTE     : out std_logic;  --DAC Output Mute, Active Low
		AUD_XCK      : out std_logic

	);
end entity;

architecture behavior of msx_sockit is

	-- Buttons
	signal btn_por_n_s		: std_logic;
	signal btn_reset_n_s		: std_logic;
	signal btn_scan_s		: std_logic;

	-- Resets
	signal pll_locked_s		: std_logic;
	signal por_s			: std_logic;
	signal reset_s			: std_logic;
	signal soft_reset_k_s		: std_logic;
	signal soft_reset_s_s		: std_logic;
	signal soft_por_s		: std_logic;
	signal soft_rst_cnt_s		: unsigned(7 downto 0)	:= X"FF";

	-- Clocks
	signal clock_sdram_s		: std_logic;
	signal clock_master_s		: std_logic;
	signal clock_vdp_s		: std_logic;
	signal clock_cpu_s		: std_logic;
	signal clock_psg_en_s		: std_logic;
	signal clock_3m_s		: std_logic;
	signal turbo_on_s		: std_logic;
	signal clock_vga_s		: std_logic;

	-- RAM
	signal ram_addr_s		: std_logic_vector(22 downto 0);		-- 8MB
	signal ram_data_from_s		: std_logic_vector( 7 downto 0);
	signal ram_data_to_s		: std_logic_vector( 7 downto 0);
	signal ram_ce_s		: std_logic;
	signal ram_oe_s		: std_logic;
	signal ram_we_s		: std_logic;

	-- VRAM memory
	signal vram_addr_s		: std_logic_vector(13 downto 0);		-- 16K
	signal vram_do_s		: std_logic_vector( 7 downto 0);
	signal vram_di_s		: std_logic_vector( 7 downto 0);
--	signal vram_ce_s		: std_logic;
--	signal vram_oe_s		: std_logic;
	signal vram_we_s		: std_logic;

	-- Audio
	signal audio_scc_s		: signed(14 downto 0);
	signal audio_psg_s		: unsigned( 7 downto 0);
	signal beep_s			: std_logic;
	signal audio_l_s		: unsigned(15 downto 0);
	signal audio_r_s		: unsigned(15 downto 0);
	signal audio_l_amp_s		: unsigned(15 downto 0);
	signal audio_r_amp_s		: unsigned(15 downto 0);
	signal volumes_s		: volumes_t;

	-- sound_i2s
	signal sound_i2s_l_s	: std_logic_vector(15 downto 0);
	signal sound_i2s_r_s	: std_logic_vector(15 downto 0);

	-- Video
	signal rgb_col_s		: std_logic_vector( 3 downto 0);
--	signal rgb_hsync_n_s		: std_logic;
--	signal rgb_vsync_n_s		: std_logic;
	signal cnt_hor_s		: std_logic_vector( 8 downto 0);
	signal cnt_ver_s		: std_logic_vector( 7 downto 0);
	signal vga_hsync_n_s		: std_logic;
	signal vga_vsync_n_s		: std_logic;
	signal vga_blank_s		: std_logic;
	signal vga_col_s		: std_logic_vector( 3 downto 0);
	signal vga_r_s			: std_logic_vector( 3 downto 0);
	signal vga_g_s			: std_logic_vector( 3 downto 0);
	signal vga_b_s			: std_logic_vector( 3 downto 0);
	signal scanlines_en_s		: std_logic;
	signal odd_line_s		: std_logic;

	-- Keyboard
	signal rows_s			: std_logic_vector( 3 downto 0);
	signal cols_s			: std_logic_vector( 7 downto 0);
	signal caps_en_s		: std_logic;
	signal extra_keys_s		: std_logic_vector( 3 downto 0);
	signal keyb_valid_s		: std_logic;
	signal keyb_data_s		: std_logic_vector( 7 downto 0);
	signal keymap_addr_s	: std_logic_vector( 8 downto 0);
	signal keymap_data_s	: std_logic_vector( 7 downto 0);
	signal keymap_we_s		: std_logic;

	-- Joystick
	signal joy1_out_s		: std_logic;
	signal joy2_out_s		: std_logic;

	-- Bus
	signal bus_addr_s		: std_logic_vector(15 downto 0);
	signal bus_data_from_s		: std_logic_vector( 7 downto 0)	:= (others => '1');
	signal bus_data_to_s		: std_logic_vector( 7 downto 0);
	signal bus_rd_n_s		: std_logic;
	signal bus_wr_n_s		: std_logic;
	signal bus_m1_n_s		: std_logic;
	signal bus_iorq_n_s		: std_logic;
	signal bus_mreq_n_s		: std_logic;
	signal bus_sltsl1_n_s		: std_logic;
	signal bus_sltsl2_n_s		: std_logic;
	signal bus_int_n_s		: std_logic;
	signal bus_wait_n_s		: std_logic;

	-- JT51
	signal jt51_cs_n_s		: std_logic;
	signal jt51_data_from_s	: std_logic_vector( 7 downto 0)	:= (others => '1');
	signal jt51_hd_s		: std_logic				:= '0';
	signal jt51_left_s		: signed(15 downto 0)			:= (others => '0');
	signal jt51_right_s		: signed(15 downto 0)			:= (others => '0');
		
	-- OPLL
	signal opll_cs_n_s		: std_logic				:= '1';
	signal opll_mo_s		: signed(12 downto 0)			:= (others => '0');
	signal opll_ro_s		: signed(12 downto 0)			:= (others => '0');


	-- FOR sdram_nes.v  NES from Mister port, https://github.com/MiSTer-devel/NES_MiSTer/blob/88b8ec80f7d848c2ea99c224698682a6bbae273b/rtl/sdram.sv
	--
	component sdram
		port (
		SDRAM_DQ : inout std_logic_vector (15 downto 0);
		SDRAM_A : out std_logic_vector (12 downto 0);
		SDRAM_DQML : out std_logic;
		SDRAM_DQMH : out std_logic;
		SDRAM_BA : out std_logic_vector (1 downto 0);
		SDRAM_nCS : out std_logic;
		SDRAM_nWE : out std_logic;
		SDRAM_nRAS : out std_logic;
		SDRAM_nCAS : out std_logic;
		SDRAM_CLK : out std_logic;
		init : in std_logic;
		clk : in std_logic;
		ch0_addr : in std_logic_vector (24 downto 0);
		ch0_rd : in std_logic;
		ch0_wr : in std_logic;
		ch0_din : in std_logic_vector (7 downto 0);
		ch0_dout : out std_logic_vector (7 downto 0)
		-- ch0_busy : out std_logic;
		-- refresh : in std_logic
	);
	end component;

	component audio_top
		port (
		clk : in std_logic;
		rst_n : in std_logic;
		mix : in std_logic;
		rdata : in std_logic_vector  ( 15-1 downto 0);
		ldata : in std_logic_vector  ( 15-1 downto 0);
		exchan : in std_logic;
		aud_bclk : out std_logic;
		aud_daclrck : out std_logic;
		aud_dacdat : out std_logic;
		aud_xck : out std_logic;
		i2c_sclk : out std_logic;
		i2c_sdat : inout std_logic
	);
	end component;
	
	signal exchan : std_logic;
	signal mix : std_logic;

	component i2s_decoder is
		Port ( 	
				clk : in STD_LOGIC; 
				sck : in STD_LOGIC; 
				ws  : in STD_LOGIC;
				sd  : in STD_LOGIC;
				left_out : 	out SIGNED(15 downto 0);  	
				right_out: 	out SIGNED(15 downto 0)  	
		);
	end component;	

	signal adc_l: SIGNED(15 downto 0);
	signal adc_r: SIGNED(15 downto 0);

	-- EAR
	signal ear_i  : std_logic;

	--pll1
	component pll is
		port (
			refclk   : in  std_logic := 'X'; -- clk
			rst      : in  std_logic := 'X'; -- reset
			outclk_0 : out std_logic;        -- clk
			outclk_1 : out std_logic;        -- clk
			outclk_2 : out std_logic;        -- clk
			locked   : out std_logic         -- export
		);
	end component pll;

begin


	-- PLL1
	pll1: pll
	port map (
		refclk		=> clock_50_i,
		rst			=> '0',
		outclk_0			=> clock_master_s,		-- 21.477 MHz				[21.484]
		outclk_1			=> clock_sdram_s,		-- 85.908 MHz (4x master)	[85.937]
		--outclk_2		=> sdram_clk_o,			-- 85.908 MHz -90°
		locked		=> pll_locked_s
	);

	-- PLL2
	pll2: entity work.pll2
	port map (
		inclk0		=> clock_50_i,
		c0			=> clock_vga_s		--  25.200
		--c1		=> clock_hdmi,		-- 	50.400
		--locked	=> open
	);

	-- Clocks
	clks: entity work.clocks
	port map (
		clock_i		=> clock_master_s,
		por_i			=> not pll_locked_s,
		turbo_on_i		=> turbo_on_s,
		clock_vdp_o		=> clock_vdp_s,
		clock_5m_en_o		=> open,
		clock_cpu_o		=> clock_cpu_s,
		clock_psg_en_o		=> clock_psg_en_s,
		clock_3m_o		=> clock_3m_s
	);

	-- The MSX1
	the_msx: entity work.msx
	generic map (
		hw_id_g		=> 8,
		hw_txt_g		=> "Sockit Board",
		hw_version_g		=> actual_version,
		video_opt_g		=> 3,							-- No dblscan and external palette (Color in rgb_r_o)
		ramsize_g		=> 8192,
		hw_hashwds_g		=> '0'
	)
	port map (
		-- Clocks
		clock_i			=> clock_master_s,
		clock_vdp_i		=> clock_vdp_s,
		clock_cpu_i		=> clock_cpu_s,
		clock_psg_en_i	=> clock_psg_en_s,
		-- Turbo
		turbo_on_k_i	=> extra_keys_s(3),	-- F11
		turbo_on_o		=> turbo_on_s,
		-- Resets
		reset_i			=> reset_s,
		por_i			=> por_s,
		softreset_o		=> soft_reset_s_s,
		-- Options
		opt_nextor_i		=> '1',
		opt_mr_type_i		=> "00",
		opt_vga_on_i		=> '1',
		-- RAM
		ram_addr_o		=> ram_addr_s,
		ram_data_i		=> ram_data_from_s,
		ram_data_o		=> ram_data_to_s,
		ram_ce_o		=> ram_ce_s,
		ram_we_o		=> ram_we_s,
		ram_oe_o		=> ram_oe_s,
		-- ROM
		rom_addr_o		=> open,
		rom_data_i		=> ram_data_from_s,
		rom_ce_o		=> open,
		rom_oe_o		=> open,
		-- External bus
		bus_addr_o		=> bus_addr_s,
		bus_data_i		=> bus_data_from_s,
		bus_data_o		=> bus_data_to_s,
		bus_rd_n_o		=> bus_rd_n_s,
		bus_wr_n_o		=> bus_wr_n_s,
		bus_m1_n_o		=> bus_m1_n_s,
		bus_iorq_n_o		=> bus_iorq_n_s,
		bus_mreq_n_o		=> bus_mreq_n_s,
		bus_sltsl1_n_o		=> bus_sltsl1_n_s,
		bus_sltsl2_n_o		=> bus_sltsl2_n_s,
		bus_wait_n_i		=> bus_wait_n_s,
		bus_nmi_n_i		=> '1',
		bus_int_n_i		=> bus_int_n_s,
		-- VDP RAM
		vram_addr_o		=> vram_addr_s,
		vram_data_i		=> vram_do_s,
		vram_data_o		=> vram_di_s,
		vram_ce_o		=> open,--vram_ce_s,
		vram_oe_o		=> open,--vram_oe_s,
		vram_we_o		=> vram_we_s,
		-- Keyboard
		rows_o			=> rows_s,
		cols_i			=> cols_s,
		caps_en_o		=> caps_en_s,
		keyb_valid_i		=> keyb_valid_s,
		keyb_data_i		=> keyb_data_s,
		keymap_addr_o		=> keymap_addr_s,
		keymap_data_o		=> keymap_data_s,
		keymap_we_o		=> keymap_we_s,
		-- Audio
		audio_scc_o		=> audio_scc_s,
		audio_psg_o		=> audio_psg_s,
		beep_o			=> beep_s,
		volumes_o		=> volumes_s,
		-- K7
		k7_motor_o		=> open,
		k7_audio_o		=> open,    --mic_o
		k7_audio_i		=> ear_i,
		-- Joystick
		joy1_up_i		=> joy1_up_i,
		joy1_down_i		=> joy1_down_i,
		joy1_left_i		=> joy1_left_i,
		joy1_right_i	=> joy1_right_i,
		joy1_btn1_i		=> joy1_p6_i,
		joy1_btn1_o		=> open,
		joy1_btn2_i		=> joy1_p9_i,
		joy1_btn2_o		=> open,
		joy1_out_o		=> joy1_out_s,
		-- -- Original code for joystick 2
		-- joy2_up_i		=> joy2_up_i,
		-- joy2_down_i		=> joy2_down_i,
		-- joy2_left_i		=> joy2_left_i,
		-- joy2_right_i	=> joy2_right_i,
		-- joy2_btn1_i		=> joy2_p6_i,
		-- joy2_btn1_o		=> open,
		-- joy2_btn2_i		=> joy2_p9_i,
		-- joy2_btn2_o		=> open,
		-- joy2_out_o		=> joy2_out_s,
		joy2_up_i		=> '1',
		joy2_down_i		=> '1',
		joy2_left_i		=> '1',
		joy2_right_i	=> '1',
		joy2_btn1_i		=> '1',
		joy2_btn1_o		=> open,
		joy2_btn2_i		=> '1',
		joy2_btn2_o		=> open,
		joy2_out_o		=> joy2_out_s,


		-- Video
		cnt_hor_o		=> cnt_hor_s,
		cnt_ver_o		=> cnt_ver_s,
		rgb_r_o			=> rgb_col_s,
		rgb_g_o			=> open,
		rgb_b_o			=> open,
		hsync_n_o		=> open,
		vsync_n_o		=> open,
		ntsc_pal_o		=> open,
		vga_on_k_i		=> '0',
		scanline_on_k_i => '0',
		vga_en_o		=> open,
		-- SPI/SD
		spi_cs_n_o		=> sd_cs_n_o,
		spi_sclk_o		=> sd_sclk_o,
		spi_mosi_o		=> sd_mosi_o,
		spi_miso_i		=> sd_miso_i,
		sd_pres_n_i		=> '0',
		sd_wp_i			=> '0',
		-- DEBUG
		D_wait_o		=> open,
		D_slots_o		=> open,
		D_ipl_en_o		=> open
	);

	joyX_p7_o <= not joy1_out_s;		-- for Sega Genesis joypad
	--joy2_p7_o <= not joy2_out_s;	-- for Sega Genesis joypad

	-- RAM
    -- FOR sdram_nes.v  from Mister port, https://github.com/MiSTer-devel/NES_MiSTer/blob/88b8ec80f7d848c2ea99c224698682a6bbae273b/rtl/sdram.sv
	--
	sdram_cke_o <= '1';
	sdram_inst : sdram
	port map (
		SDRAM_DQ => sdram_da_io,
		SDRAM_A => sdram_ad_o,
		SDRAM_DQML => sdram_dqm_o(0),
		SDRAM_DQMH => sdram_dqm_o(1),
		SDRAM_BA => sdram_ba_o,
		SDRAM_nCS => sdram_cs_o,
		SDRAM_nWE => sdram_we_o,
		SDRAM_nRAS => sdram_ras_o,
		SDRAM_nCAS => sdram_cas_o,
		SDRAM_CLK => sdram_clk_o,
		clk => clock_sdram_s,
		init => reset_s,
		ch0_addr => "00" & ram_addr_s,
		ch0_rd => ram_oe_s and ram_ce_s,			
		ch0_wr => ram_we_s and ram_ce_s,
		ch0_din => ram_data_to_s,
		ch0_dout => ram_data_from_s
	);


	-- VRAM
	vram: entity work.spram
	generic map (
		addr_width_g => 14,
		data_width_g => 8
	)
	port map (
		clk_i		=> clock_master_s,
		we_i		=> vram_we_s,
		addr_i		=> vram_addr_s,
		data_i		=> vram_di_s,
		data_o		=> vram_do_s
	);

	-- Keyboard PS/2
	keyb: entity work.keyboard
	port map (
		clock_i		=> clock_3m_s,
		reset_i		=> reset_s,
		-- MSX
		rows_coded_i		=> rows_s,
		cols_o			=> cols_s,
		keymap_addr_i		=> keymap_addr_s,
		keymap_data_i		=> keymap_data_s,
		keymap_we_i		=> keymap_we_s,
		-- LEDs
		led_caps_i		=> caps_en_s,
		-- PS/2 interface
		ps2_clk_io		=> ps2_clk_io,
		ps2_data_io		=> ps2_data_io,
		-- Direct Access
		keyb_valid_o		=> keyb_valid_s,
		keyb_data_o		=> keyb_data_s,
		--
		reset_o		=> soft_reset_k_s,
		por_o			=> soft_por_s,
		reload_core_o		=> open,
		extra_keys_o		=> extra_keys_s
	);

	-- Audio
	mixer: entity work.mixeru
	port map (
		clock_i		=> clock_master_s,
		reset_i		=> reset_s,
		volumes_i		=> volumes_s,
		beep_i			=> beep_s,
		ear_i			=> ear_i,
		audio_scc_i		=> audio_scc_s,
		audio_psg_i		=> audio_psg_s,
		jt51_left_i		=> jt51_left_s,
		jt51_right_i		=> jt51_right_s,
		opll_mo_i		=> opll_mo_s,
		opll_ro_i		=> opll_ro_s,
		audio_mix_l_o		=> audio_l_s,
		audio_mix_r_o		=> audio_r_s
	);

	-- audio_l_amp_s	<= audio_l_s(15) & audio_l_s(13 downto 0) & "0";
	-- audio_r_amp_s	<= audio_r_s(15) & audio_r_s(13 downto 0) & "0";

	audio_l_amp_s	<= "0" & audio_l_s(15) & audio_l_s(13 downto 0);
	audio_r_amp_s	<= "0" & audio_r_s(15) & audio_r_s(13 downto 0);

	-- EAR AUDIO CODEC SOCKIT
	--Convert adc_l  to  ear signal 
	--Ramon Martinez Palomares, [7/5/22 23:43]
	--https://github.com/MiSTer-devel/Template_MiSTer/blob/master/sys/ltc2308.sv#L105
	--Puedes hacerte un process buscando la histeresis superior e inferior sobre el sample.
	--Por ejemplo > 20000 que te dé un 1 y < -20000 0

	midi_module : i2s_decoder
	port map(
		clk      => clock_50_i,
		sck      => AUD_BCLK,
		ws       => AUD_ADCLRCK,
		sd       => AUD_ADCDAT,
		left_out => adc_l,
		right_out=> adc_r
	);

	PROCESS (adc_l)  
	BEGIN
		IF (adc_l > 20000) THEN
			ear_i <= '1';
		ELSIF (adc_l < -20000) THEN
			ear_i <= '0';
		END IF;
	END PROCESS;


	--  AUDIO CODEC
	AUD_MUTE <= '1';  -- KEY(3);
	exchan <= '0';
	mix <= '0';
	
	audio_top_inst : audio_top
	  port map (
	  clk     =>      clock_50_i,     -- input clock
	  rst_n   =>      not reset_s,		  -- active low reset (from reset button)
	  -- config
	  exchan  =>      exchan,		  -- switch audio left / right channel
	  mix     =>      mix,			  -- normal / centered mix (play some left channel on the right channel and vise-versa)
	  -- audio shifter
	  rdata   =>      std_logic_vector(audio_r_amp_s(14 downto 0)),	-- right channel sample data
	  ldata   =>      std_logic_vector(audio_l_amp_s(14 downto 0)),	-- left channel sample data
	  aud_bclk=>      AUD_BCLK,	  		-- CODEC data clock
	  aud_daclrck=>   AUD_DACLRCK,		-- CODEC data clock
	  aud_dacdat =>   AUD_DACDAT,		-- CODEC data
	  aud_xck =>      AUD_XCK,  		-- CODEC data clock
	  -- I2C audio config
	  i2c_sclk=>      AUD_I2C_SCLK,  	-- CODEC config clock
	  i2c_sdat=>      AUD_I2C_SDAT   	-- CODEC config data
	);	

	-- -- Left Channel
	-- audiol : entity work.dac
	-- generic map (
	-- 	nbits_g	=> 16
	-- )
	-- port map (
	-- 	reset_i	=> reset_s,
	-- 	clock_i	=> clock_3m_s,
	-- 	dac_i		=> audio_l_amp_s,
	-- 	dac_o		=> dac_l_o
	-- );

	-- -- Right Channel
	-- audior : entity work.dac
	-- generic map (
	-- 	nbits_g	=> 16
	-- )
	-- port map (
	-- 	reset_i	=> reset_s,
	-- 	clock_i	=> clock_3m_s,
	-- 	dac_i		=> audio_r_amp_s,
	-- 	dac_o		=> dac_r_o
	-- );

	
	-- MIDI
	--	midi_cs_n_s	<= '0' when bus_addr_s(7 downto 1) = "0111111" and bus_iorq_n_s = '0' and bus_m1_n_s = '1'	else '1';	-- 0x7E - 0x7F

		-- MIDI interface
	--	midi: entity work.midiIntf
	--	port map (
	--		clock_i		=> clock_8m_s,
	--		reset_i		=> reset_s,
	--		addr_i			=> bus_addr_s(0),
	--		cs_n_i			=> midi_cs_n_s,
	--		wr_n_i			=> bus_wr_n_s,
	--		rd_n_i			=> bus_rd_n_s,
	--		data_i			=> bus_data_to_s,
	--		data_o			=> midi_data_from_s,
	--		has_data_o		=> midi_hd_s,
	--		-- Outs
	--		int_n_o		=> midi_int_n_s,
	--		wait_n_o		=> midi_wait_n_s,
	--		tx_o			=> uart_tx_o
	--	);


	-- Glue logic

	-- Resets
	btn_por_n_s		<= KEY(2); 
	btn_reset_n_s	<= KEY(1); 

	por_s		<= '1'	when pll_locked_s = '0' or soft_por_s = '1' or btn_por_n_s = '0'		else '0';
	reset_s		<= '1'	when soft_rst_cnt_s = X"01"                 or btn_reset_n_s = '0'		else '0';

	process(reset_s, clock_master_s)
	begin
		if reset_s = '1' then
			soft_rst_cnt_s	<= X"00";
		elsif rising_edge(clock_master_s) then
			if (soft_reset_k_s = '1' or soft_reset_s_s = '1' or por_s = '1') and soft_rst_cnt_s = X"00" then
				soft_rst_cnt_s	<= X"FF";
			elsif soft_rst_cnt_s /= X"00" then
				soft_rst_cnt_s <= soft_rst_cnt_s - 1;
			end if;
		end if;
	end process;

	---------------------------------
	-- scanlines
	btnscl: entity work.debounce
	generic map (
		counter_size_g	=> 16
	)
	port map (
		clk_i				=> clock_master_s,
		button_i			=> KEY(1) or KEY(2),
		result_o			=> btn_scan_s
	);
	
	process (por_s, btn_scan_s)
	begin
		if por_s = '1' then
			scanlines_en_s <= '0';
		elsif falling_edge(btn_scan_s) then
			scanlines_en_s <= not scanlines_en_s;
		end if;
	end process;

	-- VGA framebuffer
	vga: entity work.vga
	port map (
		I_CLK			=> clock_master_s,
		I_CLK_VGA		=> clock_vga_s,
		I_COLOR			=> rgb_col_s,
		I_HCNT			=> cnt_hor_s,
		I_VCNT			=> cnt_ver_s,
		O_HSYNC			=> vga_hsync_n_s,
		O_VSYNC			=> vga_vsync_n_s,
		O_COLOR			=> vga_col_s,
		O_HCNT			=> open,
		O_VCNT			=> open,
		O_H				=> open,
		O_BLANK			=> vga_blank_s
	);

	-- Scanlines
	process(vga_hsync_n_s,vga_vsync_n_s)
	begin
		if vga_vsync_n_s = '0' then
			odd_line_s <= '0';
		elsif rising_edge(vga_hsync_n_s) then
			odd_line_s <= not odd_line_s;
		end if;
	end process;

	-- Index => RGB 
	process (clock_vga_s)
		variable vga_col_v	: integer range 0 to 15;
		variable vga_rgb_v	: std_logic_vector(15 downto 0);
		variable vga_r_v		: std_logic_vector( 3 downto 0);
		variable vga_g_v		: std_logic_vector( 3 downto 0);
		variable vga_b_v		: std_logic_vector( 3 downto 0);
		type ram_t is array (natural range 0 to 15) of std_logic_vector(15 downto 0);
		constant rgb_c : ram_t := (
				--      RB0G
				0  => X"0000",
				1  => X"0000",
				2  => X"240C",
				3  => X"570D",
				4  => X"5E05",
				5  => X"7F07",
				6  => X"D405",
				7  => X"4F0E",
				8  => X"F505",
				9  => X"F707",
				10 => X"D50C",
				11 => X"E80C",
				12 => X"230B",
				13 => X"CB09",
				14 => X"CC0C",
				15 => X"FF0F"
		);
	begin
		if rising_edge(clock_vga_s) then
			vga_col_v := to_integer(unsigned(vga_col_s));
			vga_rgb_v := rgb_c(vga_col_v);
			if scanlines_en_s = '1' then
				--
				if vga_rgb_v(15 downto 12) > 1 and odd_line_s = '1' then
					vga_r_s <= vga_rgb_v(15 downto 12) - 2;
				else
					vga_r_s <= vga_rgb_v(15 downto 12);
				end if;
				--
				if vga_rgb_v(11 downto 8) > 1 and odd_line_s = '1' then
					vga_b_s <= vga_rgb_v(11 downto 8) - 2;
				else
					vga_b_s <= vga_rgb_v(11 downto 8);
				end if;
				--
				if vga_rgb_v(3 downto 0) > 1 and odd_line_s = '1' then
					vga_g_s <= vga_rgb_v(3 downto 0) - 2;
				else
					vga_g_s <= vga_rgb_v(3 downto 0);
				end if;
			else
				vga_r_s <= vga_rgb_v(15 downto 12);
				vga_b_s <= vga_rgb_v(11 downto  8);
				vga_g_s <= vga_rgb_v( 3 downto  0);
			end if;
		end if;
	end process;

	VGA_R	<= vga_r_s & vga_r_s;
	VGA_G	<= vga_g_s & vga_g_s;
	VGA_B	<= vga_b_s & vga_b_s;
	VGA_HS	<= vga_hsync_n_s;
	VGA_VS	<= vga_vsync_n_s;

	VGA_SYNC_n	<= '0'; 
	VGA_BLANK_n	<= vga_hsync_n_s and vga_vsync_n_s;  --'1'
	VGA_CLK		<= clock_vga_s;

	-- Peripheral BUS control
	bus_data_from_s	<= jt51_data_from_s	when jt51_hd_s = '1'	else
--							   midi_data_from_s	when midi_hd_s = '1'	else
								(others => '1');
	bus_wait_n_s		<= '1';--midi_wait_n_s;
	bus_int_n_s		<= '1';--midi_int_n_s;

	-- JT51
	jt51_cs_n_s <= '0' when bus_addr_s(7 downto 1) = "0010000" and bus_iorq_n_s = '0' and bus_m1_n_s = '1'	else '1';	-- 0x20 - 0x21

	jt51: entity work.jt51_wrapper
	port map (
		clock_i		=> clock_3m_s,
		reset_i		=> reset_s,
		addr_i			=> bus_addr_s(0),
		cs_n_i			=> jt51_cs_n_s,
		wr_n_i			=> bus_wr_n_s,
		rd_n_i			=> bus_rd_n_s,
		data_i			=> bus_data_to_s,
		data_o			=> jt51_data_from_s,
		has_data_o		=> jt51_hd_s,
		ct1_o			=> open,
		ct2_o			=> open,
		irq_n_o		=> open,
		p1_o			=> open,
		-- Low resolution output (same as real chip)
		sample_o		=> open,
		left_o			=> open,
		right_o		=> open,
		-- Full resolution output
		xleft_o		=> jt51_left_s,
		xright_o		=> jt51_right_s,
		-- unsigned outputs for sigma delta converters, full resolution		
		dacleft_o		=> open,
		dacright_o		=> open
	);

	-- OPLL
	opll_cs_n_s	<= '0' when bus_addr_s(7 downto 1) = "0111110" and bus_iorq_n_s = '0' and bus_m1_n_s = '1'	else '1';	-- 0x7C - 0x7D

	opll1 : entity work.opll 
	port map (
		clock_i		=> clock_master_s,
		clock_en_i		=> clock_psg_en_s,
		reset_i		=> reset_s,
		data_i			=> bus_data_to_s,
		addr_i			=> bus_addr_s(0),
		cs_n        		=> opll_cs_n_s,
		we_n        		=> bus_wr_n_s,
		melody_o		=> opll_mo_s,
		rythm_o		=> opll_ro_s
	);



	-- DEBUG
	LED(0)		<= not turbo_on_s;
	LED(1)		<= not caps_en_s;
	LED(2)		<= not soft_reset_k_s;
	LED(3)		<= not soft_por_s;

end architecture;
