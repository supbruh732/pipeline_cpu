Library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity my_booth is
generic (--unit_delay: time := 2ns;
			--t_hold: time := 2ns;
			--set_up: time := 2ns;
			size: integer := 16);
   port (X, Y: in std_logic_vector(size-1 downto 0);
         clk, start_booth, reset: in std_logic;
		 op: out std_logic_vector(2*size - 1 downto 0);
		 op16: out std_logic_vector(size-1 downto 0);
		 done_booth, overflow: out std_logic);
end my_booth;

architecture struct_my_booth of my_booth is

component my_booth_fsm is
--generic (unit_delay: time := 2 ns;
			--t_hold: time :=  4 ns;
			--set_up: time := 4 ns);
port (start_flag, q0, reset, clk: in std_logic;
      done_booth, load_AC_Y, load_AC, cin, shift, x_0: out std_logic);
end component;

component my_booth_data_path is
	generic (--unit_delay: time := 2ns;
			--	t_hold: time := 2ns;
				--set_up: time := 2ns;
	              size: integer);
	port (clk, shift, load_AC, load_AC_Y, cin, reset, x_0: in std_logic;
	X, Y: in std_logic_vector(size-1 downto 0);
	q0: out std_logic;
	op: out std_logic_vector(2*size - 1 downto 0);
	done_booth: in std_logic;
	overflow: out std_logic;
	op16: out std_logic_vector(size-1 downto 0));	
end component;

signal q0, load_AC_Y, load_AC, cin, shift, x_0, done: std_logic;

begin

fsm_func: my_booth_fsm-- generic map (unit_delay, t_hold, set_up)
					port map (start_booth, q0, reset, clk, done, load_AC_Y, load_AC, cin, shift, x_0);
data_path_func: my_booth_data_path generic map(size)--(unit_delay, t_hold, set_up, size)
							port map (clk, shift, load_AC, load_AC_Y, cin, reset, x_0, X, Y, q0, op, done, overflow, op16);

done_booth <= done;

end architecture struct_my_booth;
