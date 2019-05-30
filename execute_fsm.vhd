
Library IEEE;
use IEEE.std_logic_1164.all;


entity execute_fsm is
  port( newD : in std_logic;
	reset : in std_logic;
	clk : in std_logic;
	speed : in std_logic;

     -- Decode IR
	ird : in std_logic_vector(15 downto 0);

     -- From Write Back
	doneW : in std_logic;

     -- From ALU
	doneBooth : in std_logic;
	
     -- Inter Unit Signals
   alu_sel : out std_logic_vector(4 downto 0);
	newE : out std_logic;
	doneE : out std_logic;
	startBooth : out std_logic;

	PCW_en : out std_logic;
	IRW_en : out std_logic;
	alu_reg_en : out std_logic;
	aux_reg_en : out std_logic; 
	flag_en : out std_logic );
	
end entity execute_fsm;
	

architecture behav of execute_fsm is


  component N_counter is
    generic( E : integer := 4); -- exponent of N

    port ( en : in std_logic;
           clk : in std_logic;
           q : out std_logic_vector( E - 1 downto 0);
           RST : in std_logic := '0';
           status : out std_logic);
  end component N_counter;


  component SYNC_CNTR is
    port ( en : in std_logic;
           clk : in std_logic;
           q: out std_logic_vector( 3 downto 0 );
           RST: in std_logic := '0'); 
  end component SYNC_CNTR;


  type states is ( Idle, Select_Op, Evaluate, Compare, Memory, Branch );
  signal curr_state : states := Idle;
  signal next_state : states := Idle;

  signal en_rca, en_cla, en_arr, en_bm : std_logic := '0';
  signal opcode : std_logic_vector(3 downto 0);

  signal q1, q2, q3, q4 : std_logic_vector(3 downto 0) ;
  signal status : std_logic_vector(3 downto 0);
  signal en_gen: std_logic := '0'; -- added general counter
  signal g_rst: std_logic := '0';  -- added general counter
  signal rst_count : std_logic := '0';
  signal rst : std_logic;
  signal q_gen: std_logic_vector(3 downto 0); -- gen counter q 
  signal test: std_logic := '0';
  
  constant fast : std_logic_vector(4 downto 0) := "00001";
  constant slow_a : std_logic_vector(4 downto 0) := "00010";
  constant fast_dt : std_logic_vector(3 downto 0) := "0001";
  constant slow_dt_a : std_logic_vector(3 downto 0) := "0011";
  constant fast_dt_m : std_logic_vector(3 downto 0) := "0011";
  
  -- signal delay_op_a : std_logic_vector(4 downto 0);
  -- signal delay_op_m : std_logic_vector(4 downto 0);
    
  
  constant period : time := 12 ps;


begin

  opcode <= ird(15 downto 12);

  rst <= reset or ( rst_count and (not en_rca) ); 

  RCA : SYNC_CNTR port map( en_rca, clk, q1, rst );
  CLA : SYNC_CNTR port map( en_cla, clk, q2, rst ); 
  ARRAY_MULT : SYNC_CNTR port map( en_arr, clk, q3, rst );
  BM : SYNC_CNTR port map( en_bm, clk, q3, rst );
  GEN_CNTR: SYNC_CNTR port map( en_gen, clk, q_gen, g_rst);


  CLK_E : process( clk, reset )
    begin
      if( reset = '1' ) then
		  curr_state <= Idle;
      elsif( (clk'EVENT) and (clk = '1') and (clk'LAST_VALUE = '0') ) then
		  curr_state <= next_state;
      end if;
  end process CLK_E;



---------------- STATE CHANGE LOGIC ----------------
  STATE_CHANGE : process( curr_state, newD, doneW, opcode, doneBooth, q1, rst_count, test )
    begin
      next_state <= curr_state;

      case( curr_state ) is
      -------IDLE STATE-------
			when Idle =>
			  rst_count <= '1';
			  if( newD = '1' and doneW = '1') then
				 next_state <= Select_OP;
			  else
				 next_state <= Idle;
			  end if;

		-------SELECT_OP STATE-------
			when Select_OP =>
		--	  if( doneW = '1' ) then
				 if( (opcode >= "0000") and (opcode < "0101") ) then
						next_state <= Evaluate;
						elsif( opcode = "1101" ) then
							next_state <= Evaluate;
				 elsif( opcode = "0101" ) then
					next_state <= Compare;
				 elsif( (opcode > "1011") ) then
					next_state <= Memory;
				 elsif( (opcode > "0101") and (opcode < "1100") ) then
					next_state <= Branch;
		--	    end if;
			  else
					--next_state <= Select_Op;
					next_state <= idle;
			  end if;

		-------EVALUATE STATE-------
			when Evaluate =>
			  -- rst_count <= '0';
			  -- en_rca <= '1';
			  -- if( ((opcode = "0000") AND (q_gen = "0100"))
			  --    OR ((opcode = "0001") AND (q_gen = "1000"))
			  --    OR ((opcode = "0010") AND (g_gen = "1010"))
			  --    OR ((opcode = "0011") AND (g_gen = "1100"))
			  --    OR ((opcode = "0100") AND (doneBooth = '1')) ) then
					  --en_rca <= '0';
			  -- end if;
			  
				if (test = '1') then
				  next_state <= Idle;
				else
				  next_state <= Evaluate;
				end if;

		-------COMPARE STATE-------
			when Compare => next_state <= Idle;
			 -- if( newD = '1' ) then  -- AND CHECK THE FU WAITS??
			 --   next_state <= Idle;
			 -- else
			 --   next_state <= Compare;
			 -- end if;

		-------MEMORY STATE-------
			when Memory =>
			  -- if( opcode = "1110" ) then
			  --   next_state <= Store;
			  -- elsif( not(opcode = "1110") ) then
			  --   next_state <= Evaluate;
			  -- else
			  --   next_state <= Select_OP;
			  -- end if;
			  
				if (test = '1') then
				  next_state <= Idle;
				else
				  next_state <= Memory;
				end if;

		-------BRANCH STATE-------
			when Branch =>
				if (test = '1') then
				  next_state <= Idle;
				else
				  next_state <= Branch;
				end if;
			--  next_state <= Idle;
	
      end case;
  end process STATE_CHANGE;


---------------- OUTPUT LOGIC ----------------

  OUTPUT : process( curr_state, q_gen, doneW, speed )
    begin
      case( curr_state ) is
      -------IDLE STATE-------
	when Idle =>
     alu_sel <= "00000";
	  newE <= '0';
	 if ( doneW = '1') then
		doneE <= '1';
		else 
		doneE <= '0';
	end if;
	  startBooth <= '0';

	  --PCW_en <= '0';
	  --IRW_en <= '0';
	  alu_reg_en <= '0';
	  aux_reg_en <= '0';
	  flag_en <= '0';
	  en_gen  <= '0';
	  g_rst <= '1';
		test <= '0';
		PCW_en <= '1';
		IRW_en <= '1';

      -------SELECT_OP STATE-------
	when Select_OP =>
    alu_sel <= "00000";
	  newE <= '0';
	  doneE <= '0';
	  startBooth <= '0';
--	if ( doneW = '1') then
--		PCW_en <= '1';
--		IRW_en <= '1';
--	else 
--		PCW_en <= '0';
--		IRW_en <= '0';
--	end if; 
   --  if( doneW = '1' ) then
	 --   PCW_en <= '0';
	 --   IRW_en <= '0';  -- this is causing PC to get overwritten without use
	--  else
	 --   PCW_en <= '1';
	--	 IRW_en <= '1';
	 -- end if;
	  
	  alu_reg_en <= '0';
	  aux_reg_en <= '0';
	  flag_en <= '0';
	  -- en_gen  <= '0';
	  -- g_rst <= '1';
	  --test <= '0'; doesnt matter
		
      -------EVALUATE STATE-------
	when Evaluate =>
	
	  -- if( opcode = "0000" ) then alu_sel <= fast after 20 ps;
	  --   elsif( opcode = "0001") then alu_sel <= slow after 20 ps;
	  --   elsif( opcode = "0010") then alu_sel <= "00001" after 20 ps;
	  --	 elsif( opcode = "0011") then alu_sel <= "01000" after 20 ps;
	  --   elsif( opcode = "1101") then alu_sel <= "00001" after 20 ps;
	  --   elsif( opcode = "0100") then alu_sel <= "00100"; startBooth <= '1' after 20 ps;
	  -- end if;
		
		if( speed = '1' ) then
		  if( (opcode = "0000") OR (opcode = "0001") OR (opcode = "0010") OR (opcode = "1101" ) ) then
		    alu_sel <= slow_a after 20 ps;
		  elsif( (opcode = "0100") OR (opcode = "0011") ) then
			 startBooth <= '1' after 20 ps;
			 alu_sel <= "00100" after 20 ps;
			 -- wait for 50 ps;
		  -- else
		  --   alu_sel <= "01000" after 20 ps;
		  end if;
		else
		  if( (opcode = "0000") OR (opcode = "0001") OR (opcode = "0010") OR (opcode = "1101" ) ) then
		    alu_sel <= "00001" after 20 ps;
		  elsif( (opcode = "0100") OR (opcode = "0011") ) then
		    alu_sel <= "01000" after 20 ps;
			 -- startBooth <= '1' after 20 ps;
		  -- else
		  --   alu_sel <= "01000" after 20 ps;
		  end if;
		end if;
		
		g_rst <= '0'; 
		en_gen <= '1';
	  --alu_reg_en <= '1' after 50 ps;
	  
	  -- if( ((opcode = "0000") AND (q_gen = fast_dt))
	  --     OR ((opcode = "0001") AND (q_gen = slow_dt))
     --     OR ((opcode = "0010") AND (q_gen = fast_dt))
	  --     OR ((opcode = "1101") AND (q_gen = "0001"))
	  --     OR ((opcode = "0011") AND (q_gen = "1100"))
	  --     OR ((opcode = "0100") AND (doneBooth = '1')) ) then
	  --       alu_reg_en <= '1';
	  --       test <= '1';
	  --       PCW_en <= '0';
	  --       IRW_en <= '0';
	  --       newE <= '1';
	  --       doneE <= '0';
	  -- else
	  --   alu_reg_en <= '0';
	  -- end if;
	  
	  if( speed = '1' ) then
	    if( (((opcode = "0000") OR (opcode = "0001") OR (opcode = "0010") OR (opcode = "1101" ))
																			  AND ( q_gen = slow_dt_a ))
			   OR (( (opcode = "0100") or (opcode = "0011") ) AND (doneBooth = '1') AND q_gen > "0010") ) then
				    alu_reg_en <= '1';
					 test <= '1';
					 newE <= '1';
		  else
		    alu_reg_en <= '0';
		  end if;
	  else
	    if( (((opcode = "0000") OR (opcode = "0001") OR (opcode = "0010") OR (opcode = "1101" ))
																			  AND ( q_gen = "0001" ))
			   OR (( (opcode = "0100") or (opcode = "0011") ) AND (q_gen = "0011")) ) then
				    alu_reg_en <= '1';
					 test <= '1';
					 newE <= '1';
		  else
		    alu_reg_en <= '0';
		  end if;
	  end if;
	  
	  PCW_en <= '0';
	  IRW_en <= '0';
	  aux_reg_en <= '0';   
	  flag_en <= '0';

      -------COMPARE STATE-------
	when Compare =>
     alu_sel <= "10000";
	  newE <= '0';
	  doneE <= '1';
	  startBooth <= '0';

	  PCW_en <= '0';
	  IRW_en <= '0';
	  alu_reg_en <= '0';
	  aux_reg_en <= '0';
	  flag_en <= '1';

      -------MEMORY STATE-------
	when Memory =>
     if( speed = '0' ) then
	    alu_sel <= fast;
	  else
	    alu_sel <= slow_a;
	  end if;
	  -- alu_sel <= "00001";
	  
	 
	 -- doneE <= '1';
	  startBooth <= '0';

	  if( ((q_gen = fast_dt) AND (speed = '0'))
			 OR ((q_gen = slow_dt_a) AND (speed = '1')) ) then
	    if( opcode = "1110" ) then
		   aux_reg_en <= '1';
			alu_reg_en <= '1';
			doneE <= '1';
			newE <= '1';
			PCW_en <= '0';
			IRW_en <= '0';
		 else
		   aux_reg_en <= '0';
			alu_reg_en <= '1';
		 end if;
		 test <= '1';
	  else
	    alu_reg_en <= '0';
		 aux_reg_en <= '0';
	  end if;
	  
	  g_rst <= '0'; 
	  en_gen <= '1';

	  --PCW_en <= '1';
	  --IRW_en <= '1';
	  -- alu_reg_en <= '1';
	  -- aux_reg_en <= '0';
	  flag_en <= '0';

      -------BRANCH STATE-------
	when Branch =>
     if( speed = '0' ) then
	    alu_sel <= fast;
	  else
	    alu_sel <= slow_a;
	  end if;
		 
	  newE <= '1';
	  doneE <= '1';
	  startBooth <= '0';

	  if( ((q_gen = fast_dt) AND (speed = '0'))
			 OR ((q_gen = slow_dt_a) AND (speed = '1')) ) then
	    alu_reg_en <= '1';
		 test <= '1';
	  else
	    alu_reg_en <= '0';
	  end if;

	  g_rst <= '0'; 
	  en_gen <= '1';
		
	  PCW_en <= '0';
	  IRW_en <= '0';
	  -- alu_reg_en <= '0';
	  aux_reg_en <= '0';
	  flag_en <= '0';

      end case; 
  end process OUTPUT;


end architecture;
