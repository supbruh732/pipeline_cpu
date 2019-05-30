Library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity mux2b is
--generic (unit_delay: time := 2 ns);
   port (A,B:in std_logic_vector(1 downto 0);
                           sel:in std_logic;         
        op:out std_logic_vector(1 downto 0));
end mux2b;

architecture struct_mux2b of mux2b is


component mux is
--generic (unit_delay : Time := 2 ns);
port(a0:in std_logic;      --A
     a1:in std_logic;      --B
	  sel: in std_logic;
	  op: out std_logic);
end component;

begin

m0: mux --generic map (unit_delay) 
port map (A(0), B(0), sel, op(0));
m1: mux --generic map (unit_delay) 
port map (A(1), B(1), sel, op(1));
	
end architecture struct_mux2b;