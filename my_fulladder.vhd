library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity my_fulladder is
--generic (unit_delay: Time := 2ns);
port ( x , y , cin : in STD_LOGIC;
           sum , cout : out STD_LOGIC);

end entity my_fulladder;

architecture struct_fa of my_fulladder is

component my_input2_and is
	--GENERIC	(unit_delay :   TIME    := 2ns);   -- unit delay per input
	   PORT (x, y: 	IN		STD_LOGIC;
			    z:	OUT		STD_LOGIC);
end component;

component my_input2_or is
   	--GENERIC	(unit_delay :   TIME    := 2ns);   -- unit delay per input
	   PORT (x, y: 	IN		STD_LOGIC;
			    z:	OUT		STD_LOGIC);
end component;

component my_input2_xor is
  --GENERIC	(unit_delay :   TIME    := 2ns);   -- unit delay per input
	   PORT (x, y: 	IN		STD_LOGIC;
			    z:	OUT		STD_LOGIC);
end component;

signal sum_1, carry_1, carry_2 : STD_LOGIC;

begin

xor_1: my_input2_xor --generic map (unit_delay) 
port map ( x, y , sum_1);
xor_2: my_input2_xor --generic map (unit_delay) 
port map ( sum_1, cin, sum);
and_1: my_input2_and --generic map (unit_delay) 
port map ( sum_1, cin, carry_1);
and_2: my_input2_and --generic map (unit_delay) 
port map ( x, y, carry_2);
or_1:  my_input2_or  --generic map (unit_delay) 
port map ( carry_1, carry_2, cout);

end architecture struct_fa;
  