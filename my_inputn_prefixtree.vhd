library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity my_inputn_prefixtree is
generic ( --unit_delay : Time := 2ns;   
          size : integer := 16);
 
port( g_in , p_in: in std_logic_vector((size-1) downto 0) ; 
      g_out, p_out: out std_logic_vector( (size-1) downto 0));
end entity my_inputn_prefixtree; 

architecture struct_rec_prefixtree of my_inputn_prefixtree is
	

component my_inputn_prefixtree is
	generic (--unit_delay : Time := 2ns;   
					size: integer);
	   port ( g_in , p_in: in std_logic_vector((size-1) downto 0) ; 
			 g_out, p_out: out std_logic_vector( (size-1) downto 0));	
end component;
	  
	  
component my_bang is
 port ( g1, p1, g0, p0: in STD_LOGIC;
          g, p: out STD_LOGIC);
end component;

signal sub_g, sub_p, temp_g, temp_p: std_logic_vector( (size-1) downto 0);


begin



G0: if (size = 2) generate
	
	begin
	sub_g(0) <= g_in(0);
	sub_p(0) <= p_in(0);
	Bang_0: my_bang --generic map (unit_delay) 
	port map (g_in(1), p_in(1), g_in(0), p_in(0) ,sub_g(1), sub_p(1));
	
	g_out <= sub_g;
	p_out <= sub_p;
	
end generate G0;

G1: if (size > 2) generate
	begin
	Left_subtree: my_inputn_prefixtree generic map (size/2) -- (unit_delay, size/2) 
	                                port map (g_in(size-1 downto size/2), p_in(size-1 downto size/2), 
										sub_g(size-1 downto size/2), sub_p(size-1 downto size/2));
	right_subtree: my_inputn_prefixtree generic map (size/2) --(unit_delay, size/2)
	                                port map (g_in( (size/2)-1 downto 0), p_in( (size/2)-1 downto 0),
										sub_g( (size/2)-1 downto 0), sub_p( (size/2)-1 downto 0));
	
	stitch_up: for i in size-1 downto size/2 generate
				stitch_bang: my_bang
				port map(sub_g(i), sub_p(i), sub_g(size/2-1), sub_p(size/2-1), temp_g(i), temp_p(i));
	end generate stitch_up;
	
	g_out(size/2-1 downto 0) <= sub_g(size/2-1 downto 0);
	g_out(size-1 downto size/2) <= temp_g(size-1 downto size/2);
	p_out(size/2-1 downto 0) <= sub_p(size/2-1 downto 0);
	p_out(size-1 downto size/2) <= temp_p(size-1 downto size/2);
	
end generate G1;

end architecture struct_rec_prefixtree; 


