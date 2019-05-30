LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;


ENTITY trisbuffer is
GENERIC	(--	unit_delay	:	TIME	:= 2ns;
			size  :	INTEGER	:= 16); --input size
PORT ( 	Signal_In	: 	IN		STD_LOGIC_VECTOR(size-1 downto 0);
		Enable		:	IN		STD_LOGIC;
		Signal_Out	:	OUT		STD_LOGIC_VECTOR(size-1 downto 0));
END ENTITY trisbuffer;

ARCHITECTURE T1 OF trisbuffer IS

BEGIN

PROCESS (Signal_In, Enable)
	VARIABLE temp	:	STD_LOGIC_VECTOR(size-1 downto 0);
	
BEGIN
	FOR	i in size-1 downto 0 LOOP
		If (Enable = '1') Then
			temp(i) := Signal_In(i);
		Else
			temp(i) := 'Z';
		End If;
	End LOOP;
	Signal_Out <= temp;-- after unit_delay*2;	
		
END PROCESS;

END ARCHITECTURE T1;