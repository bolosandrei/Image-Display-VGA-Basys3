-- vga_display.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vga_display is
    Port ( clk, reset : in STD_LOGIC;
           VGA_HS_O : out STD_LOGIC;
           VGA_VS_O : out STD_LOGIC;
           VGA_RED_O : out STD_LOGIC_VECTOR (3 downto 0);
           VGA_BLUE_O : out STD_LOGIC_VECTOR (3 downto 0);
           VGA_GREEN_O : out STD_LOGIC_VECTOR (3 downto 0));
end vga_display;

architecture Behavioral of vga_display is
component vga_controller is
    port (clk, reset: in std_logic :='0';
        hsync, vsync: out std_logic;
        video_on, p_tick: out std_logic;
        pixel_x, pixel_y: out std_logic_vector (9 downto 0));
end component;

component ROM_mem is
    Port (enable : in std_logic;
          h_pos : in std_logic_vector(9 downto 0);
          v_pos : in std_logic_vector(9 downto 0);
          data : out std_logic_vector(3 downto 0));
end component;

signal red : std_logic_vector(3 downto 0) :=(others => '0');
signal green : std_logic_vector(3 downto 0) :=(others => '0');
signal blue : std_logic_vector(3 downto 0) :=(others => '0');
signal enable : std_logic :='0'; -- enable for display
signal p_tick : std_logic :='0';
signal data	: std_logic_vector(3 downto 0) :=(others => '0');
signal h_pos : std_logic_vector(9 downto 0) :=(others => '0');
signal v_pos : std_logic_vector(9 downto 0) :=(others => '0');

begin

vga_ctrl : vga_controller port map ( 
		clk => clk,
		reset => reset,
		hsync => VGA_HS_O,
		vsync => VGA_VS_O,
		pixel_x => h_pos,
		pixel_y => v_pos,
		video_on => enable,
		p_tick => p_tick);
		
rom_map : ROM_mem port map (
        enable => enable,
        h_pos => h_pos,
        v_pos => v_pos,
        data=>data);
        
enable_p:process(enable)
    begin    
        if (enable = '0') then -- or '1' --polarity
            blue <= (others => '0');
            green <= (others => '0');
            red <= (others => '0');
        else
--            red <= data(11 downto 8);
--            green <= data(7 downto 4);
            blue <= data(3 downto 0);
        end if;
    end process;
    -- Output
    VGA_RED_O <= blue;
    VGA_GREEN_O <= blue;
    VGA_BLUE_O <= blue;
end Behavioral;
