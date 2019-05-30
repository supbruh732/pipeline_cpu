Library IEEE;
use IEEE.STD_LOGIC_1164.all;


entity compar_unsigned is
	generic (size:integer:= 16);
	         --unit_delay : time := 2 ns);            -- default size
   port (A,B:in std_logic_vector(size-1 downto 0); 
        flag:out std_logic_vector(1 downto 0));
	
end compar_unsigned;

architecture rec_compar_unsigned of compar_unsigned is

signal left_flag: std_logic_vector(1 downto 0);
signal right_flag: std_logic_vector(1 downto 0);

component compar_1b is
--generic (unit_delay: time := 2ns);
   port (a,b:in std_logic;         
        flag:out std_logic_vector(1 downto 0));
end component;

component compar_unsigned is
generic (size:integer);
         --unit_delay: time := 2 ns);            -- default size
   port (A,B:in std_logic_vector(size-1 downto 0);         
        flag:out std_logic_vector(1 downto 0));
end component;

component mux2b is
--generic (unit_delay: time := 2 ns);
   port (A,B:in std_logic_vector(1 downto 0);
                           sel:in std_logic;         
        op:out std_logic_vector(1 downto 0));
end component;

begin

G0: if size = 1 generate
	leaf_function: compar_1b --generic map (unit_delay) 
	port map(A(0),B(0),flag);
end generate G0;

G1: if size > 1 generate      
				
	left_tree: compar_unsigned generic map (size/2)--, unit_delay)
	                           port map (A(size-1 downto size/2), B(size-1 downto size/2), left_flag);
							   
	right_tree: compar_unsigned generic map (size/2)--, unit_delay)
								port map (A(size/2 - 1 downto 0), B(size/2 - 1 downto 0), right_flag);
	
	stitch_up: mux2b --generic map (unit_delay) 
	port map (left_flag, right_flag, left_flag(0), flag);						
end generate G1;
end architecture rec_compar_unsigned;

