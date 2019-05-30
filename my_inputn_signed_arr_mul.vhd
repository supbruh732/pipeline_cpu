library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity my_inputn_signed_arr_mul is
generic ( --unit_delay : Time := 2ns;   
          size : integer := 16);
port( X , Y: in std_logic_vector((size-1) downto 0) ; 
         P: out std_logic_vector((2*size)-1 downto 0);
		 overflow: out std_logic);
end entity my_inputn_signed_arr_mul; 

architecture struct_signed_arr_mul of my_inputn_signed_arr_mul is

component my_input2_and is
   --GENERIC	(unit_delay :   TIME    := 2ns);   -- unit delay per input
	   PORT (x, y: 	IN		STD_LOGIC;
			    z:	OUT		STD_LOGIC);
end component;

component my_input2_xor is
   --GENERIC	(unit_delay :   TIME    := 2ns);   -- unit delay per input
	   PORT (x, y: 	IN		STD_LOGIC;
			    z:	OUT		STD_LOGIC);
end component;

component my_inputn_rca is
   generic ( --unit_delay : Time := 2ns;   
          size : integer);
port( X , Y: in std_logic_vector((size-1) downto 0) ; 
         r_cin: in std_logic;
         r_sum: out std_logic_vector((size-1) downto 0);
         r_cout: out std_logic);
end component;

component my_halfadder is
   --generic (unit_delay: Time := 2ns);
	  port ( x , y: in STD_LOGIC;
             sum , cout : out STD_LOGIC);
end component;

component my_inputn_unsigned_arr_mul is
generic ( --unit_delay : Time := 2ns;   
          size : integer);
port( X , Y: in std_logic_vector((size-1) downto 0) ; 
         P: out std_logic_vector((2*size)-1 downto 0));
end component;

signal X_1comp, Y_1comp, SB_y_X, SB_x_Y: std_logic_vector(size-1 downto 0);

signal cout_X, cout_Y, temp1, temp2, SBB_x_y, SB_p: std_logic;

signal X_1, Mag_P, Mag_P_1comp, HA_carry: std_logic_vector((2*size)-3 downto 0);

signal Part_P, Over_P: std_logic_vector((2*size)-1 downto 0);

begin

gene_1comp: for i in size-1 downto 0 generate
			X_1comp_func: my_input2_xor --generic map (unit_delay) 
			port map (X(i), X(size-1), X_1comp(i));
			Y_1comp_func: my_input2_xor --generic map (unit_delay) 
			port map (Y(i), Y(size-1), Y_1comp(i));
end generate gene_1comp;

SB_multplication: my_input2_and --generic map (unit_delay) 
port map (X(size-1), Y(size-1), SBB_x_y);

gene_1_multplication: for i in size-1 downto 0 generate
						X_1_mult: my_input2_and --generic map (unit_delay) 
						port map (X_1comp(i), Y(size-1), SB_y_X(i));
						Y_1_mult: my_input2_and --generic map (unit_delay) 
						port map (Y_1comp(i), X(size-1), SB_x_Y(i));
end generate gene_1_multplication;

part_p_func: my_inputn_unsigned_arr_mul generic map (size)--(unit_delay, size) 
port map (X_1comp, Y_1comp, Part_P);

Zero_vec: for i in (2*size)-3 downto size generate
			X_1(i) <= '0';
end generate Zero_vec;

CPA_func: my_inputn_rca generic map (size)--(unit_delay, size) 
port map (SB_y_X, SB_x_Y, SBB_x_y, X_1(size-1 downto 0), temp1);

Mag_CPA_func: my_inputn_rca generic map ((2*size)-2) --(unit_delay, (2*size)-2) 
port map (Part_P((2*size)-3 downto 0), X_1, '0', Mag_P, temp2);

SBP_func: my_input2_xor --generic map (unit_delay) 
port map (X(size-1), Y(size-1), SB_p);

G2: for i in (2*size)-3 downto 0 generate
	xor_gate: my_input2_xor --generic map (unit_delay) 
	port map (Mag_P(i), SB_p, Mag_P_1comp(i));
end generate G2;

HA_func: my_halfadder --generic map (unit_delay) 
port map (Mag_P_1comp(0), SB_p, Over_P(0), HA_carry(0));

G3: for i in (2*size)-3 downto 1 generate
	HA_func_i: my_halfadder -- map (unit_delay) 
	port map (Mag_P_1comp(i), HA_carry(i-1), Over_P(i), HA_carry(i));
end generate G3;

overflow <= HA_carry((2*size)-3);

Over_P((2*size)-2) <= SB_p;
Over_P((2*size)-1) <= Over_P((2*size)-2);
P <= Over_P;

END architecture struct_signed_arr_mul;	


