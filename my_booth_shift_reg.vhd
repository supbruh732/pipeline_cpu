Library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity my_booth_shift_reg is
generic (--unit_delay: time := 2ns;
		--	t_hold : time := 2ns;
		--	set_up : time := 2ns;
			size: integer := 16);
   port (seq_in,shift,reset,load,clk:in std_logic;
   par_in:in std_logic_vector(size-1 downto 0);         
        op:out std_logic_vector(size-1 downto 0);
		seq_out:out std_logic);
end my_booth_shift_reg;

architecture struct_my_booth_sr of my_booth_shift_reg is


component my_input2_and is
  --generic (unit_delay : Time := 4 ns);            
   port(x,y:in std_logic;
        z:out std_logic);
end component;

component my_input2_or is
 -- generic (unit_delay : Time := 4 ns);            
   port(x,y:in std_logic;
        z:out std_logic);
end component;

component my_input1_not is
 -- generic (unit_delay : Time := 2 ns);            
   port(x:in std_logic;
        z:out std_logic);
end component;

component my_dff is
 -- generic (unit_delay : Time := 12 ps;
			--	t_hold: Time := 4 ps;
			--	set_up: Time := 4 ps);            
   port(d:in std_logic;
		  clk:in std_logic;
		  enable:in std_logic;
		  reset:in std_logic;
		  q:out std_logic		  
        );
end component;

component mux is
--generic (unit_delay: time:= 2ns);
   port (a0,a1:in std_logic;
           sel:in std_logic;
            op:out std_logic);
end component;

signal d_in,temp_op:std_logic_vector(size-1 downto 0);
signal sel,enable:std_logic;
begin
sel<=load;
or1: my_input2_or
	  --generic map(unit_delay)
	  port map(load,shift,enable);
dff0: my_dff
		--generic map(unit_delay, t_hold, set_up)
		port map(d_in(size-1), clk,enable,reset,temp_op(size-1));
mux0: mux
        --generic map (unit_delay)
		port map(seq_in,par_in(size-1),sel,d_in(size-1));

G0: for i in 0 to size-2 generate
				dffs: my_dff
						--generic map(unit_delay, t_hold, set_up)
						port map(d_in(i), clk,enable,reset,temp_op(i));
				muxes: mux
					--generic map (unit_delay)
						port map(temp_op(i+1),par_in(i),sel,d_in(i));
seq_out<=temp_op(0);
op<=temp_op;
end generate G0;

end architecture struct_my_booth_sr;