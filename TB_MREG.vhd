Library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_arith.all;
use work.rnd2.all;

entity m_reg_TB is
    generic( N : integer := 16);

end entity m_reg_TB;

architecture structure_proc of m_reg_TB is


component m_reg is
    generic (N : integer := 16;
            M : integer := 16);
    port (WE : in std_logic_vector(3 downto 0);     -- write DCD
        D: in std_logic_vector( n-1 downto 0);
        clk : in std_logic;
        EN_DCD: in std_logic_vector ( 5 downto 0); -- enable for all decoders
        R_A : in std_logic_vector( 3 downto 0) :="0000";  -- Reg A read DCD
        R_B : in std_logic_vector( 3 downto 0) :="0000";  -- Reg B read DCD
        FSD : in std_logic_vector( 3 downto 0) :="0000";  -- flag set DCD
        FRD  :in std_logic_vector( 3 downto 0) :="0000";  -- flag reset DCD
        FTSD : in std_logic_vector( 3 downto 0) :="0000";  -- Flag read tri state DCD
        B1: out std_logic_vector( n-1 downto 0); -- bus 1 
        B2: out std_logic_vector( n-1 downto 0); -- bus 2
        FRB: out std_logic;                     -- flag read bus
        RST_ALL: in std_logic := '0'); -- resets all flag regs at once
    
end component m_reg;


 signal WE_inp: std_logic_vector(3 downto 0);
 signal RA_inp: std_logic_vector(3 downto 0);
 signal RB_inp: std_logic_vector(3 downto 0);
 signal SR_inp: std_logic_vector(3 downto 0);
 signal RST_SR_inp: std_logic_vector(3 downto 0);
 signal Read_SR_inp: std_logic_vector(3 downto 0);
 signal WINP : std_logic_vector(n-1 downto 0);
 signal E_DCD : std_logic_vector( 5 downto 0) := "000001";

 constant clkfreq : integer := 100e5;
 constant clkT: time := 100 ms / clkfreq;
 signal tb_CLK : std_logic := '0';


constant PERIOD : time := 20 ns;

begin
  UUT: m_reg port map (WE_inp,WINP,tb_CLK,E_DCD,RA_inp,RB_inp,SR_inp,RST_SR_inp,Read_SR_inp);
  -- reg file 
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

variable index:integer;
variable temp:std_logic_vector(3 downto 0);
variable temp2:std_logic_vector(3 downto 0);
variable RData:std_logic_vector(n - 1 downto 0);
variable WE_DCD:std_logic_vector(3 downto 0) := "0000";
variable RA:std_logic_vector(3 downto 0 ) ;
variable RB:std_logic_vector(3 downto 0);
variable A, B, C:integer;
  begin
	--cin <= '0';
    for n in 0 to 15 loop  -- in a loop use index variable to get input value we can get our 25 values
    
    uniform_d(inp1_rec);
	   A:=integer(inp1_rec.rnd);
	   uniform_d(inp2_rec);
        B:=integer(inp2_rec.rnd);
        uniform_d(inp1_rec);
        C:=integer(inp1_rec.rnd);
        temp := conv_std_logic_vector(A,4);   
					-- as soon as we assign value to ip
	temp2 := conv_std_logic_vector(B , 4);
       --  ip <= to_bitvector(temp);

    RData := conv_std_logic_vector(C, 16);
    WE_DCD := conv_std_logic_vector(n,4) ;
	 WE_inp <= (WE_DCD);
     RA_inp <= (temp2);
     WINP <= (RData);
        wait for PERIOD; -- wait this is about 20% more of our worst delay (this time needs to be somewhat larger
       -- wait for CLKT;              -- than the worst case circuit delay (6 ns for 2-4 dec)
    end loop; 

      SR_inp <= "0000";  -- this is the sr ff decoder for set
      RST_SR_inp <= "0000";  -- sr ff decoder for reset
      Read_SR_inp <= "0000"; -- sr ff decoder for reading

      RA_inp <= "0011";
      RB_inp <= "1001";
      wait for Period;
      E_DCD <= "000110";

    wait;
   end process P;
   
end architecture structure_proc;

