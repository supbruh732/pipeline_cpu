
Library IEEE;
use IEEE.std_logic_1164.all;

entity fetch_fsm is
  port( start : in std_logic;
    	reset : in std_logic;
	   clk : in std_logic;
	
	ir : in std_logic_vector(15 downto 0);
	
     -- from Memory Unit
	newM : in std_logic;
		
     -- from Write Unit
	branchW : in std_logic;		
	loadW : in std_logic;
	storeW : in std_logic;
	
     -- from Decode Unit	
	doneD : in std_logic;	
    
     -- Inter Unit signals
	read_mem : out std_logic;
	write_mem : out std_logic;
  	okw : out std_logic;		-- "okay to write to memory" (to write unit)
	newFW : out std_logic;		-- fetch signal to write to say new instructions aquired
	newF : out std_logic;		-- to Decode Unit
	doneF : out std_logic;

     -- Reg Control Signals
	IR_en : out std_logic;
	IRD_en : out std_logic;
	PC_conn : out std_logic;
	PC_sel : out std_logic;
	PC_clk : out std_logic;
	PC_ld : out std_logic;
	MAR_conn : out std_logic;
	MDR_conn : out std_logic;
	MDR_en : out std_logic;
	MDR_sel_F : out std_logic;
 	newF_en : out std_logic;
	newFW_en : out std_logic );

end entity fetch_fsm;


architecture behav of fetch_fsm is

  component SYNC_CNTR is
    port ( en : in std_logic;
           clk : in std_logic;
           q: out std_logic_vector( 3 downto 0 );
           RST: in std_logic := '0'); 
  end component SYNC_CNTR;
  

  type states is ( Idle, Init, Ops, Load, Store, Store2, Branch, Branch_Check, FRead, FWrite, STR_SP,STR_2, Bubble );
  signal curr_state : states := Idle;
  signal next_state : states := Idle;
  
  signal en_cnt, rst_cnt : std_logic;
  
  signal opcode, q_cnt : std_logic_vector(3 downto 0);
  


begin

  opcode <= ir(15 downto 12);

  GEN_CNTR: SYNC_CNTR port map( en_cnt, clk, q_cnt, rst_cnt);

  CLK_F : process( clk, reset )
    begin
      if( reset = '1' ) then
	curr_state <= idle;
      elsif( (clk'EVENT) and (clk = '1') and (clk'LAST_VALUE = '0') ) then
  	curr_state <= next_state;
      end if;
  end process CLK_F;


  STATE_CHANGE : process( curr_state, start, newM, loadW, storeW, branchW, opcode, q_cnt, doneD )
    begin
      next_state <= curr_state;

      case( curr_state ) is
      -------IDLE STATE-------
   ---     when Idle =>
	 --- if( start = '1' and newM = '1' ) then
	 ---   next_state <= Ops;
	 --- elsif( start = '1' ) then
	 ---   next_state <= Init;
   ---       else
	 ---   next_state <= Idle;
	 --- end if;
	 
	 when Idle =>
	 if( start = '1' ) then
		 next_state <= Init;
	 else
		 next_state <= Idle;
	 end if;

	
      -------INIT STATE-------
	when Init =>
	  if( newM = '1' ) then
	    next_state <= Ops ;
	  else
	    next_state <= Init;
	  end if;

      -------OPS STATE-------
	when Ops =>
		If (storeW = '1') then 
		next_state <= Store;
	else
			if( (opcode > "0101") and (opcode < "1100") ) then -- used to be >= but that included cmp
				if( doneD = '1' ) then
					next_state <= Branch_Check;
				else
					next_state <= Ops;
				end if;
			else
				if( doneD = '1' ) then
					if( loadW = '1' ) then
						next_state <= Load;
					elsif( storeW = '1' ) then
						next_state <= Store;
					elsif( branchW = '1' ) then
						next_state <= Branch;
					elsif( (loadW = '0') and (storeW = '0') and (branchW = '0') ) then
						next_state <= Init;
					end if;
				else
					next_state <= Ops;
				end if;
			end if;
		end if;

      -------LOAD STATE-------
	when Load =>
	  next_state <= FRead;
	
      -------STORE STATE-------
	when Store =>
	  next_state <= Store2;
		--next_state <= FWrite; -- added just for quick delay 
	when Store2 =>
		next_state <= FWrite;
	
      -------FREAD STATE-------
	when FRead =>
	  next_state <= Bubble;

      -------FWRITE STATE-------
 	when FWrite =>
	  if( newM = '1' ) then
	    if( loadW = '1' ) then
	      next_state <= Load;
  	    elsif( branchW = '1' ) then
	      next_state <= Branch;
	    elsif( storeW = '1' and doneD = '0' ) then
	      next_state <= Store;
	    elsif( (loadW = '0') and (storeW = '0') and (branchW = '0') ) then
	      next_state <= Init;
	    end if;
	  else
			-- next_state <= FWrite;
			next_state <= init;
	  end if;

      -------BRANCH STATE-------
 	when Branch =>
		next_state <= Init;
		
		---------SPECIAL STATE----------
		when STR_SP =>
		next_state <= STR_2;
		
		when STR_2 =>
		next_state <= Branch_CHECK;
		
      -------BRANCH_CHECK STATE-------
	when Branch_CHECK =>

	if (StoreW = '1') then
		next_state <= STR_SP;
		else 

	  if( q_cnt <= "0010" and doneD = '1' ) then
	    next_state <= Idle;
	  elsif( q_cnt > "0010" and doneD = '0' ) then
	    next_state <= Branch_Check;
	  elsif( branchW = '1' ) then
	    next_state <= Branch;
	  else
	    next_state <= Branch_Check;
	  end if;
			end if;
	  -- if( branchW = '1' ) then
	  --   next_state <= Branch;
	  -- else
	  --   next_state <= Branch_Taken;
	  -- end if;

      -------BUBBLE STATE-------
	when Bubble =>
	  if( newM = '1' ) then
	    next_state <= Init;
	  else
	    next_state <= Bubble;
	  end if;

      end case;
  end process STATE_CHANGE;



  OUTPUT : process( curr_state, DoneD, newM, rst_cnt, en_cnt, storeW )
    begin
      case( curr_state ) is
      -------IDLE STATE-------
	when Idle =>
	  read_mem <= '0';
       	  write_mem <= '0';
  	  okw <= '0';		
	  newFW <= '0';		
	  newF <= '0';	
	  doneF <= '0';	

       -- Reg Control Signals
	  IR_en <= '0';
	  IRD_en <= '0';
	  PC_conn <= '0';
	  PC_sel <= '0';
	  PC_clk <= '0';
	  PC_ld <= '0';
	  MAR_conn <= '0';
	  MDR_conn <= '0';
	  MDR_en <= 'Z';
	  MDR_sel_F <= 'Z';
 	  newF_en <= '0';
	  newFW_en <= '0';

      -------INIT STATE-------
	when Init =>
	  read_mem <= '1';
     	  write_mem <= '0';
  	  okw <= '0';		
	  newFW <= '0';		
	  newF <= '0'; --signal was 0 
	  doneF <= '1' after 20 ps;		

       -- Reg Control Signals
	  
	  if( newM = '1' ) then
				IR_en <= '1';
	
	  else
	    IR_en <= '0';
	  end if;
	  
	  IRD_en <= '0';
	  PC_conn <= '1';
	  PC_sel <= '0';
	  PC_clk <= '0';
	  PC_ld <= '0';
	  MAR_conn <= '0';
	  MDR_conn <= '0';
	  MDR_en <= 'Z';
	  MDR_sel_F <= 'Z';
 	  newF_en <= '0';
	  newFW_en <= '0';
	  rst_cnt <= '1';
	  en_cnt <= '0';

      -------OPS STATE-------
	when Ops =>
	  read_mem <= '0';
          write_mem <= '0';
  	  okw <= '0';		
	  -- newFW <= '1';		
	  newF <= '1' ; --signal was 0 
	  doneF <= '0';		

       -- Reg Control Signals
	  IR_en <= '0';
	  
	  if (DoneD = '1') then  -- ADDED THIS BC IRD was getting overwritten w/o decoder ack
	    newFW <= '0';
		 IRD_en <= '1';
	  else 
		 newFW <= '0';
		 IRD_en <= '0';
	  end if;
	  
	  PC_conn <= '0';
	  PC_sel <= '0';
	  PC_clk <= '1';
	  PC_ld <= '1';
	  MAR_conn <= '0';
	  MDR_conn <= '0';
	  MDR_en <= 'Z';
	  MDR_sel_F <= 'Z';
 	  newF_en <= '0';
	  newFW_en <= '0';
	  rst_cnt <= '0';
	  en_cnt <= '0';	  

      -------LOAD STATE-------
	when Load =>
	  read_mem <= '1';
       	  write_mem <= '0';
  	  okw <= '1';		
	  newFW <= '0';		
	  newF <= '0';
	  doneF <= '0';		

       -- Reg Control Signals
	  IR_en <= '0';
	  IRD_en <= '0';
	  PC_conn <= '0';
	  PC_sel <= '0';
	  PC_clk <= '0';
	  PC_ld <= '0';
	  MAR_conn <= '1';
	  MDR_conn <= '0';
	  MDR_en <= '1';
	  MDR_sel_F <= '0';
 	  newF_en <= '0';
	  newFW_en <= '0';

      -------STORE STATE-------
	when Store =>
	  read_mem <= '0';
       	  write_mem <= '1';
  	  okw <= '0';		
	  newFW <= 'Z';		
	  newF <= '0';
	  doneF <= '0';		

       -- Reg Control Signals
	  IR_en <= '0';
	  IRD_en <= '0';
	  PC_conn <= '0';
	  PC_sel <= '0';
	  PC_clk <= '0';
	  PC_ld <= '0';
	  MAR_conn <= '1';
	  MDR_conn <= '1';
	  MDR_en <= 'Z';
	  MDR_sel_F <= 'Z';
 	  newF_en <= '0';
		newFW_en <= '0';
					
		      -------STORE STATE2-------
	when Store2 =>
	read_mem <= '0';
				 write_mem <= '0';
		okw <= '0';		
	newFW <= '0';		
	newF <= '0';
	doneF <= '0';		

		 -- Reg Control Signals
	IR_en <= '0';
	IRD_en <= '0';
	PC_conn <= '0';
	PC_sel <= '0';
	PC_clk <= '0';
	PC_ld <= '0';
	MAR_conn <= '1';
	MDR_conn <= '1';
	MDR_en <= 'Z';
	MDR_sel_F <= 'Z';
	 newF_en <= '0';
				newFW_en <= '0';
		
		      -------SPECIAL STORE STATE-------
	when STR_SP =>
	read_mem <= '0';
				 write_mem <= '1' ;
--		okw <= '1';		
	--newFW <= '1';		
	--newF <= '1';
	doneF <= '1';		

		 -- Reg Control Signals
	IR_en <= '0';
	IRD_en <= '0';
	PC_conn <= '0';
	PC_sel <= '0';
	PC_clk <= '0';
	PC_ld <= '0';
	MAR_conn <= '1' ;
	MDR_conn <= '1' ;
	MDR_en <= 'Z';
	MDR_sel_F <= 'Z';
	 newF_en <= '0';
	newFW_en <= '0';
			      -------SPECIAL STORE STATE-------
						when STR_2 =>
						read_mem <= '0';
									 write_mem <= '1'  after 1 ps;
							okw <= '1';		
						newFW <= '1';		
						newF <= '1';
						doneF <= '1';		
					
							 -- Reg Control Signals
						IR_en <= '0';
						IRD_en <= '0';
						PC_conn <= '0';
						PC_sel <= '0';
						PC_clk <= '0';
						PC_ld <= '0';
						MAR_conn <= '1' ;
						MDR_conn <= '1' ;
						MDR_en <= 'Z';
						MDR_sel_F <= 'Z';
						 newF_en <= '0';
						newFW_en <= '0';

      -------FREAD STATE-------
	when FRead =>
	  read_mem <= '0';
          write_mem <= '0';
  	  okw <= '0';		
	  newFW <= '0';		
	  newF <= '0';
	  doneF <= '0';		

       -- Reg Control Signals
	  IR_en <= '0';
	  IRD_en <= '0';
	  PC_conn <= '0';
	  PC_sel <= '0';
	  PC_clk <= '0';
	  PC_ld <= '0';
	  MAR_conn <= '1';
	  MDR_conn <= '0';
	  MDR_en <= '1';
	  MDR_sel_F <= '1';
 	  newF_en <= '0';
	  newFW_en <= '1';

      -------Bubble STATE-------	  
	when Bubble =>
	  read_mem <= '0';
          write_mem <= '0';
  	  okw <= '0';		
	  newFW <= '1';		
	  newF <= '0';
	  doneF <= '0';		

       -- Reg Control Signals
	  IR_en <= '0';
	  IRD_en <= '0';
	  PC_conn <= '0';
	  PC_sel <= '0';
	  PC_clk <= '0';
	  PC_ld <= '0';
	  MAR_conn <= '0';
	  MDR_conn <= '0';
	  MDR_en <= 'Z';
	  MDR_sel_F <= 'Z';
 	  newF_en <= '0';
	  newFW_en <= '0';

      -------FWRITE STATE-------
	when FWrite =>
	  read_mem <= '0';
     write_mem <= '0';
  	  okw <= '1';		
	  newFW <= '0';		
	  newF <= '0';	
	  doneF <= '0';	

       -- Reg Control Signals
	  IR_en <= '0';
	  IRD_en <= '0';
	  PC_conn <= '0';
	  PC_sel <= '0';
	  PC_clk <= '0';
	  PC_ld <= '0';
	  MAR_conn <= '0';
	  MDR_conn <= '0';
	  MDR_en <= 'Z';
	  MDR_sel_F <= 'Z';
 	  newF_en <= '0';
	  newFW_en <= '0';

      -------BRANCH STATE-------
	when Branch =>
	  read_mem <= '0';
     write_mem <= '0';
  	  okw <= '1';		
	  newFW <= '1';		
	  newF <= '0';	
	  doneF <= '0';	

       -- Reg Control Signals
	  IR_en <= '0';
	  IRD_en <= '0';
	  PC_conn <= '1';
	  PC_sel <= '1';
	  PC_clk <= '1' after 12 ps;
	  PC_ld <= '1';
	  MAR_conn <= '0';
	  MDR_conn <= '0';
	  MDR_en <= 'Z';
	  MDR_sel_F <= 'Z';
 	  newF_en <= '0';
	  newFW_en <= '0';

      -------BRANCH_CHECK STATE-------
	when Branch_Check =>
	  read_mem <= '0';
          write_mem <= '0';
  	  okw <= '0';		
	  newFW <= '0';		
	  newF <= '0';	
	  doneF <= '0';	

       -- Reg Control Signals
	  IR_en <= '0';
	  IRD_en <= '0';
		PC_conn <= '0';
		if( branchW = '1' ) then
	    PC_sel <= '1';
		else
			PC_sel <= '0';
		end if;
		
		PC_clk <= '0';
	  PC_ld <= '0';
	  MAR_conn <= '0';
	  MDR_conn <= '0';
	  MDR_en <= 'Z';
	  MDR_sel_F <= 'Z';
 	  newF_en <= '0';
	  newFW_en <= '0';
	  rst_cnt <= '0';
	  en_cnt <= '1';

      end case;
  end process OUTPUT;


end architecture behav;
    