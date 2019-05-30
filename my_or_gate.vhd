Library IEEE;

use IEEE.STD_LOGIC_1164.all;

entity my_or is
  generic (gate_delay : Time := 2 ns);            -- default delay
   port(x,y:in STD_LOGIC;
        z:out STD_LOGIC);
end entity my_or;

architecture behav_delay of my_or is

begin
   z<= '0' after gate_delay when x='0' and y='0' else
       '1' after gate_delay;
end architecture behav_delay;