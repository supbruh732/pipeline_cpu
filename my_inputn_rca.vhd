library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity my_inputn_rca is
generic ( --unit_delay : Time := 2ns;   
          size : integer := 16);
 
port( X , Y: in std_logic_vector((size-1) downto 0) ; 
         r_cin: in std_logic;
         r_sum: out std_logic_vector((size-1) downto 0);
         r_cout: out std_logic;
		 r_cout2: out std_logic);
end entity my_inputn_rca; 

architecture struct_rca of my_inputn_rca is

component my_fulladder is
   --generic (unit_delay: Time := 2ns);
	  port ( x , y , cin : in STD_LOGIC;
           sum , cout : out STD_LOGIC);
end component;

signal temp_cout_arr: std_logic_vector(size-2 downto 0);

begin
   --G2 MSB
   --G1 MID
   --G0 LSB
   G2: my_fulladder --generic map (unit_delay) 
   port map (X(size-1), Y(size-1), temp_cout_arr(size-2), r_sum(size-1), r_cout);
   G1: for i in (size-2) downto 1 generate
			MID_fulladder_i: my_fulladder --generic map (unit_delay) 
			port map (X(i), Y(i), temp_cout_arr(i-1), r_sum(i), temp_cout_arr(i));
   end generate G1;
   G0: my_fulladder --generic map (unit_delay) 
   port map (X(0), Y(0), r_cin, r_sum(0), temp_cout_arr(0));
   
   r_cout2 <= temp_cout_arr(size-2);
   
end architecture struct_rca; 


