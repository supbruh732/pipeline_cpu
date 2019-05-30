Library IEEE;
use IEEE.STD_LOGIC_1164.all;



entity Bang is
Port( P1, G1, P0 ,G0 : in std_logic ;
	xP, xG : out std_logic);
end entity Bang;

architecture Bang_struct of Bang is 


component my_and is
  generic (gate_delay : Time := 2 ps);            -- default delay
   port(x,y:in std_logic;
        z:out std_logic);
end component;

component my_or is
  generic (gate_delay : Time := 2 ps);            -- default delay
   port(x,y:in std_logic;
        z:out std_logic);
end component;

signal A2_Out : std_logic;

begin 

AND1: my_and port map(P0,P1,xP);
AND2: my_and port map(G0,P1,A2_Out);
OR1: my_or port map(A2_Out, G1, xG);


end architecture Bang_struct;