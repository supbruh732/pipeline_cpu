LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY my_inputn_nor is
	GENERIC	(--unit_delay :   TIME    := 2ns;
				size: integer := 16);   -- unit delay per input
	   PORT (X: 	IN		STD_LOGIC_vector(size-1 downto 0);
			  Z:	OUT		STD_LOGIC);
END ENTITY my_inputn_nor;

ARCHITECTURE struct_rec OF my_inputn_nor IS
	

component my_input2_nor is
	--GENERIC	(unit_delay :   TIME    := 2ns);   -- unit delay per input
	   PORT (x, y: 	IN		STD_LOGIC;
			    z:	OUT		STD_LOGIC);
end component;

component my_input2_and is
	--GENERIC	(unit_delay :   TIME    := 2ns);   -- unit delay per input
	   PORT (x, y: 	IN		STD_LOGIC;
			    z:	OUT		STD_LOGIC);
end component;

component my_inputn_nor is
	GENERIC	(--unit_delay :   TIME    := 2ns;
				size: integer);   -- unit delay per input
	   PORT (X: 	IN		STD_LOGIC_vector(size-1 downto 0);
			  Z:	OUT		STD_LOGIC);
end component;


signal right_result, left_result: std_logic;

Begin

G0: if size = 2 generate
	leaf: my_input2_nor
			--generic map (unit_delay)
				port map (X(0), X(1), z);
end generate G0;

G1: if size > 2  generate
	left: my_inputn_nor
			generic map (size/2)--(unit_delay, size/2)
				port map (X(size-1 downto (size/2)), left_result);
	right: my_inputn_nor
			generic map (size/2)--(unit_delay, size/2)
				port map (X((size/2)-1 downto 0), right_result);
	stitch_up: my_input2_and
			--generic map (unit_delay)
				port map (left_result, right_result, z);
end generate G1;
END ARCHITECTURE struct_rec;

