Library IEEE;
use IEEE.STD_LOGIC_1164.all;


entity my_and is
  generic (gate_delay : Time := 2 ps);            -- default delay
   port(x,y:in STD_LOGIC;
        z:out STD_LOGIC);
end entity my_and;

architecture behav_delay of my_and is

begin
   z<= '1' after gate_delay when x='1' and y='1' else
       '0' after gate_delay;
end architecture behav_delay;