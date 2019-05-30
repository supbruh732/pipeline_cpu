Library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity MFA is
Port( a, b, cin : in std_logic;
	s, P, G: out std_logic);
end entity MFA;

architecture MFA_struct of MFA is 

component my_xor is
  generic (gate_delay : Time := 3 ps);            -- default delay
   port(x,y:in std_logic;
        z:out std_logic);
end component;

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

signal  X1_O : std_logic;

begin 

XOR1: my_xor port map(a,b,X1_O);
XOR2: my_xor port map(X1_O, cin, s);
P <= X1_O;
AND1: my_and port map(a,b,G);


end architecture MFA_struct;