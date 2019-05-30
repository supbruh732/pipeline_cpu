Library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity my_booth_data_path is
	generic (--unit_delay: time := 2ns;
			--	t_hold: time := 2ns;
			--	set_up: time := 2ns;
	              size: integer := 16);
	port (clk, shift, load_AC, load_AC_Y, cin, reset, x_0: in std_logic;
	X, Y: in std_logic_vector(size-1 downto 0);
	q0: out std_logic;
	op: out std_logic_vector(2*size - 1 downto 0);
	done_booth: in std_logic;
	overflow: out std_logic;
	op16: out std_logic_vector(size-1 downto 0));	
end my_booth_data_path;

architecture struct_my_bdp of my_booth_data_path is

component my_booth_shift_reg is
generic (--unit_delay: time := 2ns;
			--t_hold : time := 2ns;
		--	set_up : time := 2ns;
			size: integer);
   port (seq_in,shift,reset,load,clk:in std_logic;
   par_in:in std_logic_vector(size-1 downto 0);         
        op:out std_logic_vector(size-1 downto 0);
		seq_out:out std_logic);
end component;

component my_inputn_cla is
generic (-- unit_delay : Time := 2ns;   
          size : integer);
port( X , Y: in std_logic_vector((size-1) downto 0) ; 
         cin: in std_logic;
         sum: out std_logic_vector((size-1) downto 0);
		cout_2: out std_logic;
        cout: out std_logic);	
end component;

component my_input2_xor is
  --generic (unit_delay : Time := 4 ns);            
   port(x,y:in std_logic;
        z:out std_logic);
end component;

component my_input2_and is
  --generic (unit_delay : Time := 4 ns);            
   port(x,y:in std_logic;
        z:out std_logic);
end component;

component my_input2_or is
  --generic (unit_delay : Time := 4 ns);            
   port(x,y:in std_logic;
        z:out std_logic);
end component;

component my_input1_not is
  --generic (unit_delay : Time := 2 ns);            
   port(x:in std_logic;
        z:out std_logic);
end component;

component my_dff is
  --generic (unit_delay : Time := 12 ps;
				--t_hold: Time := 4 ps;
				--set_up: Time := 4 ps);            
   port(d:in std_logic;
		  clk:in std_logic;
		  enable:in std_logic;
		  reset:in std_logic;
		  q:out std_logic		  
        );
end component;

component mux is
-- (unit_delay: time:= 2ns);
   port (a0,a1:in std_logic;
           sel:in std_logic;
            op:out std_logic);
end component;


signal Addition,AC_op,Q_op,M_op,temp_M_q0,CLA_in:std_logic_vector(size-1 downto 0);
signal temp_Addition: std_logic_vector(size downto 0);
signal Cout,cout_1, cout_2, clear_AC,AC2Q,Q_junk,M_junk,noverfl,temp_Cout:std_logic;
signal gnd:std_logic:='0';
signal temp_overfl,temp_xor:std_logic_vector(size-1 downto 0);
begin
q0 <= Q_op(0);
not1: my_input1_not
		--generic map(unit_delay)
		port map(load_AC_Y,clear_AC);
AC: my_booth_shift_reg
	generic map(size)--(unit_delay, t_hold, set_up, size)
	   port map(Cout,shift,clear_AC,load_AC,clk,Addition,         
        AC_op,AC2Q);
Q:  my_booth_shift_reg
	generic map (size)--(unit_delay, t_hold, set_up, size)
	 port map(AC2Q,shift,reset,load_AC_Y,clk, X,         
        Q_op,Q_junk);
M:  my_booth_shift_reg
	generic map(size)-- (unit_delay, t_hold, set_up, size)
	 port map(gnd,gnd,reset,load_AC_Y,clk, Y,         
        M_op,M_junk);
loop1: for i in 0 to size-1 generate
			ands: my_input2_and
					--generic map(unit_delay)
					port map(x_0,M_op(i),temp_M_q0(i));
			xors: my_input2_xor
					--generic map(unit_delay)
					port map(temp_M_q0(i),Cin,CLA_in(i));
end generate loop1;

CLA1: my_inputn_cla
			generic map(size)--(unit_delay, size)
			port map(AC_op,CLA_in,Cin,temp_Addition(size-1 downto 0),cout_2, temp_Addition(size));
xor2: my_input2_xor
      --generic map(unit_delay)
	port map(temp_Addition(size),temp_Addition(size-1),noverfl);
mux1: mux
	--generic map(unit_delay)
	   port map(temp_Addition(size),temp_Addition(size-1),noverfl,     
        temp_Cout);
dff_Cout: my_dff
	 -- generic map(unit_delay, t_hold, set_up)
	  port map(temp_Cout,
		  clk,
		  load_AC,
		  clear_AC,
		  Cout);
Addition<=temp_Addition(size-1 downto 0);
--op(31 downto 16)<=AC_op;
--op(15 downto 0 )<=Q_op;
--loop3: for i in 31 downto 16 generate
--	and1s: my_and
--		generic map(4 ps)
--		port map(AC_op(i-16),done_booth,op(i));
--	and2s: my_and
--		generic map(4 ps)
--		port map(Q_op(i-16),done_booth,op(i-16));
--end generate loop3;
or1: my_input2_or
	--generic map(unit_delay)
	port map(temp_xor(size-2),temp_xor(size-3),temp_overfl(size-3));
loop4: for i in size-2 downto 0 generate
	xors: my_input2_xor
		--generic map(unit_delay)
		port map(AC_op(size-1),AC_op(i),temp_xor(i));
end generate loop4;
loop2: for i in size-4 downto 0 generate
	ors: my_input2_or
		--generic map(unit_delay)
		port map(temp_overfl(i+1),temp_xor(i),temp_overfl(i));
end generate loop2;
loop3: for i in 2*size-1 downto size generate
	dff1s: my_dff
	 --generic map(unit_delay, t_hold, set_up)            
   		port map(AC_op(i-size),
		  done_booth,
		  '1',
		  reset,
		  op(i));
	dff2s: my_dff
	 --generic map(unit_delay, t_hold, set_up)            
   		port map(Q_op(i-size),
		  done_booth,
		  '1',
		  reset,
		  op(i-size));
END generate;
loop5: for i in size-2 downto 0 generate
	dff3s: my_dff
	 --generic map(unit_delay, t_hold, set_up)            
   		port map(Q_op(i),
		  done_booth,
		  '1',
		  reset,
		  op16(i));
	
END generate;
dff4: my_dff
	 --generic map(unit_delay, t_hold, set_up)  
   		port map(AC_op(size-1),
		  done_booth,
		  '1',
		  reset,
		  op16(size-1));
and1: my_input2_and
	--generic map(unit_delay)
	port map(temp_overfl(0),done_booth,overflow);
			
end architecture struct_my_bdp;