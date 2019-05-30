LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY my_input2_and is
	--GENERIC	(unit_delay :   TIME    := 2ns);   -- unit delay per input
	   PORT (x, y: 	IN		STD_LOGIC;
			    z:	OUT		STD_LOGIC);
END ENTITY my_input2_and;

ARCHITECTURE behv_and2 OF my_input2_and IS
	
Begin

	z <= x and y;-- after 2 * unit_delay;
	
END ARCHITECTURE behv_and2;

