Library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity N_SH_REG is
  generic( R : integer := 16;
          tprop : Time := 8 ns;
          thld : Time := 4 ns ;
          tsu : Time := 1 ns );
    port ( in_R : in std_logic_vector( R - 1 downto 0 );
        clk : in std_logic;
        en : in std_logic;
        RST: in std_logic := '0';
        q : out std_logic_vector( R - 1 downto 0 );
        mode: in std_logic_vector ( 1 downto 0); -- 00 -> reset , 01 -> load, 11 -> ASR,  10 -> flow in shift
        Fin: in std_logic := '0';
        Fout : out std_logic);
end N_SH_REG;

architecture Struct of N_SH_REG is

 component DFF_R is 
    generic(tprop : Time  := tprop ;
            thld : Time := thld ;
            tsu   : Time  := tsu );
    port( d : in std_logic ;
        clk : in std_logic;
        en  : in std_logic;
        RST : in std_logic := '0';
        q   : out std_logic := '0';
        qn  : out std_logic := '1') ;
end component DFF_R;

component Nto1_Mux is 
    generic( E: integer := 2;
             N: integer := 4);
    port ( I : in std_logic_vector(N - 1 downto 0);
           sel: in std_logic_vector(E - 1 downto 0);
    En : in std_logic; 
     op : out std_logic);
end component;
    type in_wire is array ( R - 1  downto 0) of std_logic_vector(3 downto 0);
    signal In_MUX : in_wire;
   -- signal op_mux : std_logic_vector(R - 1 downto 0);
    signal D_SIG : std_logic_vector(R - 1 downto 0);
    signal Q_SIG : std_logic_vector(R - 1 downto 0);
    signal EN_SIG : std_logic := '0';
    signal notCLK: std_logic := '0';

    -- clock test
   -- constant clkfreq : integer := 100e5;
  --  constant clk_T: time := 100 ms / clkfreq;
  --  signal clks :   std_logic := '0';
begin
   -- xCLK: process
     --   begin
       --     clks <= not clks after clk_T / 2;
         --   wait for clk_T;
    --end process;
    --q(R-1) <= MSB;
    q <= Q_SIG;
 --   IN_mux(5)(2) <= '1';
 notCLK <= not clk;

    GEN_RST: for T in R - 1 downto 0 generate
        IN_MUX(T)(0) <= '0';
    end generate;

    GEN_LD: for L in R - 1 downto 0 generate
        IN_MUX(L)(1) <= in_R(L); 
    end generate;

    IN_MUX(R-1)(2) <= Fin;
    GEN_FIN: for A in R - 2 downto 0 generate
        IN_MUX(A)(2) <= q_sig(A + 1);
    end generate;

    IN_MUX(R-1)(3) <= q_sig(R-1);
    GEN_ASR: for A in R - 2 downto 0 generate
        IN_MUX(A)(3) <= q_sig(A + 1);
    end generate;

    MSB_MUX: Nto1_Mux port map(In_MUX(R-1), mode, en, D_SIG(R-1));

    GEN_MUX: for M in R - 2 downto 0 generate
        mux_others: Nto1_Mux port map (In_MUX(M),mode, en, D_SIG(M));
    end generate;

    GEN_REG: for M in R - 1 downto 0 generate
        FF_GEN: DFF_R port map (D_SIG(M),notclk,en,RST,q_sig(M));
    end generate;

    Fout <= Q_SIG(0);
end Struct ; --N_SH_REGtrN_SH_REG