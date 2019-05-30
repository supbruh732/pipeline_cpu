library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity my_mfa is
--generic (unit_delay: Time := 2ns);
port ( x , y , cin : in STD_LOGIC;
           s, p, g : out STD_LOGIC);

end entity my_mfa;

architecture struct_mfa of my_mfa is

component my_input2_and is
	--GENERIC	(unit_delay :   TIME    := 2ns);   -- unit delay per input
	   PORT (x, y: 	IN		STD_LOGIC;
			    z:	OUT		STD_LOGIC);
end component;

component my_input2_xor is
   --GENERIC	(unit_delay :   TIME    := 2ns);   -- unit delay per input
	   PORT (x, y: 	IN		STD_LOGIC;
			    z:	OUT		STD_LOGIC);
end component;

signal temp_p, temp_g: STD_LOGIC;

begin

xor_1: my_input2_xor --generic map (unit_delay) 
port map ( x, y, temp_p);
xor_2: my_input2_xor --generic map (unit_delay) 
port map ( temp_p, cin, s);
and_1: my_input2_and --generic map (unit_delay) 
port map ( x, y, temp_g);

p <= temp_p;
g <= temp_g;

end architecture struct_mfa;
  