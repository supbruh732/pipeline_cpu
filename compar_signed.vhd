Library IEEE;
use IEEE.STD_LOGIC_1164.all;


entity compar_signed is
	generic (size:integer:= 16);
	         --unit_delay : time := 2 ns);            -- default size
   port (A,B:in std_logic_vector(size-1 downto 0); 
        flag:out std_logic_vector(1 downto 0));
	
end compar_signed;

architecture struct_signed of compar_signed is

component compar_unsigned is
	generic (size:integer);
	         --unit_delay : time := 2 ns);            -- default size
   port (A,B:in std_logic_vector(size-1 downto 0); 
        flag:out std_logic_vector(1 downto 0));
end component;

signal wire_a, wire_b: std_logic_vector(size-1 downto 0);

begin

wire_a <= B(size-1) & A(size-2 downto 0);
wire_b <= A(size-1) & B(size-2 downto 0);

G0: compar_unsigned generic map (size) --, unit_delay) 
port map (wire_a, wire_b, flag);

end architecture struct_signed;

