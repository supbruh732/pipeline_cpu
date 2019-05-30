Library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_arith.all;
use work.rnd2.all;

entity TB_FU is
end entity TB_FU;

architecture structure_proc of TB_FU is

 component fetch_fsm is
    port( start : in std_logic;
          reset : in std_logic;
      clk : in std_logic;
      
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


-- signal for fetch

-- 

signal strt: std_logic :='0';
signal rst: std_logic := '0';
signal nw_m: std_logic := '0';

signal brnch: std_logic := '0';
signal ld : std_logic := '0';
signal str: std_logic := '0';
signal DECdone: std_logic := '0';
signal IU_CS: std_logic_vector(5 downto 0) := "000000";
signal REG_CS: std_logic_vector(11 downto 0) :="000000000000";



 constant clkfreq : integer := 100e5;
 constant clkT: time := 100 ms / clkfreq;
 signal tb_CLK : std_logic := '0';


constant PERIOD : time := 20 ns;

begin
    UUT: fetch_fsm port map (strt, rst, tb_CLK, nw_m, brnch,ld,str,DECdone, 
                            IU_CS(5),IU_CS(4),IU_CS(3),IU_CS(2),IU_CS(1),IU_CS(0),
                            REG_CS(11),REG_CS(10),REG_CS(9), REG_CS(8),
                            REG_CS(7),REG_CS(6),REG_CS(5), REG_CS(4),
                            REG_CS(3),REG_CS(2),REG_CS(1), REG_CS(0));                          
  
  XCLK: process  -- this is the register clk
  begin
    tb_clk <= not tb_clk after clkT / 2;  
    wait for CLKT;
  end process XCLK;
 
    
   P: process
      variable inp1_rec: rnd_rec_t := (

            seed => (0, 0, 0, 123),
           -- seed => (367, 23, 4, 191),
           -- seed => (250, 1843, 3687, 991),
             bound_l => 1.0,
           -- bound_l => 0.0,
            bound_h => 2.0**16-1.0,  
           -- bound_h => 3.0,
            rnd => 0.0,
            trials => 10,
            p_success => 0.7,
            mean => 2.0,
            std_dev => 1.0
            -- the last 4 fields actually don't matter
         );

        variable inp2_rec: rnd_rec_t := (

            --seed => (0, 0, 0, 123),
           -- seed => (367, 23, 4, 191),
             seed => (250, 1843, 3687, 991),
             bound_l => 1.0,
          --  bound_l => 0.0,
            bound_h => 2.0**16-1.0,
          --  bound_h => 7.0,
            rnd => 0.0,
            trials => 10,
            p_success => 0.7,
            mean => 2.0,
            std_dev => 1.0
            -- the last 4 fields actually don't matter
         );

variable temp:std_logic_vector(3 downto 0);
variable temp2:std_logic_vector(3 downto 0);

variable WE_DCD:std_logic_vector(3 downto 0) := "0000";
variable RA:std_logic_vector(3 downto 0 ) ;
variable RB:std_logic_vector(3 downto 0);
variable A, B, C:integer;
  begin



   -- CASE FOR LOAD
      strt <= '1';
      wait for period/2;
      strt <= '0'; 
      wait for period/2; 
      nw_m <= '1'; -- new mem
      wait for 2 * period; -- wait an extra clock to prove doneD = 0 loop works
      nw_m <= '0';
      DECdone <= '1'; 
      ld <= '1';
      wait for period/2;
      DECdone <= '0'; 
      ld <= '0';
      wait for period/2;
      nw_m <= '1';
      wait for 2 * period;
      nw_m <= '0';
      wait for period/2;
      wait for 2 * period;
        
 -- CASE for STORE to LOAD PATH
        wait for period/2;
        strt <= '0'; 
        wait for period/2; 
        nw_m <= '1'; -- new mem
        wait for 2 * period; -- wait an extra clock to prove doneD = 0 loop works
        nw_m <= '0';
        DECdone <= '1'; 
        str <= '1';
        wait for period * 2;
        DECdone <= '0'; 
        str <= '0';
        wait for period*2;
        nw_m <= '1';
        ld <= '1';
        wait for 2 * period;
        nw_m <= '0';
        ld <= '0';
        wait for period/2;
        nw_m <= '1';
        wait for 2 * period;
        nw_m <= '0';
        wait for 2 * period;

      -- CASE for BRANCH
        wait for period/2;
        strt <= '0'; 
        wait for period/2; 
        nw_m <= '1'; -- new mem
        wait for 2 * period; -- wait an extra clock to prove doneD = 0 loop works
        nw_m <= '0';
        DECdone <= '1'; 
        str <= '1';
        wait for period * 2;
        DECdone <= '0'; 
        str <= '0';
        wait for period*2;
        nw_m <= '1';
        brnch <= '1';
        wait for 2 * period;
        nw_m <= '0';
        brnch <= '0';
        wait for period/2;
        nw_m <= '1';
        wait for 2 * period;
        nw_m <= '0';
        wait for 2 * period;

       -- CASE for loop Store write to Store and Write to init <- last part is not working we need condF
        wait for period/2;
        strt <= '0'; 
        wait for period/2; 
        nw_m <= '1'; -- new mem
        wait for 2 * period; -- wait an extra clock to prove doneD = 0 loop works
        nw_m <= '0';
        DECdone <= '1'; 
        str <= '1';
        wait for period * 2;
        DECdone <= '0'; 
        str <= '0';
        wait for period*2;
        nw_m <= '1';
        str <= '1';
        wait for 2 * period;
        nw_m <= '0';
        str <= '0';
      
        wait for period/2;
        
        nw_m <= '1';

        wait for 2 * period;
     
        nw_m <= '0';
        wait for 2 * period;

    wait;
   end process P;
   
end architecture structure_proc;

