LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY my_input2_or is
	--GENERIC	(unit_delay :   TIME    := 2ns);   -- unit delay per input
	   PORT (x, y: 	IN		STD_LOGIC;
			    z:	OUT		STD_LOGIC);
END ENTITY my_input2_or;

ARCHITECTURE behv_or2 OF my_input2_or IS
	
Begin

	z <= x or y;-- after 2 * unit_delay;
	
END ARCHITECTURE behv_or2;

