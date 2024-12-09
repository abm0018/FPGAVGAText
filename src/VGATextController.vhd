----------------------------------------------------------------------------------
-- Company: Alex Mitchell
-- Engineer:  Alex Mitchell
-- Create Date: 12/08/2024 08:03:10 PM
-- Module Name: VGATextController - Behavioral
-- Target Devices: Xilinx 7Series
-- Tool Versions: Vivado 2024.1+
-- Description: Module instatiates my VGA controller and this serves as an axi
--  to VGA interface for writing text to a 640x480 display
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_misc.all;

entity VGATextController is
    Generic(
        DEBUGENABLE : string := "FALSE";
        VRES : natural := 480; --pixels
        HRES : natural := 640; --pixels
        HBACK_CC : natural := 48; --Clock cycles for horizontal back porch
        HFRONT_CC : natural := 16; --Clock cycles for horizontal front porch
        HSYNC_CC : natural := 96; --Clock cycles for hsync
        CBITS : natural := 3 --number of bits per color
    );
    Port (
        i_pixelclock : in std_logic; --needs to be 25 MHz for ~60Hz, 640x480
        o_hsync : out std_logic;
        o_vsync : out std_logic;
        o_red : out std_logic_vector(CBITS-1 downto 0);
        o_green : out std_logic_vector(CBITS-1 downto 0);
        o_blue : out std_logic_vector(CBITS-1 downto 0);
        TextBuf_addr : in std_logic_vector(14 downto 0); --byte address from axi bram controller
        TextBuf_clk : in STD_LOGIC;
        TextBuf_din : in STD_LOGIC_VECTOR ( 31 downto 0 );
        TextBuf_en : in std_logic;
        TextBuf_we : in STD_LOGIC_VECTOR ( 3 downto 0 )
--        s_axi_aclk : IN STD_LOGIC;
--        s_axi_aresetn : IN STD_LOGIC;
--        s_axi_awaddr : IN STD_LOGIC_VECTOR(14 DOWNTO 0);
--        s_axi_awlen : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
--        s_axi_awsize : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
--        s_axi_awburst : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
--        s_axi_awlock : IN STD_LOGIC;
--        s_axi_awcache : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
--        s_axi_awprot : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
--        s_axi_awvalid : IN STD_LOGIC;
--        s_axi_awready : OUT STD_LOGIC;
--        s_axi_wdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
--        s_axi_wstrb : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
--        s_axi_wlast : IN STD_LOGIC;
--        s_axi_wvalid : IN STD_LOGIC;
--        s_axi_wready : OUT STD_LOGIC;
--        s_axi_bresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
--        s_axi_bvalid : OUT STD_LOGIC;
--        s_axi_bready : IN STD_LOGIC;
--        s_axi_araddr : IN STD_LOGIC_VECTOR(14 DOWNTO 0);
--        s_axi_arlen : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
--        s_axi_arsize : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
--        s_axi_arburst : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
--        s_axi_arlock : IN STD_LOGIC;
--        s_axi_arcache : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
--        s_axi_arprot : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
--        s_axi_arvalid : IN STD_LOGIC;
--        s_axi_arready : OUT STD_LOGIC;
--        s_axi_rdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
--        s_axi_rresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
--        s_axi_rlast : OUT STD_LOGIC;
--        s_axi_rvalid : OUT STD_LOGIC;
--        s_axi_rready : IN STD_LOGIC
    );
end VGATextController;

architecture Behavioral of VGATextController is

component vga_syncs is
    Generic (
        -- NOTE - g_Vertical timings are derived from H and set as constants below
        g_DEBUGENABLE : string := DEBUGENABLE;
        g_VRES : natural := VRES; --Lines
        g_HRES : natural := HRES; --Pixels per line
        g_HBACK_CC : natural := HBACK_CC; --Clocks for Horizontal back porch
        g_HFRONT_CC : natural := HFRONT_CC; --Clocks for Vertical front porch
        g_HSYNC_CC : natural := HSYNC_CC --Clocks to hold HSYNC LOW
    );
    Port (
        i_clock : in std_logic; -- Must be pixel clock for display
        o_hsync : out std_logic; -- sync signal to vga display
        o_vsync : out std_logic; -- sync signal to vga display
        o_blank : out std_logic; -- '1' when time to blank display
        o_row : out std_logic_vector(31 downto 0); -- index of current row (0 to 479)
        o_col : out std_logic_vector(31 downto 0) -- index of current col (0 to 639)
    );
end component;

COMPONENT Char_ROM
  PORT (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(63 DOWNTO 0) 
  );
END COMPONENT;

COMPONENT Text_Buffer
  PORT (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
    clkb : IN STD_LOGIC;
    enb : IN STD_LOGIC;
    addrb : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(10 DOWNTO 0) 
  );
END COMPONENT;

COMPONENT axi_bram_ctrl_0
  PORT (
    s_axi_aclk : IN STD_LOGIC;
    s_axi_aresetn : IN STD_LOGIC;
    s_axi_awaddr : IN STD_LOGIC_VECTOR(14 DOWNTO 0);
    s_axi_awlen : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    s_axi_awsize : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    s_axi_awburst : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    s_axi_awlock : IN STD_LOGIC;
    s_axi_awcache : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    s_axi_awprot : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    s_axi_awvalid : IN STD_LOGIC;
    s_axi_awready : OUT STD_LOGIC;
    s_axi_wdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axi_wstrb : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    s_axi_wlast : IN STD_LOGIC;
    s_axi_wvalid : IN STD_LOGIC;
    s_axi_wready : OUT STD_LOGIC;
    s_axi_bresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    s_axi_bvalid : OUT STD_LOGIC;
    s_axi_bready : IN STD_LOGIC;
    s_axi_araddr : IN STD_LOGIC_VECTOR(14 DOWNTO 0);
    s_axi_arlen : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    s_axi_arsize : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    s_axi_arburst : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    s_axi_arlock : IN STD_LOGIC;
    s_axi_arcache : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    s_axi_arprot : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    s_axi_arvalid : IN STD_LOGIC;
    s_axi_arready : OUT STD_LOGIC;
    s_axi_rdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axi_rresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    s_axi_rlast : OUT STD_LOGIC;
    s_axi_rvalid : OUT STD_LOGIC;
    s_axi_rready : IN STD_LOGIC;
    bram_rst_a : OUT STD_LOGIC;
    bram_clk_a : OUT STD_LOGIC;
    bram_en_a : OUT STD_LOGIC;
    bram_we_a : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    bram_addr_a : OUT STD_LOGIC_VECTOR(14 DOWNTO 0);
    bram_wrdata_a : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    bram_rddata_a : IN STD_LOGIC_VECTOR(31 DOWNTO 0) 
  );
END COMPONENT;

signal vga_clock : std_logic; --25 MHz clock for VGA display output (640x480 @ ~60Hz)
signal hsync, vsync : std_logic;
signal blank : std_logic;
signal vga_row, vga_col : unsigned(31 downto 0);

signal red, green, blue : std_logic_vector(2 downto 0); --internal pixel values
signal red_out, green_out, blue_out : std_logic_vector(2 downto 0); --pixel values that get sent to DAC (gets blanked)

signal rom_pixel_idx : unsigned(5 downto 0);
signal rom_data : std_logic_vector(63 downto 0);
signal rom_addr : std_logic_vector(7 downto 0);
signal pixel_out : std_logic;

signal text_addr : std_logic_vector(12 downto 0) := (others=>'0');
signal text_data : std_logic_vector(10 downto 0);

--signal TextBuf_addr : std_logic_vector(14 downto 0); --byte address from axi bram controller
signal TextBuf_word_addr : STD_LOGIC_VECTOR( 12 downto 0 ); --word address that goes to the text buffer ram addr in
--signal TextBuf_clk : STD_LOGIC;
--signal TextBuf_din : STD_LOGIC_VECTOR ( 31 downto 0 );
signal TextBuf_dout : STD_LOGIC_VECTOR ( 31 downto 0 );
--signal TextBuf_en : STD_LOGIC;
signal TextBuf_rst : STD_LOGIC;
--signal TextBuf_we : STD_LOGIC_VECTOR ( 3 downto 0 );
signal TextBuf_wea : std_logic;
signal TextColor : std_logic_vector(2 downto 0);

begin

o_hsync <= hsync;
o_vsync <= vsync;
o_red <= red_out;
o_green <= green_out;
o_blue <= blue_out;
vga_clock <= i_pixelclock;

TextBuf_wea <= or_reduce(TextBuf_we);
text_addr <= std_logic_vector(vga_row(8 downto 3)) & std_logic_vector(vga_col(9 downto 3));
rom_addr <= text_data(7 downto 0);
TextColor <= text_data(10 downto 8);
rom_pixel_idx <= vga_row(2 downto 0) & (vga_col(2 downto 0)-1);
pixel_out <= rom_data(to_integer(rom_pixel_idx));
TextBuf_word_addr <= TextBuf_addr(14 downto 2);

red_out <= red when blank = '0' else (others=>'0');
green_out <= green when blank = '0' else (others=>'0');
blue_out <= blue when blank = '0' else (others=>'0');

red(0) <= pixel_out and TextColor(0);
red(1) <= pixel_out and TextColor(0);
red(2) <= pixel_out and TextColor(0);
        
green(0) <= pixel_out and TextColor(1);
green(1) <= pixel_out and TextColor(1);
green(2) <= pixel_out and TextColor(1);

blue(0) <= pixel_out and TextColor(2);
blue(1) <= pixel_out and TextColor(2);
blue(2) <= pixel_out and TextColor(2);

text_buffer_inst : Text_Buffer --maps pixel (row,col) to ascii val to pass to ROM
  port map (
    clka => TextBuf_clk, --axi interfac
    ena => TextBuf_en, --axi inteface
    wea(0) => TextBuf_wea, --axi interface
    addra => TextBuf_word_addr, --axi inteface
    dina => TextBuf_din(10 downto 0), --axi inteface
    clkb => vga_clock, --vga side
    enb => '1',
    addrb => text_addr,
    doutb => text_data --TODO Future, add 3 extra bits at MSB, these will control the text color...
  );

char_rom_inst : Char_ROM
  port map (
    clka => vga_clock,
    ena => '1',
    addra => rom_addr,
    douta => rom_data
  );

vga_sync_inst : vga_syncs
    port map (
        i_clock => vga_clock, -- Must be pixel clock for display
        o_hsync => hsync, -- sync signal to vga display
        o_vsync => vsync, -- sync signal to vga display
        o_blank => blank, -- '1' when cur pixel is visible. 
        unsigned(o_row) => vga_row, -- index of current row (0 to 479)
        unsigned(o_col) => vga_col -- index of current col (0 to 639)
    );

--axi_bram_ctrl_inst : axi_bram_ctrl_0
--  PORT MAP (
--    s_axi_aclk => s_axi_aclk,
--    s_axi_aresetn => s_axi_aresetn,
--    s_axi_awaddr => s_axi_awaddr,
--    s_axi_awlen => s_axi_awlen,
--    s_axi_awsize => s_axi_awsize,
--    s_axi_awburst => s_axi_awburst,
--    s_axi_awlock => s_axi_awlock,
--    s_axi_awcache => s_axi_awcache,
--    s_axi_awprot => s_axi_awprot,
--    s_axi_awvalid => s_axi_awvalid,
--    s_axi_awready => s_axi_awready,
--    s_axi_wdata => s_axi_wdata,
--    s_axi_wstrb => s_axi_wstrb,
--    s_axi_wlast => s_axi_wlast,
--    s_axi_wvalid => s_axi_wvalid,
--    s_axi_wready => s_axi_wready,
--    s_axi_bresp => s_axi_bresp,
--    s_axi_bvalid => s_axi_bvalid,
--    s_axi_bready => s_axi_bready,
--    s_axi_araddr => s_axi_araddr,
--    s_axi_arlen => s_axi_arlen,
--    s_axi_arsize => s_axi_arsize,
--    s_axi_arburst => s_axi_arburst,
--    s_axi_arlock => s_axi_arlock,
--    s_axi_arcache => s_axi_arcache,
--    s_axi_arprot => s_axi_arprot,
--    s_axi_arvalid => s_axi_arvalid,
--    s_axi_arready => s_axi_arready,
--    s_axi_rdata => s_axi_rdata,
--    s_axi_rresp => s_axi_rresp,
--    s_axi_rlast => s_axi_rlast,
--    s_axi_rvalid => s_axi_rvalid,
--    s_axi_rready => s_axi_rready,
--    bram_rst_a => TextBuf_rst,
--    bram_clk_a => TextBuf_clk,
--    bram_en_a => TextBuf_en,
--    bram_we_a => TextBuf_we,
--    bram_addr_a => TextBuf_addr,
--    bram_wrdata_a => TextBuf_din,
--    bram_rddata_a => TextBuf_dout
--  );

end Behavioral;
