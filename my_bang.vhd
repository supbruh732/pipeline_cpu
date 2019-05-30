library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity my_bang is
--generic (unit_delay: Time := 2ns);
port ( g1, p1, g0, p0: in STD_LOGIC;
          g, p: out STD_LOGIC);

end entity my_bang;

architecture struct_bang of my_bang is

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

signal pg: STD_LOGIC;

begin

propgate_and: my_input2_and --generic map (unit_delay) 
port map (p0, p1, p);
       and_1: my_input2_and --generic map (unit_delay) 
	   port map (p1, g0, pg);
	    or_1: my_input2_or  --generic map (unit_delay) 
		port map (g1, pg, g);

end architecture struct_bang;
  