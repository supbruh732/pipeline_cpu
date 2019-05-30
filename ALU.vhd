Library IEEE;
use IEEE.STD_LOGIC_1164.all;


entity ALU is
	generic (size: integer := 16);           -- default size
   port 
   (X, Y: in std_logic_vector (size-1 downto 0);
      
	  rca_enable, cla_enable, booth_enable, arr_mul_enable, compar_enable: in std_logic;
	  
	  ---inputs for booth_mul
	  start_booth: in std_logic;
	  clk: in std_logic;
	  reset: in std_logic;	  
	  done_booth: out std_logic;
	  
	  Z: out std_logic_vector (size-1 downto 0);
       overflow, cout_add: out std_logic;
       flag_neg, flag_zero, flag_greater, flag_less, flag_eq: out std_logic);
end ALU;

architecture struct_ALU of ALU is

component my_inputn_rca is

 
port( X , Y: in std_logic_vector((size-1) downto 0) ; 
         r_cin: in std_logic;
         r_sum: out std_logic_vector((size-1) downto 0);
         r_cout: out std_logic;
		 r_cout2: out std_logic);
end component;

component my_inputn_cla is
generic (      size : integer := 16 );
 
port( X , Y: in std_logic_vector((size-1) downto 0) ; 
         cin: in std_logic;
         sum: out std_logic_vector((size-1) downto 0);
		cout_2: out std_logic;
        cout: out std_logic);
end component;

component my_inputn_signed_arr_mul is
generic ( size : integer := 16);
port( X , Y: in std_logic_vector((size-1) downto 0) ; 
         P: out std_logic_vector((2*size)-1 downto 0);
		 overflow: out std_logic);
end component;


component my_booth is

generic (size: integer := 16);
   port (X, Y: in std_logic_vector(size-1 downto 0);
         clk, start_booth, reset: in std_logic;
		 op: out std_logic_vector(2*size - 1 downto 0);
		 op16: out std_logic_vector(size-1 downto 0);
		 done_booth, overflow: out std_logic);

end component;

component compar_signed is
	generic (size:integer:= 16 );            -- default size
   port (A,B:in std_logic_vector(size-1 downto 0); 
        flag:out std_logic_vector(1 downto 0));
end component;

component trisbuffer is

GENERIC	(	n  :	Integer	:= 16); --input size
PORT ( 	Signal_In	: 	IN		STD_LOGIC_VECTOR(n-1 downto 0);
		Enable		:	IN		STD_LOGIC;
		Signal_Out	:	OUT		STD_LOGIC_VECTOR(n-1 downto 0));
end component;
		
component trisbuffer_1b is

PORT ( 	Signal_In	: 	IN		STD_LOGIC;
		Enable		:	IN		STD_LOGIC;
		Signal_Out	:	OUT		STD_LOGIC);
end component;
		
component my_inputn_nor is
	GENERIC	(size: integer := 16);   -- unit delay per input
	   PORT (X: 	IN		STD_LOGIC_vector(size-1 downto 0);
			  Z:	OUT		STD_LOGIC);
end component;

component my_input2_xor is
	
	   PORT (x, y: 	IN		STD_LOGIC;
			    z:	OUT		STD_LOGIC);
end component;

component my_input2_xnor is
	   -- unit delay per input
	   PORT (x, y: 	IN		STD_LOGIC;
			    z:	OUT		STD_LOGIC);
end component;

component my_input2_nor is
	   -- unit delay per input
	   PORT (x, y: 	IN		STD_LOGIC;
			    z:	OUT		STD_LOGIC);
end component;

component my_input1_not is
		   -- unit delay per input
	   PORT (	x: 	IN		STD_LOGIC;
			    z:	OUT		STD_LOGIC);
end component;


-------------------

component CLA_P2 is
generic( N : INTEGER := 16;     --SIZE 2^E = (N)
 	 E : INTEGER := 4);     --EXPONENT part -> 2^(E) = N
port( a : in std_logic_vector( N-1 downto 0) ;
      b : in std_logic_vector( N-1 downto 0) ;
     cin: in std_logic ;
	S: out std_logic_vector(N-1 downto 0);
	OVR: out std_logic; -- for 2's comp
	cout: out std_logic); -- ovr for unsigned
end component CLA_P2;




signal temp_rca_cout1, temp_rca_cout2, temp_cla_cout1, temp_cla_cout2: std_logic;
signal arr_mul_out32, booth_out32: std_logic_vector(2*size - 1 downto 0);
signal rca_out, cla_out, arr_mul_out, booth_out, temp_Z: std_logic_vector(size-1 downto 0);
signal compar_out : std_logic_vector(1 downto 0);

signal rca_overflow, cla_overflow, arr_overflow, booth_overflow, temp_overflow: std_logic;

signal temp_rca_inputX, temp_rca_inputY, temp_cla_inputX, temp_cla_inputY, temp_arr_inputX, temp_arr_inputY, temp_booth_inputX, temp_booth_inputY, temp_comp_inputX, temp_comp_inputY: std_logic_vector(size-1 downto 0);

begin

----------

---INPUT TRISBUFFER-------

Buffer_inputx_rca_func: trisbuffer
		generic map ( size)
			port map (X, rca_enable,temp_rca_inputX);
Buffer_inputy_rca_func: trisbuffer
		generic map ( size)
			port map (Y, rca_enable, temp_rca_inputY);
			
Buffer_inputx_cla_func: trisbuffer
		generic map ( size)
			port map (X, cla_enable,temp_cla_inputX);
Buffer_inputy_cla_func: trisbuffer
		generic map ( size)
			port map (Y, cla_enable, temp_cla_inputY);

Buffer_inputx_arr_func: trisbuffer
		generic map ( size)
			port map (X, arr_mul_enable,temp_arr_inputX);
Buffer_inputy_arr_func: trisbuffer
		generic map ( size)
			port map (Y, arr_mul_enable, temp_arr_inputY);

Buffer_inputx_booth_func: trisbuffer
		generic map ( size)
			port map (X, booth_enable,temp_booth_inputX);
Buffer_inputy_booth_func: trisbuffer
		generic map ( size)
			port map (Y, booth_enable, temp_booth_inputY);

Buffer_inputx_comp_func: trisbuffer
		generic map ( size)
			port map (X, compar_enable,temp_comp_inputX);
Buffer_inputy_comp_func: trisbuffer
		generic map ( size)
			port map (Y, compar_enable, temp_comp_inputY);
-----------
----FUs------
RCA_func: my_inputn_rca  -- 
	generic map ( size)
		port map (temp_rca_inputX, temp_rca_inputY, '0', rca_out, temp_rca_cout2, temp_rca_cout1);
--CLA_func: my_inputn_cla
--	generic map ( size)
--		port map (temp_cla_inputX, temp_cla_inputY, '0', cla_out, temp_cla_cout2, temp_cla_cout1);

------ MOSES CLA ---------
CLA_MOSES : CLA_P2
	port map( temp_cla_inputX, temp_cla_inputY, '0', cla_out, temp_cla_cout2, temp_cla_cout1 );
------ --------- ---------

arr_mul_func: my_inputn_signed_arr_mul
		generic map ( size)
			port map (temp_arr_inputX, temp_arr_inputY, arr_mul_out32, arr_overflow);
			
arr_mul_out <= arr_mul_out32(size-1 downto 0);
			
booth_func: my_booth 
		generic map ( size)
		port map (temp_booth_inputX, temp_booth_inputY, clk, start_booth, reset, booth_out32, booth_out, done_booth, booth_overflow);

Compar_func: compar_signed
		generic map (size)
			port map (temp_comp_inputX, temp_comp_inputY, compar_out);

RCA_overflow_func: my_input2_xor
		
			port map (temp_rca_cout1, temp_rca_cout2, rca_overflow);
CLA_overflow_func: my_input2_xor
		
			port map (temp_cla_cout1, temp_cla_cout2, cla_overflow);
			
			---------overflow---------
Buffer1_overflow_rca_func: trisbuffer_1b
		
			port map (rca_overflow, rca_enable,temp_overflow);
			
Buffer1_overflow_cla_func: trisbuffer_1b
		
			port map (cla_overflow, cla_enable, temp_overflow);
			
Buffer1_overflow_arr_func: trisbuffer_1b
		
			port map (arr_overflow, arr_mul_enable, temp_overflow);
			
Buffer1_overflow_booth_func: trisbuffer_1b
		
			port map (booth_overflow, booth_enable, temp_overflow);

overflow <= temp_overflow;
-------cout----------

Buffer1_cout_rca_func: trisbuffer_1b
		
			port map (temp_rca_cout1, rca_enable, cout_add);
			
Buffer1_cout_cla_func: trisbuffer_1b
		
			port map (temp_cla_cout1, cla_enable, cout_add);



------------------zero and negative flag-----------
-------------connect each one to the buffer then, connect each buffer to the output bus-------


---output Z----------
Buffer1_out_rca_func: trisbuffer
		generic map ( size)
			port map (rca_out, rca_enable, temp_Z);
			
Buffer1_out_cla_func: trisbuffer
		generic map ( size)
			port map (cla_out, cla_enable, temp_Z);

Buffer1_out_booth_func: trisbuffer
		generic map ( size)
			port map (booth_out, booth_enable, temp_Z);
			
Buffer1_overflow_arr_mul_func: trisbuffer
		generic map ( size)
			port map (arr_mul_out, arr_mul_enable, temp_Z);

Z <= temp_Z;

---zero flag:
N_input_NOR_func: my_inputn_nor
		generic map ( size)
			port map (temp_Z, flag_zero);

flag_neg_func: my_input2_xnor
		
			port map (temp_Z(size-1), temp_overflow, flag_neg); 
----flag < > = ---------------------------------------------------------

less_flag_func: my_input2_nor
		
				port map (compar_out(1), compar_out(0), flag_less);

flag_greater <= compar_out(1);
flag_eq <= compar_out(0);


end architecture struct_ALU;
