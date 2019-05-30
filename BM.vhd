Library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity BM is
    generic( N : integer := 16;
             E : integer := 4);
  port ( X: in std_logic_vector ( N - 1 downto 0);
         Y: in std_logic_vector ( N - 1 downto 0);
         P: out std_logic_vector( 2*N - 1 downto 0);
         T: out std_logic_vector( N - 1 downto 0 );
         clk: in std_logic;
         shift: in std_logic;
         LD_AC: in std_logic_vector( 1 downto 0);  -- 10 -> reset, 11 -> ld reg
         LD_X: in std_logic_vector( 1 downto 0); -- 10 -> reset , 11 -> ld reg 
         ALU: in std_logic; -- 0 add, 1 sub
         RST: in std_logic := '0';
         status: out std_logic;
         Qc: out std_logic; -- current Q
         OVR: out std_logic);
end BM;

architecture STRUCT of BM is

    component CLA_P2 is
        generic( N : INTEGER := N;     --SIZE 2^E = (N)
              E : INTEGER := E);     --EXPONENT part -> 2^(E) = N
        port( a : in std_logic_vector( N-1 downto 0) ;
              b : in std_logic_vector( N-1 downto 0) ;
             cin: in std_logic ;
            S: out std_logic_vector(N-1 downto 0);
            OVR: out std_logic; -- for 2's comp
            cout: out std_logic); -- ovr for unsigned
        end component CLA_P2;

    component N_SH_REG is
        generic( R : integer := N;
                tprop : Time := 6 ps;
                thld : Time := 3 ps ;
                tsu : Time := 3 ps );
          port ( in_R : in std_logic_vector( R - 1 downto 0 );
              clk : in std_logic;
              en : in std_logic;
              RST: in std_logic := '0';
              q : out std_logic_vector( R - 1 downto 0 );
              mode: in std_logic_vector ( 1 downto 0); -- 00 -> reset , 01 -> load, 11 -> ASR,  10 -> flow in shift
              Fin: in std_logic := '0';
              Fout : out std_logic);
      end component N_SH_REG;

      component my_xor is
        generic (gate_delay : Time := 3 ps);            -- default delay
         port(x,y:in STD_LOGIC;
              z:out STD_LOGIC);
      end component my_xor;

      component my_and is
        generic (gate_delay : Time := 2 ps);            -- default delay
         port(x,y:in STD_LOGIC;
              z:out STD_LOGIC);
      end component my_and;

    signal xor_R: std_logic_vector( N - 1 downto 0);
    signal SUM: std_logic_vector( N - 1 downto 0);
    signal ac_R : std_logic_vector( N - 1 downto 0);
    signal RM_AC: std_logic_vector( 1 downto 0);
    signal RM_X : std_logic_vector( 1 downto 0); 
    signal AC_OUT: std_logic;
    signal ENCLK: std_logic;
  
    signal Cout_SIG: std_logic;
    

begin
    RM_AC(1) <= shift;
    RM_X(1) <= shift;
    RM_AC(0) <= LD_AC(0);
    RM_X(0) <= LD_X(0);
  --  ENCLK <= LD_X(1) and clk;
andCLK: my_and port map(LD_X(1), CLK, ENCLK);
    gen_xor: for T in N - 1 downto 0 generate
        x2cmp: my_xor port map(Y(T),ALU, xor_R(T));
    end generate;

    CLA: CLA_P2 port map(ac_R,xor_R,ALU,SUM,OVR,Cout_SIG);

    --OVR_DETECT: my_xor port map (SUM(N - 1),Cout_SIG,OVR);
    AC_REG: N_SH_REG port map(SUM,clk,LD_AC(1),RST,ac_R,RM_AC,'0',AC_OUT);
   -- X_REG: N_SH_REG port map (X,clk,LD_X(1),RST,p(N-1 downto 0),RM_X, AC_OUT, Qc); 
   X_REG: N_SH_REG port map (X,clk,LD_X(1),RST,p(N-1 downto 0),RM_X, AC_OUT, Qc); 
    p(2*N - 1 downto N) <= ac_R;


end STRUCT ; --BMTRBM