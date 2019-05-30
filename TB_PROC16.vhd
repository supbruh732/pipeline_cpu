Library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_arith.all;
use work.rnd2.all;

entity TB_EDU16 is

    generic( clk: in std_logic := '0';
         N : integer := 16;
             E : integer := 4);
end entity TB_EDU16;

architecture structure_proc of TB_EDU16 is

component Processor16 is 
    generic (RAM_FILE: STRING := "G:\Program.txt";
        N : integer := 16 );
    port(MSTR_RST : in std_logic := '0';
         clk: in std_logic;
            speed : in std_logic := '0';
            RND: in std_logic_vector(2 downto 0) := "000"
    );
end component;

 constant clkfreq : integer := 100e7;
 constant clkT: time := 100 ms / clkfreq;
 signal tb_CLK : std_logic := '0';

 signal MSTR_RST_SIG : std_logic := '0';  -- zero means program starts
 signal SPEED_SIG: std_logic := '0'; -- high speed default = 0
 signal RND_SIG: std_logic_vector(2 downto 0) := "000";
constant PERIOD : time := 100 ps;

begin
  UUT: Processor16 port map ( MSTR_RST_SIG, tb_clk, SPEED_SIG, RND_SIG);

  XCLK: process 
  begin
    tb_clk <= not tb_clk after clkT / 2;  
    wait for CLKT;
  end process XCLK;
 
    
   P: process
      variable inp1_rec: rnd_rec_t := (

           -- seed => (0, 0, 0, 123),
           -- seed => (367, 23, 4, 191),
            seed => (250, 1843, 3687, 991),
             bound_l => 1.0,
           -- bound_l => 0.0,
            bound_h => 2.0**3-1.0,  
           -- bound_h => 3.0,
            rnd => 1.0,
            trials => 100,
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
variable Y_RND: std_logic_vector(2 downto 0);
variable A, B, C:integer;
  begin
            
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


    Y_RND := conv_std_logic_vector(C, 3);
    RND_SIG  <= (Y_RND);


        wait for 20 ps;
      
    end loop; 

    wait;
   end process P;
   
end architecture structure_proc;

