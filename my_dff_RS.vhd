Library IEEE;
use IEEE.STD_LOGIC_1164.all;


entity my_dff_RS is
 -- generic (unit_delay : Time := 12 ps;
	--			t_hold: Time := 4 ps;
		--		set_up: Time := 4 ps);            -- default delay
   port(d:in std_logic;
		  clk:in std_logic;
		  enable:in std_logic;
		  reset:in std_logic;
		  q:out std_logic;
		  qu:out std_logic;
		  set:in std_logic
        );
end entity my_dff_RS;

architecture behav_delay of my_dff_RS is

begin
	process(reset,clk,set) is
	Begin
	--check for the rising edge clock edge
	
	if (reset = '1') then
		q<= '0';
		qu <= '1';
	elsif (set = '1') then
		q<= '1';
		qu <= '0';
	elsif (rising_edge(clk)) then
		if (enable = '1') then
			q <= d;
			qu <= not d;
		end if;
	end if;
end process;
				
end architecture behav_delay;