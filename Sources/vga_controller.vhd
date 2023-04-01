-- vga_controller.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.NUMERIC_STD.ALL;

entity vga_controller is
  port (clk, reset: in std_logic;
        hsync, vsync: out std_logic;
        video_on, p_tick: out std_logic;
        pixel_x, pixel_y: out std_logic_vector (9 downto 0));
end vga_controller;

architecture Behavioral of vga_controller is
    -- VGA 640-by-480 sync parameters
    constant HD: integer:=640; --horizontal display area
    constant HF: integer:=16 ; --h. front porch
    constant HB: integer:=48 ; --h. back porch
    constant HR: integer:=96 ; --h. retrace
    constant VD: integer:=480; --vertical display area
    constant VF: integer:=10;  --v. front porch
    constant VB: integer:=33;  --v. back porch
    constant VR: integer:=2;   --v. retrace
    
    signal nr : std_logic_vector(1 downto 0) := "00"; -- 2 bit counter
    signal rgb_out : std_logic_vector(11 downto 0) := x"000";
    signal h_pos : integer RANGE 0 to 1023 := 0;
    signal v_pos : integer RANGE 0 to 1023 := 0;
    signal rgb_enable : std_logic := '0';
    -- status signals
    signal h_end, v_end, pixel_tick: std_logic;
begin
   -- freq divider
freq_div: process(clk) -- clk - 100MHZ (Basys 3) => 25 MHz pixel tick
    begin
       if (clk'event and clk='1') then
           nr <= nr + 1; --nr este pe 2 biti, oricum se reseteaza cand se face "11" + 1 => "00"
       end if;
    end process freq_div;
    pixel_tick <= nr(1);
--    pixel_tick <= '1' when num4(1)='1' else '0';
    -- status
    h_end <=  -- end of horizontal counter
      '1' when h_pos=(HD+HF+HB+HR-1) else --799
      '0';
    v_end <=  -- end of vertical counter
      '1' when v_pos=(VD+VF+VB+VR-1) else --524
      '0';
   -- mod-800 horizontal sync counter
    process (pixel_tick)
    begin
    if rising_edge(pixel_tick) then
       if h_end='1' then
          h_pos <= 0;
       else
          h_pos <= h_pos + 1;
       end if;
    end if;
    end process;
    
    -- mod-525 vertical sync counter
    process (pixel_tick,h_pos)
    begin
    if rising_edge(pixel_tick) and h_end='1' then
       if (v_end='1') then
          v_pos <= 0;
       else
          v_pos <= v_pos + 1;
       end if;
    end if;
    end process;
    
h_sync: process(pixel_tick, h_pos)
    begin
        if(rising_edge(pixel_tick)) then
            if (h_pos>(HD+HF)) and (h_pos<=(HD+HF+HR-1)) then
                hsync <= '1';
            else
                hsync <= '0';
            end if;
        end if;
    end process;
    
v_sync: process(pixel_tick, v_pos)
    begin
        if(rising_edge(pixel_tick)) then
            if (v_pos>(VD+VF)) and (v_pos<=(VD+VF+VR-1)) then
                vsync <= '1';
            else
                vsync <= '0';
            end if;
        end if;
    end process;
        	  
video_enable: process(pixel_tick, h_pos, v_pos)
begin
	if(rising_edge(pixel_tick)) then
		if h_pos <= HD and v_pos <= VD then
			rgb_enable <= '1';
		else
			rgb_enable <= '0';
		end if;
	end if;
end process;
   -- output signals
    video_on<=rgb_enable;
    p_tick <= pixel_tick;
    pixel_x <= conv_std_logic_vector(h_pos,10);
    pixel_y <= conv_std_logic_vector(v_pos,10);
end Behavioral;
