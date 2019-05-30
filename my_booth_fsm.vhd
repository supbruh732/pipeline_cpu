Library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity my_booth_fsm is
--generic (unit_delay: time := 2 ns;
	--		t_hold: time :=  4 ns;
		--	set_up: time := 4 ns);
   port (start_flag,q0,reset,clk:in std_logic;
		 done_booth,load_AC_Y,load_AC,Cin,shift,x_0:out std_logic);
end my_booth_fsm;

architecture behavioral of my_booth_fsm is
component my_booth_downcounter is
--generic (unit_delay: time := 2 ns;
		--	t_hold: time :=  4 ns;
			--set_up: time := 4 ns);
   port (clk,set:in std_logic;
        Q:out std_logic_vector(3 downto 0));
end component;

TYPE states is (idle,start,test0,operate,shifting,test,load);
signal present_state:states:=idle;
signal next_state:states:=idle;
signal counter:std_logic_vector(3 downto 0);
signal shift_inner,initialize,q_1_reg:std_logic;

begin
	
	DFF: PROCESS (reset, clk)
		
		begin
		if(reset='0') then
			present_state<= idle;-- after 12 ps;
		elsif (rising_edge(clk)) THEN -- (clk'event and clk = '1' and clk'last_value = '0') THEN
			present_state<= next_state;-- after 12 ps;
		end if;
	end process DFF;
	
	counter1: my_booth_downcounter
				--generic map (unit_delay, t_hold, set_up)
					port map(shift_inner,initialize,counter);
					
	q1: process(shift_inner,initialize)
				begin
				if initialize = '0' then
					q_1_reg<='0';
				elsif (rising_edge(shift_inner)) THEN --(shift_inner'event and shift_inner = '1' and shift_inner'last_value = '0') THEN
					q_1_reg<=q0;
				end if;
	end process q1;
	
	op_logic: process(present_state)
				 begin
				 case present_state is
				 when idle=>
						shift_inner<='0';
						shift<='0';
						done_booth<='1';
						load_AC_Y<='0';
						load_AC<='0';
						Cin<=q0;
						x_0<='0';
						Initialize<='1';
				 when start=> 
						shift_inner<='0';
						shift<='0';
						done_booth<='0';
						load_AC_Y<='1';
						load_AC<='0';
						Cin<=q0;
						x_0<='0';
						Initialize<='0';
				 when test0=> 
						shift_inner<='0';
						shift<='0';
						done_booth<='0';
						load_AC_Y<='0';
						load_AC<='0';
						Cin<=q0;
						x_0<=q0 xor q_1_reg;
						Initialize<='1';
				when operate=> 
						shift_inner<='0';
						shift<='0';
						done_booth<='0';
						load_AC_Y<='0';
						load_AC<='0';
						Cin<=q0;
						x_0<=q0 xor q_1_reg;
						Initialize<='1';
				when shifting=> 
						shift_inner<='1';
						shift<='1';
						done_booth<='0';
						load_AC_Y<='0';
						load_AC<='0';
						Cin<=q0;
						x_0<=q0 xor q_1_reg;
						Initialize<='1';
				when test=> 
						shift_inner<='0';
						shift<='0';
						done_booth<='0';
						load_AC_Y<='0';
						load_AC<='0';
						Cin<=q0;
						x_0<=q0 xor q_1_reg;
						Initialize<='1';
				when load=>
						shift_inner<='0';
						shift<='0';
						done_booth<='0';
						load_AC_Y<='0';
						load_AC<='1';
						Cin<=q0;
						x_0<=q0 xor q_1_reg;
						Initialize<='1';
				end case;
	end process op_logic;
	
	NS_logic: process(q0,start_flag,present_state,counter) is
				begin
				case present_state is
				when idle=>
						if start_flag = '1' then
							next_state<=start;
						else
							next_state<=idle;
						end if;
				 when start=> 
						next_state<=test0;
				 when test0=> 
						if q0 = '1' then
							next_state<=operate;
						else 
							next_state<=shifting;
						end if;
				when operate=> 
						next_state<=load;
				when load=> 
						next_state<=shifting;
				when shifting=> 
						next_state<=test;
				when test=> 
						if counter(0) = '0' and counter(1) = '0' and counter(2) = '0' and counter(3) = '0' then
							next_state<=idle;
						elsif q0 = '0' and q_1_reg = '1' then
								next_state<=operate;
						elsif q0 = '1' and q_1_reg = '0' then
								next_state<=operate;
						elsif q0 = '1' and q_1_reg = '1' then
								next_state<=shifting;
						elsif q0 = '0' and q_1_reg = '0' then
								next_state<=shifting;
						end if;
				end case;
	end process NS_logic;
end architecture behavioral;