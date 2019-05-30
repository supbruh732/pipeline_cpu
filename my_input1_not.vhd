LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY my_input1_not is
	--GENERIC	(unit_delay :   TIME    := 2ns);   -- unit delay per input
	   PORT (	x: 	IN		STD_LOGIC;
			    z:	OUT		STD_LOGIC);
END ENTITY my_input1_not;

ARCHITECTURE behv_not1 OF my_input1_not IS
	
Begin

	z <= not(x);-- after 1 * unit_delay;
	
END ARCHITECTURE behv_not1;

