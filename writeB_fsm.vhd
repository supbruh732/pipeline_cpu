
Library IEEE;
use IEEE.std_logic_1164.all;

entity writeB_fsm is
  port( newE : in std_logic;
	reset : in std_logic;
	clk : in std_logic;

     -- Execute IR
	ire : in std_logic_vector(15 downto 0);

     -- From Fetch
	newFW : in std_logic;
	okw : in std_logic;

     -- Inter Unit Signals
	RW_DCD : out std_logic_vector(6 downto 0);
	W_ADDR : out std_logic_vector(3 downto 0);
	FRD_ADDR : out std_logic_vector(3 downto 0);		-- DO WE REALLY NEED IT?? FR-ADDRS = W-ADDRS
	EN_WB_MUX : out std_logic;
  	RF_WRITE_SEL : out std_logic;

	load : out std_logic;
	store : out std_logic;
	branch : out std_logic;
	newW : out std_logic;
	doneW : out std_logic;

	dr_en : out std_logic;
	dr_sel : out std_logic;
	result_sel : out std_logic;
   aluDone : in std_logic;	
	mar_en : out std_logic );
end entity writeB_fsm;


architecture behav of writeB_fsm is

  type states is ( Idle, Write_Sel, ALU_Load, Load_M, Store_M, Branch_M, PC_Write );
  signal curr_state : states := Idle;
  signal next_state : states := Idle;

  signal opcode : std_logic_vector(3 downto 0);
  signal write_reg : std_logic_vector(3 downto 0);

  
begin

  opcode <= ire(15 downto 12);
  write_reg <= ire(11 downto 8);

  CLK_W : process( clk, reset )
    begin
      if( reset = '1' ) then
	curr_state <= Idle;
      elsif( (clk'EVENT) and (clk = '1') and (clk'LAST_VALUE = '0') ) then
  	curr_state <= next_state;
      end if;
  end process CLK_W;


---------------- STATE CHANGE LOGIC ----------------
  STATE_CHANGE : process( curr_state, newE, newFW, okw, opcode, aluDone )
    begin
      next_state <= curr_state;

      case( curr_state ) is
      -------IDLE STATE-------
	when Idle =>
--		if( aluDone = '1' ) then
			if( newE = '1' ) then
	    next_state <= Write_Sel;
	  else
	    next_state <= Idle;
	  end if;
	  
      -------WRITE_SEL STATE-------
	when Write_Sel =>
	    if( opcode >= "0000" and opcode < "0101" ) then
				next_state <= ALU_Load;
			elsif( opcode = "1101" ) then   -- ld imm
				next_state <= ALU_Load;		
       elsif( opcode = "1100" ) then
	      next_state <= Load_M;
	    elsif( opcode = "1110" ) then
	      next_state <= Store_M;
	    elsif( opcode > "0101" and opcode < "1100" ) then
	      next_state <= Branch_M;
       else
	    next_state <= Write_Sel;
	    end if;

      -------ALU_LOAD STATE-------
	when ALU_Load =>
	next_state <= Idle;
	--  if( newE = '1' ) then
	--    next_state <= Idle;
  --        else
	--    next_state <= ALU_Load;
	--  end if;

      -------LOAD STATE-------
	when Load_M =>
	  if( newFW = '1' ) then
	    next_state <= Idle;
	  else
	    next_state <= Load_M;
	  end if;

      -------STORE STATE-------
 	when Store_M =>
	  if( okw = '1' ) then
	    next_state <= Idle;
	  else
	    next_state <= Store_M;
	  end if;

      -------BRANCH STATE-------
	when Branch_M =>
	  if( newFW = '1' ) then
	    next_state <= Idle;
	  else
	    next_state <= Branch_M;
	  end if;

      -------PC_WRITE STATE-------
	when PC_Write =>
	  if( okw = '1' ) then
	    next_state <= Idle;
	  else
	    next_state <= PC_Write;
	  end if;
      end case;
  end process STATE_CHANGE;


---------------- OUTPUT LOGIC ----------------

  OUTPUT : process( curr_state, write_reg, aluDone, okw )
    begin
      case( curr_state ) is 
      -------IDLE STATE-------
	when Idle =>
	  RW_DCD <= "ZZZZZZZ";
	  W_ADDR <= write_reg;
     FRD_ADDR <= write_reg;
	  EN_WB_MUX <= '0';
  	  RF_WRITE_SEL <= '0';
	
	  load <= '0'; 
	  store <= '0'; 
	  branch <= '0'; 
	  newW <= '0';

     -- if( aluDone = '1' ) then	  
	    doneW <= '1'; -- was 0 changed to 1  
     -- else
	  --  doneW <= '0';
	  -- end if;
	  
	  dr_en <= 'Z'; 
	  dr_sel <= 'Z'; 
	  result_sel <= '0';
     mar_en <= 'Z';

      -------WRITE_SEL STATE-------
	when Write_Sel =>
	  RW_DCD <= "ZZZZZZZ";
	  W_ADDR <= write_reg;
     FRD_ADDR <= write_reg;
	  EN_WB_MUX <= '1';
  	  RF_WRITE_SEL <= '0';

	  load <= '0'; 
	  store <= '0'; 
	  branch <= '0'; 
	  newW <= '0'; 
	  doneW <= '0'; --was 1
  
	  dr_en <= 'Z'; 
	  dr_sel <= 'Z'; 
	  result_sel <= '0';
          mar_en <= 'Z';

      -------ALU_LOAD STATE-------
	when ALU_Load =>
	  RW_DCD <= "0010001" after 20 ps;		-- not sure the bits (assumed -- 3rd = write and 6th = reset)
	  W_ADDR <= write_reg;
    FRD_ADDR <= write_reg;
	  EN_WB_MUX <= '1';
  	RF_WRITE_SEL <= '0';			-- 0 => Write from DATA BUS && 1 => Write from MDR

	  load <= '0'; 
	  store <= '0'; 
	  branch <= '0'; 
	  newW <= '0'; 
	  doneW <= '0'; -- was 0 
  
	  dr_en <= 'Z'; 
	  dr_sel <= 'Z'; 
	  result_sel <= '1';
    mar_en <= 'Z';

      -------LOAD_M STATE-------
	when Load_M =>
	  -- RW_DCD <= "ZZZZZZZ";
	  if( okw = '1' ) then
	    RW_DCD <= "0010001" after 12 ps;
	    EN_WB_MUX <= '1';
		 RF_WRITE_SEL <= '1';
	  else
	    RW_DCD <= "ZZZZZZZ";
		 EN_WB_MUX <= '0';
		 RF_WRITE_SEL <= '0';
	  end if;	  

	  W_ADDR <= write_reg;
          FRD_ADDR <= write_reg;
	  -- EN_WB_MUX <= '0';
  	  -- RF_WRITE_SEL <= '0';			-- 0 => Write from DATA BUS && 1 => Write from MDR

	  load <= '1'; 
	  store <= '0'; 
	  branch <= '0'; 
	  newW <= '0'; 
	  doneW <= '0'; 
  
	  dr_en <= 'Z'; 
	  dr_sel <= 'Z'; 
	  result_sel <= '1';
	  if( newFW = '1' ) then
	    mar_en <= '0';
          else
	    mar_en <= '1';
	  end if;

      -------STORE_M STATE-------
	when STORE_M =>
	  RW_DCD <= "ZZZZZZZ";
	  W_ADDR <= write_reg;
          FRD_ADDR <= write_reg;
	  EN_WB_MUX <= '0';
  	  RF_WRITE_SEL <= '1';			-- 0 => Write from DATA BUS && 1 => Write from MDR

	  load <= '0'; 
	  store <= '1'; 
	  branch <= '0'; 
	  newW <= '1'; 
	  doneW <= '0'; 
  
	  dr_en <= '1'; 
	  dr_sel <= '1'; 
	  result_sel <= '1';
    mar_en <= '1';

      -------BRANCH_M STATE-------
	when Branch_M =>
	  RW_DCD <= "ZZZZZZZ";
	  W_ADDR <= write_reg;
          FRD_ADDR <= write_reg;
	  EN_WB_MUX <= '0';
  	  RF_WRITE_SEL <= '0';			-- 0 => Write from DATA BUS && 1 => Write from MDR

	  load <= '0'; 
	  store <= '0'; 
	  branch <= '1'; 
	  newW <= '0'; 
	  doneW <= '0'; 
  
	  dr_en <= 'Z'; 
	  dr_sel <= 'Z';
     
          if( newFW = '1' ) then	  -- this necessary? LOL NO
	    result_sel <= '1';
	  else
	    result_sel <= '0';
	  end if;
	  mar_en <= 'Z';
	  
      -------PC_WRITE STATE-------
	when PC_Write =>
	  RW_DCD <= "ZZZZZZZ";
	  W_ADDR <= write_reg;
          FRD_ADDR <= write_reg;
	  EN_WB_MUX <= '0';
  	  RF_WRITE_SEL <= '0';			-- 0 => Write from DATA BUS && 1 => Write from MDR

	  load <= '0'; 
	  store <= '0'; 
	  branch <= '0'; 
	  newW <= '0'; 
	  doneW <= '0'; 
  
	  dr_en <= 'Z'; 
	  dr_sel <= 'Z'; 
	  result_sel <= '0';
	  mar_en <= 'Z';


      end case;
  end process OUTPUT;

end architecture;
