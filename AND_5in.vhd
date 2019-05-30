Library IEEE;
use IEEE.STD_LOGIC_1164.all;


entity my_and_5 is
  generic (gate_delay : Time := 6 ns);            -- default delay
   port(X3,X2, X1, X0:in STD_LOGIC;
        EN: in std_logic;
        z:out STD_LOGIC);
end entity my_and_5;

architecture behav_delay of my_and_5 is

begin
   z<= '1' after gate_delay when x0='1' and x1='1' and x2='1' and x3 ='1' and EN = '1' else
       '0' after gate_delay;
end architecture behav_delay;