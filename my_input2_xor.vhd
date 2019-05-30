LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY my_input2_xor is
	--GENERIC	(unit_delay :   TIME    := 2ns);   -- unit delay per input
	   PORT (x, y: 	IN		STD_LOGIC;
			    z:	OUT		STD_LOGIC);
END ENTITY my_input2_xor;

ARCHITECTURE behv_xor2 OF my_input2_xor IS
	
Begin

	z <= x xor y;-- after 3 * unit_delay;
	
END ARCHITECTURE behv_xor2;

