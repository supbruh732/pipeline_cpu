library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity my_halfadder is
--generic (unit_delay: Time := 2ns);
port ( x , y: in STD_LOGIC;
       sum , cout : out STD_LOGIC);

end entity my_halfadder;

architecture struct_ha of my_halfadder is

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

begin

xor_1: my_input2_xor --generic map (unit_delay) 
port map ( x, y , sum);

and_1: my_input2_and --generic map (unit_delay) 
port map ( x, y, cout);

end architecture struct_ha;
  