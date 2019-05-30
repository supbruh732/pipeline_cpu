Library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity Processor16 is 
    generic (RAM_FILE: STRING := "D:\Program.txt";
        N : integer := 16 );
    port(MSTR_RST : in std_logic := '0';
         clk: in std_logic;
            speed : in std_logic := '0';
            RND: in std_logic_vector(2 downto 0) := "000"
    );

end entity;

architecture struct of Processor16 is

    component  MEM is 
        generic( RAM_FILE_PATH : STRING := RAM_FILE;
                N : integer := 16;
                M : integer := 255);  -- memory size 

        port ( -- D_IN: INOUT std_logic_vector(N - 1 downto 0);
            INIT: out std_logic := '0';  -- memory loaded if 1
            ADDR: INOUT std_logic_vector(N - 1 downto 0);
            R_ENX: in std_logic := '0';
            W_ENX: in std_logic := '0';
            Data: inout std_logic_vector(N - 1 downto 0));
    end component;

    component PC_CNTR is
        generic( N : integer := 16);
      port (clk : in std_logic;
            PC_LD : in std_logic := '0';
            PC_SEL: in std_logic := '0';
            PC_CONN: in std_logic := '0';
            RST: in std_logic := '0';
            Main_Bus: in std_logic_vector(N - 1 downto 0);
            Q_A: out std_logic_vector(N-1 downto 0);
            Q_R: out std_logic_vector(N-1 downto 0)    
      ) ;
    end component PC_CNTR;

    component MAR is 
        generic( N: integer := 16);
        port( clk : in std_logic := '0';
            Q_SEL: in std_logic:= '0';  -- MAR_CONN
            EN: in std_logic := '0';
            RST: in std_logic := '0';
            ADDRESS_BUS: inout std_logic_vector( N - 1 downto 0 );
            MAIN_BUS: in std_logic_vector(N - 1 downto 0 ));  
    end component MAR;

    component MDR is 
        generic( N: integer := 16);
        port( clk : in std_logic := '0';
            Q_SEL: in std_logic:= '0';  -- MDR_CONN
            B_SEL: in std_logic := '0'; --BUS SELECTION ether REG FILE or DATA BUS
            EN: in std_logic := '0';
            RST: in std_logic := '0';
            DATA_BUS: inout std_logic_vector( N - 1 downto 0 );
            MAIN_BUS: in std_logic_vector(N - 1 downto 0 );
            RF: out std_logic_vector( N - 1 downto 0 ));
        
    end component MDR;

    component IR is 
        generic( N: integer := 16);
        port( clk : in std_logic := '0';
            EN: in std_logic := '0';
            RST: in std_logic := '0';
            DATA_BUS: in std_logic_vector( N - 1 downto 0 );
            FSM: out std_logic_vector(N - 1 downto 0 )); 
    end component IR;

    component Nbit_NMUX is 
        generic( M: integer := 16;
                E: integer := 2;
                N: integer := 2);
        port ( I : in std_logic_vector(M - 1 downto 0);
            I2: in std_logic_vector(M - 1 downto 0);
            sel: in std_logic :='0';
        En : in std_logic; 
        op : out std_logic_vector(M - 1 downto 0));
    end component;

    component Mux16_2_1 is 
        generic (N : integer := 16 );
        port(I : in std_logic_vector( N - 1 downto 0);
            I2 : in std_logic_vector( N - 1 downto 0);
            sel : in std_logic := '0';
            EN : in std_logic := '0'; 
            OP: out std_logic_vector( N - 1 downto 0)
        );

    end component;

    component SX4to1 is 
        generic( M: integer := 16;
                E: integer := 4;
                N: integer := 4);
        port ( I : in std_logic_vector(M - 1 downto 0);
            I2: in std_logic_vector(M/4 - 1 downto 0);
            I3: in std_logic_vector(M/2 - 1 downto 0);
            I4: in std_logic_vector(M - 5 downto 0);
            sel: in std_logic_vector( 1 downto 0);
        En : in std_logic; 
        op : out std_logic_vector(M - 1 downto 0));
    end component;

    component RegFile is
        generic (N : integer := 16;
                M : integer := 16);
      port (WE : in std_logic_vector(3 downto 0);     -- write DCD
            D: in std_logic_vector( n-1 downto 0);
            clk : in std_logic;
            RW_DCD: in std_logic_vector ( 6 downto 0); -- enable for all decoders
            R_0 : in std_logic_vector( n - 1 downto 0); -- scratch reg
            R_A : in std_logic_vector( 3 downto 0);  -- Reg A read DCD
            R_B : in std_logic_vector( 3 downto 0);  -- Reg B read DCD
            FSD : in std_logic_vector( 3 downto 0);  -- flag set DCD
            FRD  :in std_logic_vector( 3 downto 0);  -- flag reset DCD
            FTSD : in std_logic_vector( 3 downto 0);  -- Flag read tri state DCD
            FTSD2: in std_logic_vector( 3 downto 0);  -- 2nd flag read dcd
            B1: out std_logic_vector( n-1 downto 0); -- bus 1 
            B2: out std_logic_vector( n-1 downto 0); -- bus 2
            FRB: out std_logic;                     -- flag read bus
            FRB2: out std_logic;
          RST_ALL: in std_logic := '0');
    end component RegFile;

    component reg2R is
        generic (N : integer := 16);
        port ( D : in std_logic_vector(n-1 downto 0);
              clk: in std_logic;
              en : in std_logic;
              RST: in std_logic := '0';
               Q : out std_logic_vector(n-1 downto 0));
    end component reg2R;

    component ControlUnit is 
    generic( N: integer := 16);
    port ( speed : in std_logic;
	        IR : in std_logic_vector( N - 1 downto 0 );
           IR_EN : out std_logic := '0';
           FLGS : in std_logic_vector( 4 downto 0);
           MSTR_RST: in std_logic := '0';
           ALL_RST : in std_logic := '0';
           RST: out std_logic := '0';
           PC_OP: in std_logic_vector(N - 1 downto 0);
           PC_SEL : out std_logic := '0';
           PC_LD: out std_logic := '0';
           PC_CONN: out std_logic := '0';
           PC_CLK: out std_logic := '0';
            CLK: in std_logic;
            MAR_conn: out std_logic := '0';
            MDR_conn: out std_logic := '0';
            MDR_EN: out std_logic := '0';
       	    MAR_EN : out std_logic := '0';
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
				EN_WB_MUX : out std_logic;
				RF_WRITE_SEL : out std_logic;

            XBIT: out std_logic_vector( 1 downto 0); -- (00) uses Reg B | (01) 4bit extend| (10) 8bit extend| (11) 12bit extend
            imm: out std_logic_vector( 11 downto 0);

            ---- ALU OP ---
            ALU_SEL: out std_logic_vector(4 downto 0);
            strt_booth: out std_logic;
            done_Booth: in std_logic;
            alu_reg_en: out std_logic;
            alu_reg_sel: out std_logic;
            aux_reg_en: out std_logic;
            rst_imm: out std_logic;
            RND: in std_logic_vector(2 downto 0) := "000"
                      
            
            );
end component ControlUnit;

----
----component my_ALU is
----	generic (size:integer:= 16;
----			 t_hold: time := 2 ps;
----			 set_up: time := 2 ps ;
----			 unit_delay: time := 2 ps   );            -- default size
----   port 
----   (X, Y: in std_logic_vector (size-1 downto 0);
  --    
------	  rca_enable, cla_enable, booth_enable, arr_mul_enable, compar_enable: in std_logic;
----	  
----	  ---inputs for booth_mul
----	  start_booth: in std_logic;
----	  clk: in std_logic;
----	  reset: in std_logic;	  
----	  done_booth: out std_logic;
----	  
----	  Z: out std_logic_vector (size-1 downto 0);
  ----     overflow, cout_add: out std_logic;
  ----     flag_neg, flag_zero, flag_greater, flag_less, flag_eq: out std_logic);
--end component;
--
component my_ALU is
	generic (size:integer:= 16);
			 --t_hold: time := 2ns;
			 --set_up: time := 2ns;
			 --unit_delay: time := 2ns);            -- default size
   port 
   (X, Y: in std_logic_vector (size-1 downto 0);
      
	  rca_enable, cla_enable, booth_enable, arr_mul_enable, compar_enable: in std_logic;
	  
	  ---inputs for booth_mul
	  start_booth: in std_logic;
	  clk: in std_logic;
	  reset: in std_logic;	  
	  done_booth: out std_logic;
	  
	  Z: out std_logic_vector (size-1 downto 0);
       overflow, cout: out std_logic;
       flag_neg, flag_zero, flag_greater, flag_less, flag_eq: out std_logic);
end component;
    

-- ALL BUS SIGNALS --
    
    signal WRITE_MEM_SIG : std_logic := '0';
    signal READ_MEM_SIG : std_logic := '0';
    signal DATA_BUS : std_logic_vector(N - 1 downto 0);
    signal ADDRESS_BUS : std_logic_vector(N - 1 downto 0);
    signal WRITE_BUS: std_logic_vector( N - 1 downto 0);
    signal REG_FILE_WB: std_logic_vector( N - 1 downto 0);
    signal INST_REG : std_logic_vector( N - 1 downto 0);
    -- CU TO REG FILE SIGNALS -- 
    signal RST : std_logic := '0';
    -- ALU TO CU SIGNALS -- 
   

    signal FLAGS_BUS: std_logic_vector( 4 downto 0);

    -- CU to MUX signals --
    signal DIN : std_logic_vector(n-1 downto 0);

    -- REG signals -- 
    signal PC_LD: std_logic := '0';
    signal PC_SEL: std_logic := '0';
    signal PC_CONN: std_logic := '0';
    signal R_0 : std_logic_vector(N - 1 downto 0);
    signal PC_0 : std_logic_vector(N - 1 downto 0);
    signal MAR_CONN: std_logic :='0';
    signal MAR_EN : std_logic :='0';
    signal MDR_CONN: std_logic :='0';
    signal MDR_EN : std_logic :='0';
    signal BUS_SEL_IN : std_logic :='0';
    signal IR_EN : std_logic :='0';
    signal PC_CLK: std_logic := '0';

    -- REG file sig

    signal RW_DCD : std_logic_vector(6 downto 0);
    

    signal R_A:  std_logic_vector( 3 downto 0);
    signal R_B:  std_logic_vector( 3 downto 0);
    signal R_W:  std_logic_vector( 3 downto 0); -- written register
    signal FSD:  std_logic_vector( 3 downto 0);
    signal FRD:  std_logic_vector( 3 downto 0);
    signal FTSD: std_logic_vector( 3 downto 0);
    signal FTSD2:  std_logic_vector( 3 downto 0);
    signal FRB:  std_logic; 
    signal FRB2: std_logic;
    signal Rd1: std_logic;  -- signal to enable regs
    signal Rd2:  std_logic;
    signal REG_A_BUS_I: std_logic_vector( N - 1 downto 0); -- in from RF
    signal REG_B_BUS_I: std_logic_vector( N - 1 downto 0);
    signal MUX_B_I: std_logic_vector( N - 1 downto 0);
    signal REG_A_BUS_O: std_logic_vector( N - 1 downto 0);  -- out from REG
    signal REG_B_BUS_O: std_logic_vector( N - 1 downto 0);
    

    signal XBIT: std_logic_vector( 1 downto 0); -- (00) uses Reg B | (01) 4bit extend| (10) 8bit extend| (11) 12bit extend
    signal imm:  std_logic_vector( 11 downto 0);

    ---- ALU OP ---
   signal ALU_SEL:  std_logic_vector(4 downto 0);
   signal strt_booth:  std_logic;
   signal done_Booth:  std_logic;
   signal alu_reg_en: std_logic;
   signal alu_reg_sel:  std_logic;
   signal all_rst: std_logic := '0';
   signal ALU_RESULT_BUS: std_logic_vector( N - 1 downto 0);
   signal AUX_BUS: std_Logic_vector(N -1 downto 0);
   signal AUX_IN_BUS: std_logic_vector( N - 1 downto 0);
   
   -- WB signals -- 
   signal MUX_TO_RF_BUS: std_logic_vector( N - 1 downto 0);
   signal RF_WRITE_SEL : std_Logic := '0'; -- WB can select were to load data from MDR or WRITE BUS
   signal EN_WB_MUX : std_logic := '0'; -- enable mux to reg file
   

   signal mem_init : std_logic := '0'; -- all memory loaded if 1
   signal AUX_SEL : std_logic := '0';
   signal AUX_EN : std_logic := '0';
   --ALU FUNC UNIT sigs-
   signal RCA: std_logic := '0';
   signal CLA: std_logic := '0';
   signal BOOTH: std_logic := '0';
   signal AMULT: std_logic := '0';
   signal CMP: std_logic := '0';
   
   signal OVR: std_logic;
   signal COUT: std_logic;
   -- ALU -- flag
   signal NEG: std_logic ;
   signal ZERO: std_logic ;
   signal GT: std_logic ;
   signal LT: std_logic ;
   signal EQ: std_logic ;
   signal rst_imm_sig: std_logic := '0';  -- for imm
  
begin
   
    SYSTEM_MEMORY: MEM port map (MEM_INIT,ADDRESS_BUS, READ_MEM_SIG, WRITE_MEM_SIG, DATA_BUS);

    PC_REG: PC_CNTR port map (PC_CLK,PC_LD, PC_SEL,PC_CONN, MSTR_RST, WRITE_BUS, ADDRESS_BUS,PC_0 );

    MAR_REG: MAR port map ( clk, MAR_CONN,MDR_EN,RST, ADDRESS_BUS, WRITE_BUS);

    MDR_REG: MDR port map (clk, MDR_CONN, BUS_SEL_IN, MDR_EN,RST,DATA_BUS, AUX_BUS,REG_FILE_WB ); -- took out mdr en

    IR_REG : IR port map ( clk, IR_EN, RST, DATA_BUS,INST_REG);

    CONTROL_UNIT: ControlUnit port map (speed, INST_REG, IR_EN,FLAGS_BUS, MSTR_RST, mem_init,RST, PC_0, PC_SEL, PC_LD, PC_CONN, PC_CLK, clk,
                                        MAR_CONN, MDR_CONN, MDR_EN, MDR_EN, BUS_SEL_IN, WRITE_MEM_SIG, READ_MEM_SIG,
                                        RW_DCD, R_0, R_A,R_B,R_W, FSD, FRD, FTSD, FTSD2, FRB, FRB2, Rd1, Rd2, EN_WB_MUX, RF_WRITE_SEL, XBIT, imm, ALU_SEL, strt_booth, done_booth, alu_reg_en, alu_reg_sel, AUX_EN,rst_imm_sig, RND);
                             
    REGISTER_FILE: RegFile port map(R_W,MUX_TO_RF_BUS,clk,RW_DCD,R_0,R_A,R_B,FSD,R_W,FTSD,FTSD2,REG_A_BUS_I,MUX_B_I,FRB,FRB2,RST);

    REG_A: reg2R port map ( REG_A_BUS_I,clk, Rd1, rst_imm_sig, REG_A_BUS_O);
    REG_B: reg2R port map ( REG_B_BUS_I,clk, Rd2, RST, REG_B_BUS_O);
    REG_C: reg2R port map ( MUX_B_I, clk, Rd2, RST, AUX_IN_BUS);  --REG C connects to AUX For stor data procedure  is enabled by Decoder FSM
    RESULTS_ALU_REG: MAR port map (clk,alu_reg_sel,alu_reg_en, RST, WRITE_BUS,ALU_RESULT_BUS);
    AUX_REG: IR port map (clk, AUX_EN,RST,AUX_IN_BUS, AUX_BUS);  -- AUX for Store Data procedure  AUX connects to MDR is enabled by EXE
    --AUX_REG: MAR port map ( clk, aux_sel, AUX_EN, RST,AUX_BUS, MUX_B_I ); old AUX
    SIGN_XTEND_MUX: SX4to1 port map(MUX_B_I,imm(3 downto 0), imm( 7 downto 0), imm, XBIT,Rd2, REG_B_BUS_I);
    MUX_WB_RF: Mux16_2_1 port map(WRITE_BUS, REG_FILE_WB, RF_WRITE_SEL,EN_WB_MUX, MUX_TO_RF_BUS );
  
    ALU_UNIT: my_ALU port map(REG_A_BUS_O, REG_B_BUS_O,
                            RCA , CLA, BOOTH, AMULT, CMP,
                            strt_booth, clk, RST, done_booth,
                            ALU_RESULT_BUS,
                            OVR, COUT,
                            NEG, ZERO, GT,LT,EQ);
-- flags mapping --
    FLAGS_BUS(4) <= GT;
    FLAGS_BUS(3) <= LT;
    FLAGS_BUS(2) <= EQ;
    FLAGS_BUS(1) <= ZERO;
    FLAGS_BUS(0) <= NEG;

    
    BOOTH <= ALU_SEL(2);
    AMULT <= ALU_SEL(3);
    CMP <= ALU_SEL(4);
    RCA <= ALU_SEL(1);
    CLA <= ALU_SEL(0);
  

end struct ; -- struct

