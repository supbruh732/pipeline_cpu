Library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity my_xor is
  generic (gate_delay : Time := 3 ns);            -- default delay
   port(x,y:in STD_LOGIC;
        z:out STD_LOGIC);
end entity my_xor;

architecture behav_delay of my_xor is

begin
   z<= (not(x) and y) or (x and not(y)) after gate_delay;
end architecture behav_delay;
