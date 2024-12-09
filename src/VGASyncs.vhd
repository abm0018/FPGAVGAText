----------------------------------------------------------------------------------
-- Engineer: Alex Mitchell 
-- Create Date: 12/07/2024 02:01:40 PM
-- Module Name: vga_syncs - Behavioral
-- Target Devices: Xilinx 7Series (targeting EBAZ4205 board)
-- Tool Versions: Vivado 2024.1+
-- Description: Controls H/V sync signals for VGA monitor. Bases timing off generic
--      ports specified on compile time. I have no desire to modify there paramters
--      during operation.
-- o_valid = '1' to let external state machine know when to draw. if '0', need to set color to 
-- off, else weird things happen with monitor.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vga_syncs is
    Generic (
        -- NOTE - g_Vertical timings are derived from H and set as constants below
        g_DEBUGENABLE : string := "FALSE";
        g_VRES : natural := 480; --Lines
        g_HRES : natural := 640; --Pixels per line
        g_HBACK_CC : natural := 48; --Clocks for Horizontal back porch
        g_HFRONT_CC : natural := 16; --Clocks for Vertical front porch
        g_HSYNC_CC : natural := 96 --Clocks to hold HSYNC LOW
    );
    Port (
        i_clock : in std_logic; -- Must be pixel clock for display
        o_hsync : out std_logic; -- sync signal to vga display
        o_vsync : out std_logic; -- sync signal to vga display
        o_blank : out std_logic; -- '1' when time to blank display
        o_row : out std_logic_vector(31 downto 0); -- index of current row (0 to 479)
        o_col : out std_logic_vector(31 downto 0) -- index of current col (0 to 639)
    );
end vga_syncs;

architecture Behavioral of vga_syncs is

constant g_VFRONT_ROWS : natural := 10;
constant g_VSYNC_ROWS : natural := 2;
constant g_VBACK_ROWS : natural := 33;
constant g_HCYCLE_CC : natural := g_HSYNC_CC + g_HBACK_CC + g_HFRONT_CC + g_HRES;
constant g_VFRONT_CC : natural := g_VFRONT_ROWS * g_HCYCLE_CC;
constant g_VSYNC_CC : natural := g_VSYNC_ROWS * g_HCYCLE_CC;
constant g_VBACK_CC : natural := g_VBACK_ROWS * g_HCYCLE_CC + g_VSYNC_CC;
constant g_VCYCLE_CC : natural := g_VSYNC_CC + g_VBACK_CC + g_VFRONT_CC + g_VRES;
constant g_VFRONT_START_CC : natural := (g_VBACK_ROWS + g_VRES) * g_HCYCLE_CC;
constant g_HFRONT_START_CC : natural := g_HBACK_CC + g_HRES + g_HSYNC_CC;

signal col_count : unsigned(31 downto 0) := (others=>'0');
signal row_count : unsigned(31 downto 0) := (others=>'0');
signal pixel_count : unsigned(31 downto 0) := (others=>'0');

signal v_back, v_front, h_back, h_front : std_logic; -- '1' when active

begin

h_front <= '1' when ((col_count > g_HRES) and (col_count <= (g_HRES + g_HFRONT_CC))) else '0';
o_hsync <= '0' when (col_count > (g_HRES + g_HFRONT_CC)) and (col_count <= g_HSYNC_CC + g_HRES + g_HFRONT_CC) else '1';
h_back <= '1' when (col_count > (g_HSYNC_CC + g_HRES + g_HFRONT_CC)) else '0';

v_front <= '1' when (row_count > g_VRES) and (row_count <= (g_VRES + g_VFRONT_ROWS)) else '0'; --may be wrong, not sure if I need to include vsync time
o_vsync <= '0' when (row_count > (g_VRES + g_VFRONT_ROWS)) and (row_count <= g_VRES + g_VFRONT_ROWS + g_VSYNC_ROWS ) else '1';
v_back <= '1' when (row_count > g_VRES + g_VFRONT_ROWS + g_VSYNC_ROWS) else '0';

pixelcount_proc : process(i_clock) begin
    if rising_edge(i_clock) then
        if ((row_count < g_VRES) and (col_count < g_HRES)) then
            o_blank <= '0';
            o_row <= std_logic_vector(row_count);
            o_col <= std_logic_vector(col_count);
        else
            o_blank <= '1';
        end if;
    end if;
end process;

counter_proc : process(i_clock) begin
    if rising_edge(i_clock) then
        if (col_count >= g_HCYCLE_CC) then --time to draw a new row
            col_count <= (others=>'0');
            
            --VBack=33H, VFront=10H, VSync=2H, VRES=480H
            if (row_count >= (g_VBACK_ROWS + g_VRES + g_VFRONT_ROWS + g_VSYNC_ROWS)) then --time to reset back to (0,0)
                row_count <= (others=>'0');
            else --have more rows to draw
                row_count <= row_count + 1;
            end if;
            
        else --keep drawing this row
            col_count <= col_count + 1;
        end if;
        
        -- Overall pixel counter (includes front/back porches)
        if ( (col_count = x"00000000") and (row_count = x"00000000")) then
            pixel_count <= (others=>'0');
        else
            pixel_count <= pixel_count + 1;
        end if;
        
    end if;
end process;

end Behavioral;
