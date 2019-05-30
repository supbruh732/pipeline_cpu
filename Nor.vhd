Library IEEE;
use IEEE.STD_LOGIC_1164.all;


entity my_nor4e is
  generic (gate_delay : Time := 10 ps);            -- default delay
   port(X3,X2, X1, X0:in STD_LOGIC;
        EN: in std_logic;
        z:out STD_LOGIC);
end entity my_nor4e;

architecture behav_delay of my_nor4e is

begin
   z<= '1' after gate_delay when x0='0' and x1='0' and x2='0' and x3 ='0' and EN = '1' else
       '0' after gate_delay;
end architecture behav_delay;