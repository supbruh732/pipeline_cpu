Library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity compar_1b is
--generic (unit_delay: time := 2ns);
   port (a,b:in std_logic;         
        flag:out std_logic_vector(1 downto 0));
end compar_1b;

architecture struct_compar_1b of compar_1b is

component my_input2_and is
 -- generic (unit_delay : Time := 2 ns);            -- default delay
   port(x,y:in std_logic;
        z:out std_logic);
end component;

component my_input2_xor is
 -- generic (unit_delay : Time := 2 ns);            -- default delay
   port(x,y:in std_logic;
        z:out std_logic);
end component;

component my_input1_not is
  --generic (unit_delay : Time := 2 ns);            -- default delay
   port(x:in std_logic;
        z:out std_logic);
end component;

signal not_b:std_logic;
signal a_xor_b:std_logic;


begin

not1: my_input1_not --generic map (unit_delay)
		port map(b,not_b);
and1: my_input2_and --generic map (unit_delay)
		port map(not_b,a,flag(1));		
xor1: my_input2_xor --generic map (unit_delay)
		port map(a,b,a_xor_b);		
not2: my_input1_not --generic map (unit_delay)
		port map(a_xor_b,flag(0));
			 
end architecture struct_compar_1b;
