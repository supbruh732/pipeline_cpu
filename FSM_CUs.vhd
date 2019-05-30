Library IEEE;
use IEEE.STD_LOGIC_1164.all;


entity ControlUnit is 
    generic( N: integer := 16);
    port ( speed : in std_logic;
			  IR : in std_logic_vector( N - 1 downto 0 );
           IR_EN : out std_logic := '0';
           FLGS : in std_logic_vector( 4 downto 0);
           MSTR_RST: in std_logic := '0';
           ALL_RST : in std_logic := '0';
           RST: out std_logic := '0';
           PC_OP: in std_logic_vector(N - 1 downto 0); -- R0 
           PC_SEL : out std_logic := '0';
           PC_LD: out std_logic := '0';
           PC_CONN: out std_logic := '0';
           PC_CLK: out std_logic := '0';
            CLK: in std_logic;
            MAR_conn: out std_logic := '0';
            MDR_conn: out std_logic := '0';
            MAR_EN: out std_logic := '0';
            MDR_EN: out std_logic := '0';
            MDR_SEL_F: out std_logic := '0';
            MEM_W: out std_logic ;
            MEM_R: out std_logic;
            
            ---- REG FILE ---
            RW_DCD: out std_logic_vector( 6 downto 0 );
            R_0: out std_logic_vector( N - 1 downto 0);
            R_A: out std_logic_vector( 3 downto 0);
            R_B: out std_logic_vector( 3 downto 0);
            R_W: out std_logic_vector( 3 downto 0); -- written register
            FSD: out std_logic_vector( 3 downto 0);
            FRD: out std_logic_vector( 3 downto 0);
            FTSD: out std_logic_vector( 3 downto 0);
            FTSD2: out std_logic_vector( 3 downto 0);
            FRB: in std_logic; 
            FRB2: in std_logic;
            Rd1: out std_logic;
            Rd2: out std_logic;
			 	EN_WB_MUX : out std_logic;				-- MUX WRITE BUS MUX
         	RF_WRITE_SEL : out std_logic;			-- SELECT BETWEEN WRITE BUS AND MDR

            XBIT: out std_logic_vector( 1 downto 0); -- (00) uses Reg B | (01) 4bit extend| (10) 8bit extend| (11) 12bit extend
            imm: out std_logic_vector( 11 downto 0);

            ---- ALU OP ---
            ALU_SEL: out std_logic_vector(4 downto 0);
            strt_booth: out std_logic;
            done_Booth: in std_logic;
            alu_reg_en: out std_logic;
            alu_reg_sel: out std_logic;
            aux_reg_en: out std_logic;
            rst_imm: out std_logic := '0';
            RND: in std_logic_vector(2 downto 0) := "000"
            
            );


end entity ControlUnit;

architecture Struct of ControlUnit is

    component reg2R is
        generic (N : integer := 16);
        port ( D : in std_logic_vector(n-1 downto 0);
              clk: in std_logic;
              en : in std_logic;
              RST: in std_logic := '0';
               Q : out std_logic_vector(n-1 downto 0));
    end component reg2R;

    component MC is   -- MASTER CONTROL UNIT FSM
    port( RST: in std_logic := '0';
            CLK : in std_logic;
            startM: out std_logic := '0';
            startF: out std_logic := '0';
            HLT : in std_logic := '0';
            booted: in std_logic );
    end component MC;

    component MU is   -- MEMORY CONTROL UNIT FSM
        port( RST: out std_logic := '0';
            CLK : in std_logic;
            ALL_RST: in std_logic := '0';
            startM: in std_logic := '0';
            NewM: out std_logic := '0';
            DoneF: in std_logic := '0';
            M_LD: in std_logic := '0';
            M_W: in std_logic := '0';
            LOAD: out std_logic := '0';
            STORE: out std_logic := '0';
            WB: in std_logic :=  '0';
            booted: inout std_logic := '0';
            RNG_SEQ: in std_logic_vector(2 downto 0) := "000"); -- rnd sequence
    end component MU;

    component fetch_fsm is
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
      
      end component fetch_fsm;

      component DecUnit is 
    generic( N: integer := 16);
    port (  RST: in std_logic := '0';
            ALL_RST: out std_logic := '0'; -- notifies MU FSM Dec is ready to use
            HLT_MC: out std_logic := '0'; -- alerts MC halt read
            clk: in std_logic := '0'; 
            IRD : in std_logic_vector( N - 1 downto 0); -- Instruct reg between Fetch - Dec
            IRE_EN: out std_logic := '0'; -- instruct reg between Dec - EXE
            -- regfile interface-- 
            RW_DCD: out std_logic_vector(6 downto 0); -- main enable decoder
            R_A: out std_logic_vector(3 downto 0);  -- decoder for Register bus A
            R_B: out std_logic_vector( 3 downto 0); -- decoder for Register bus B
            WE : out std_logic_vector(3 downto 0); -- decoder for write register
            FSD: out std_logic_vector( 3 downto 0);  -- decoder for seting flag
            FRD: out std_logic_vector( 3 downto 0);  -- decoder for reseting flag
            FTSD: out std_logic_vector( 3 downto 0);  -- decoder for reading first reg flag
            FTSD2: out std_logic_vector( 3 downto 0); -- 2nd flag read for 2nd operand
            FRB: in std_logic;  -- read bus for write flag A 
            FRB2: in std_logic; -- read bus for write flag B
            Rd1: out std_logic := '0';  -- RegA
            Rd2: out std_logic := '0';  -- RegB
            -- inter handshake --
            NewD: out std_logic;
            DoneE: in std_logic := '0';
            DoneD: out std_logic;
            NewFD: in std_logic := '0';
            XBIT: out std_logic_vector (1 downto 0); -- extend bits for 00 Rd2 01 4bit extend, 10 8 bit extend 11 12bit extend for immed
            imm: out std_logic_vector(11 downto 0);
            FLAGS: in std_logic_vector(4 downto 0); -- 5 bit Status flags reg
            rst_imm: out std_logic := '0'
            );
end component DecUnit;


component execute_fsm is
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
      
  end component execute_fsm;


  component writeB_fsm is
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
  end component writeB_fsm;


        -- DECODE SIGNAL  --

    signal NewD: std_logic := '0';    
    signal DoneE: std_logic := '0';
    --signal DoneD: std_logic := '0';
        
    signal RST_CONFIRM: std_logic_vector(4 downto 0) := "00000";
    
    
    signal StartM : std_logic := '0';
    signal StartF : std_logic := '0';
    signal HLT: std_logic := '0';
    signal Booted: std_logic := '0';
    signal RST_ALL: std_logic := '0';
    signal RST_INT: std_logic := '0';
    signal DoneF: std_logic := '0';
    signal DoneM : std_logic := '0';
    signal NewM: std_logic := '0';
    signal NewF: std_logic := '0';
    signal W_REQ : std_logic := '0';
    signal L_REQ : std_logic := '0';
    signal WB : std_logic := '0';
    --signal RND: std_logic_vector(2 downto 0) := "000";

    -- write to fetch signals
    signal F_branchW : std_logic := '0';
    signal F_loadW : std_logic := '0';
    signal F_storeW: std_logic := '0';

    -- DCD to Fetch
    signal F_doneD : std_logic := '0';
    -- intersig
    signal F_okw : std_logic := '0';
    signal F_newFW: std_logic := '0';
    signal IRD_EN: std_logic := '0';
    signal NEW_F_EN: std_logic := '0';
    signal NEWFW_EN: std_logic := '0';

    signal IRE_EN_SIG: std_logic := '0';
    signal IRW_EN_SIG: std_logic := '0';
    signal PCW_EN_SIG: std_logic := '0'; -- not sure why its needed ?

    -- internal register signals-- 

    signal PC_DEC_REG : std_logic_vector( N - 1 downto 0);
    signal IR_DEC_REG : std_logic_vector( N - 1 downto 0);
    signal PC_EXE_REG : std_logic_vector( N - 1 downto 0);
    signal IR_EXE_REG : std_logic_vector( N - 1 downto 0);
    signal PC_W_REG : std_logic_vector( N - 1 downto 0);
    signal IR_W_REG : std_logic_vector( N - 1 downto 0);
    signal FLAGS_REG: std_logic_vector( 4 downto 0);

    --- ALU sig -- 
    --signal aux_reg_en : std_logic; -- not sure why this is needed?
    


    -- exe signals -- 
    signal EXE_FLG_EN : std_logic := '0'; 
    signal DoneW: std_logic := '0';
    signal newE: std_logic := '0';
    signal newW: std_logic := '0';
    signal DEC_RW_DCD: std_logic_vector(6 downto 0);
    signal EXE_RW_DCD: std_logic_Vector(6 downto 0);
    signal DEC_BLANK: std_logic_vector(3 downto 0); -- dummy signal to prevent write attempts from decoder
    signal F_BLANK: std_logic;
    signal F_BLANK2: std_logic;
    signal EXE_BLANK: std_logic_vector(3 downto 0);
    signal ALU_REG_EN_SIG: std_logic := '0';
	 -- write bus signal --
	 -- signal EN_WB_MUX : out std_logic;
    -- signal RF_WRITE_SEL : out std_logic;


begin
    --READ \ WRITE  Decoder for REG FILE--
    RW_DCD(0) <= EXE_RW_DCD(0); -- Write register
    RW_DCD(1) <= DEC_RW_DCD(1); -- Read A reg
    RW_DCD(2) <= DEC_RW_DCD(2); -- Read B reg
    RW_DCD(3) <= DEC_RW_DCD(3); -- Set WF
    RW_DCD(4) <= EXE_RW_DCD(4); -- Reset WF 
    RW_DCD(5) <= DEC_RW_DCD(5); -- Read Write Flag A
    RW_DCD(6) <= DEC_RW_DCD(6); -- Read Write flag B

    alu_reg_en <= ALU_REG_EN_SIG;
    RST <= RST_INT;
    --R_0 <= PC_EXE_REG; -- hard wire R0 PC from exe
    R_0 <= PC_DEC_REG; -- hard wire R0 PC from dec this one gets stored in reg A

    IR_D_R : reg2R port map(IR, clk, IRD_EN, RST_INT, IR_DEC_REG);
    IR_E_R : reg2R port map(IR_DEC_REG, clk, IRE_EN_SIG, RST_INT, IR_EXE_REG);
    IR_W_R : reg2R port map(IR_EXE_REG, clk, IRW_EN_SIG, RST_INT, IR_W_REG);

    PC_D_R : reg2R port map(PC_OP,clk,IRD_EN,RST_INT, PC_DEC_REG);
    PC_E_R : reg2R port map( PC_DEC_REG, clk, IRE_EN_SIG, RST_INT, PC_EXE_REG );
    PC_W_R : reg2R port map( PC_EXE_REG, clk, IRW_EN_SIG, RST_INT, PC_W_REG );
    STATUS_FLG: reg2R generic map ( N => 5) port map (FLGS,clk, EXE_FLG_EN,RST_INT, FLAGS_REG );


    
    MSTR_UNIT: MC port map(MSTR_RST, CLK, STARTM, STARTF, HLT, BOOTED);
    MEMORY_UNIT: MU port map(RST_INT, CLK, ALL_RST, STARTM, NEWM, DONEF,L_REQ,W_REQ,MEM_R,MEM_W, WB, BOOTED, RND);
    FETCH_UNIT :fetch_fsm port map(StartF,RST_INT, clk,IR, NewM,F_branchW,F_loadW, F_storeW, F_doneD, L_REQ, W_REQ, F_okw, F_newFW,NewF,doneF,
                                    IR_EN, IRD_EN,PC_CONN,PC_SEL ,PC_CLK,PC_LD, MAR_conn, MDR_conn, MDR_EN, MDR_SEL_F, NEW_F_EN, NEWFW_EN );
    DECODER_UNIT: DecUnit port map(RST_INT,RST_CONFIRM(4),HLT,clk,IR_DEC_REG,IRE_EN_SIG,DEC_RW_DCD,R_A,R_B,dec_blank,FSD,FRD,FTSD,FTSD2,FRB,FRB2, rd1, rd2,
                                   NewD, DoneE,F_doneD,NewF,XBIT, imm, FLAGS_REG, rst_imm);
    EXECUTE_UNIT: execute_fsm port map( NewD, rst_int, clk, speed, IR_EXE_REG,DoneW, done_Booth,alu_sel, newE,DoneE,strt_booth,PCW_EN_SIG,IRW_EN_SIG,ALU_REG_EN_SIG,aux_reg_en,EXE_FLG_EN);
    WRITE_UNIT: writeB_fsm port map(newE,rst_int,clk,IR_W_REG,F_newFW,F_okw,EXE_RW_DCD,R_W,FRD,EN_WB_MUX,RF_WRITE_SEL,F_loadW,F_storeW,F_branchW, newW,
													doneW,MDR_EN, MDR_SEL_F,alu_reg_sel,ALU_REG_EN_SIG, MAR_EN);

   

end Struct ; -- Struct