library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity my_inputn_cla is
generic ( --unit_delay : Time := 2ns;   
          size : integer := 16);
 
port( X , Y: in std_logic_vector((size-1) downto 0) ; 
         cin: in std_logic;
         sum: out std_logic_vector((size-1) downto 0);
		cout_2: out std_logic;
        cout: out std_logic);
end entity my_inputn_cla; 

architecture struct_cla of my_inputn_cla is

component my_mfa is
  --generic (unit_delay: Time := 2ns);
	  port ( x , y , cin : in STD_LOGIC;
           s, p, g : out STD_LOGIC);
end component;

component my_input2_and is
   --GENERIC	(unit_delay :   TIME    := 2ns);   -- unit delay per input
	   PORT (x, y: 	IN		STD_LOGIC;
			    z:	OUT		STD_LOGIC);
end component;

component my_input2_or is
   --GENERIC	(unit_delay :   TIME    := 2ns);   -- unit delay per input
	   PORT (x, y: 	IN		STD_LOGIC;
			    z:	OUT		STD_LOGIC);
end component;

component my_inputn_prefixtree is
   generic ( --unit_delay : Time := 2ns;   
          size : integer);
	   port( g_in , p_in: in std_logic_vector((size-1) downto 0) ; 
      g_out, p_out: out std_logic_vector( (size-1) downto 0));
end component;


signal temp_cout : std_logic_vector(size-1 downto 0);
signal temp_p, temp_g, p_c, g_c, temp_cin : std_logic_vector(size-1 downto 0);

begin
MFA_LOOP: for i in 1 to size - 1 generate
	MFA_i: my_mfa
	port map(X(i), Y(i), temp_cout(i-1), sum(i), temp_p(i), temp_g(i));
end generate MFA_LOOP;

MFA_lsb: my_mfa
	port map(X(0), Y(0), cin, sum(0), temp_p(0), temp_g(0));


prefix_tree1: my_inputn_prefixtree
	generic map(size)
	port map(temp_g, temp_p, g_c, p_c);
   
   
	G0: for i in (size-1) downto 0 generate

		and_i: my_input2_and --generic map (unit_delay) 
		port map (p_c(i), cin, temp_cin(i));
		
		or_i : my_input2_or  --generic map (unit_delay) 
		port map (g_c(i), temp_cin(i), temp_cout(i));
	end generate G0;
	
	cout <= temp_cout(size-1);
	cout_2 <= temp_cout(size-2);  
end architecture struct_cla; 


