Library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_arith.all;
use work.rnd2.all;

entity TB_BMU is
    generic( N : integer := 16;
             E : integer := 4);
end entity TB_BMU;

architecture structure_proc of TB_BMU is

component BM_UNIT is 
        generic( N: integer := N;
                 E: integer := E);
    port (START_BOOTH: in std_logic := '1';
          RST: in std_logic := '0';
          clk: in std_logic;
          X : in std_logic_vector( N - 1 downto 0) := "1111111111100111";
          Y : in std_logic_vector( N - 1 downto 0) := "0000000001001101";
          DONE_BOOTH: out std_logic;
          ovr : out std_logic;
          p : out std_logic_vector ( 2*N - 1 downto 0);
          T: out std_logic_vector( N - 1 downto 0 ));
end component;


signal X_IN : std_logic_vector(N - 1 downto 0);
signal Y_IN : std_logic_vector(N - 1 downto 0);
signal P_sig: std_logic_vector(2*N - 1 downto 0);

 constant clkfreq : integer := 100e7;
 constant clkT: time := 1000 ms / clkfreq;
 signal tb_CLK : std_logic := '0';
 signal strt_b: std_logic := '0';
 signal Done_b: std_logic;
 signal rst: std_logic := '0';
 signal OVR: std_logic;



constant PERIOD : time := 860000 ps;

begin
  
  UUT: BM_UNIT port map(strt_b,rst,tb_clk,X_IN, Y_IN,Done_b,OVR,P_SIG);

  XCLK: process 
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

variable X_RND:std_logic_vector(n - 1 downto 0);
variable Y_RND: std_logic_vector(n - 1 downto 0);

variable WE_DCD:std_logic_vector(3 downto 0) := "0000";
variable RA:std_logic_vector(3 downto 0 ) ;
variable RB:std_logic_vector(3 downto 0);
variable A, B, C:integer;
  begin
	--cin <= '0';
    for n in 0 to 19 loop  -- in a loop use index variable to get input value we can get our 25 values
    
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


    X_RND := conv_std_logic_vector(C, 16);
    Y_RND := conv_std_logic_vector(B, 16);
    X_IN <= (X_RND);
    Y_IN <= (Y_RND);
    strt_b <= '1';
    wait for 20 ps;
    strt_b <= '0';
   -- WE_DCD := conv_std_logic_vector(n,4) ;
	-- WE_inp <= (WE_DCD);
     --RA_inp <= (temp2);
     --WINP <= (RData);
       -- wait for PERIOD; -- wait this is about 20% more of our worst delay (this time needs to be somewhat larger
        --wait for Done_b;
        wait on Done_b;
        wait for 20 ps;
       -- wait for CLKT;              -- than the worst case circuit delay (6 ns for 2-4 dec)
    end loop; 

    wait;
   end process P;
   
end architecture structure_proc;

