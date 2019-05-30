LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;


ENTITY trisbuffer_1b is
--GENERIC	(	unit_delay	:	TIME	:= 2ns); --input size
PORT ( 	Signal_In	: 	IN		STD_LOGIC;
		Enable		:	IN		STD_LOGIC;
		Signal_Out	:	OUT		STD_LOGIC);
END ENTITY trisbuffer_1b;

ARCHITECTURE T1b OF trisbuffer_1b IS

BEGIN

PROCESS (Signal_In, Enable)
	VARIABLE temp	:	STD_LOGIC;
	
BEGIN
		If (Enable = '1') Then
			temp := Signal_In;
		Else
			temp := 'Z';
		End If;
	Signal_Out <= temp;-- after unit_delay*2;	
		
END PROCESS;

END ARCHITECTURE T1b;