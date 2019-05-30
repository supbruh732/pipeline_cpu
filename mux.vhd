Library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity mux is 
--generic (unit_delay : Time := 2 ns);
port(a0:in std_logic;      --A
     a1:in std_logic;      --B
	  sel: in std_logic;
	  op: out std_logic);
end  mux;

architecture struct of mux is 

component my_input2_and is 
 --generic (unit_delay : Time := 4 ns);            -- default delay
   port(x,y:in std_logic;
        z:out std_logic);
end component;

component my_input2_or is 
--generic(unit_delay : time := 4 ns);
 port(x,y:in std_logic;
      Z:out std_logic);
end component;

component my_input1_not is 
--generic(unit_delay : time := 2 ns);
 port(x:in std_logic;
      Z:out std_logic);
end component;

signal c,temp_ca1,temp_ab,temp_ca0,temp_or1: std_logic;

begin 
  nc: my_input1_not --generic map(unit_delay)
             port map(sel,c);
  ca1: my_input2_and --generic map(unit_delay)
              port map(sel,a1,temp_ca1);
  ab: my_input2_and --generic map(unit_delay)
             port map(a1,a0,temp_ab);
 ca0: my_input2_and --generic map(unit_delay)
             port map(c,a0,temp_ca0);
 or1: my_input2_or --generic map(unit_delay)
            port map(temp_ca0,temp_ab,temp_or1);
 or2: my_input2_or --generic map(unit_delay)
            port map(temp_or1,temp_ca1,op);
end architecture struct;
  
