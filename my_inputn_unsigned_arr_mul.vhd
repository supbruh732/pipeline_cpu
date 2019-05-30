library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity my_inputn_unsigned_arr_mul is
generic ( --unit_delay : Time := 2ns;   
          size : integer := 16);
 
port( X , Y: in std_logic_vector((size-1) downto 0) ; 
         P: out std_logic_vector((2*size)-1 downto 0));
end entity my_inputn_unsigned_arr_mul; 

architecture struct_unsigned_arr_mul of my_inputn_unsigned_arr_mul is

type N_arr is array (size-1 downto 0) of std_logic_vector (size-1 downto 0);
type M_arr is array (size-2 downto 0) of std_logic_vector (size-2 downto 0);


component my_fulladder is
   --generic (unit_delay: Time := 2ns);
	  port ( x , y , cin : in STD_LOGIC;
                  sum, cout: out STD_LOGIC);
end component;

component my_input2_and is
   --GENERIC	(unit_delay :   TIME    := 2ns);   -- unit delay per input
	   PORT (x, y: 	IN		STD_LOGIC;
			    z:	OUT		STD_LOGIC);
end component;

component my_halfadder is
   --generic (unit_delay: Time := 2ns);
	  port ( x , y: in STD_LOGIC;
             sum , cout : out STD_LOGIC);
end component;

component my_inputn_cla is
   generic ( --unit_delay : Time := 2ns;   
                   size : integer); 
	port( X , Y: in std_logic_vector((size-1) downto 0) ; 
         cin: in std_logic;
         sum: out std_logic_vector((size-1) downto 0);
		cout_2: out std_logic;
        cout: out std_logic);
end component;


signal arr_inputs : N_arr;
signal arr_s, arr_c : M_arr;

signal x_in, y_in, s_out: std_logic_vector ((size-1) downto 0);
signal c_out, cout_2: std_logic;

begin
-- inputs:
outer: for i in size-1 downto 0 generate
	inner: for j in size-1 downto 0 generate
		and_ij: my_input2_and --generic map (unit_delay) 
		port map (X(i), Y(j), arr_inputs(i)(j));
	end generate inner;
end generate outer;
	
--CSvA
CSvA_1: for i in size-2 downto 0 generate
			ha_i: my_halfadder --generic map (unit_delay) 
			port map (arr_inputs(i)(1), arr_inputs(i+1)(0), arr_s(0)(i), arr_c(0)(i));
end generate CSvA_1;

CSvA_2: for i in 1 to size-2 generate
	MSB_FA: my_fulladder --generic map (unit_delay) 
	port map (arr_inputs(size-2)(i+1), arr_inputs(size-1)(i), arr_c(i-1)(size-2), arr_s(i)(size-2), arr_c(i)(size-2));
	
	CSvA_i: for j in size-3 downto 0 generate
			FA: my_fulladder --generic map (unit_delay) 
			port map (arr_inputs(j)(i+1), arr_s(i-1)(j+1), arr_c(i-1)(j), arr_s(i)(j), arr_c(i)(j));
	end generate CSvA_i;
end generate CSvA_2;

x_in <= '0' & arr_inputs(size-1)(size-1) & arr_s(size-2)(size-2 downto 1);
y_in <= '0' & arr_c(size-2)(size-2 downto 0);

CPA: my_inputn_cla generic map (size) --(unit_delay, size) 
port map (x_in, y_in, '0', s_out, cout_2, c_out);

P(((2*size)-1) downto size) <= s_out(size-1 downto 0);

outputs: for i in size-2 downto 0 generate
			P(i+1) <= arr_s(i)(0);
end generate outputs;
P(0) <= arr_inputs(0)(0);

END architecture struct_unsigned_arr_mul;


