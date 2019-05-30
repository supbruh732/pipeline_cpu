Library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity MDR is 
    generic( N: integer := 16);
    port( clk : in std_logic := '0';
          Q_SEL: in std_logic:= '0';
          B_SEL: in std_logic := '0';
          EN: in std_logic := '0';
          RST: in std_logic := '0';
          DATA_BUS: inout std_logic_vector( N - 1 downto 0 );
          MAIN_BUS: in std_logic_vector(N - 1 downto 0 );
          RF: out std_logic_vector( N - 1 downto 0 ));
       
end entity MDR;

architecture Struct of MDR is 

component DFF_R is 
    generic(tprop : Time  := 12 ps;
            thld : Time := 4 ps;
            tsu   : Time  := 4 ps);
    port( d : in std_logic ;
        clk : in std_logic;
        en  : in std_logic;
        RST : in std_logic := '0';
        q   : out std_logic := '0';
        qn  : out std_logic := '1') ;
end component DFF_R;

component tri_state is 
    generic(trise : time := 2 ps;
            tfall : time := 2 ps;
            this : time := 2 ps);

    port( x : in std_logic;
          en : in std_logic;
          y : out std_logic);
end component tri_state;

    signal BUS_SEL_D : std_logic;
    signal MDR_B: std_logic_vector( N - 1 downto 0);
    signal Qbus: std_logic_vector(N - 1 downto 0);

begin
BUS_SEL_D <= not B_SEL;

GEN_MDR: for K in ( N - 1 ) downto 0 generate
    MDR_REG: DFF_R port map (MDR_B(K),clk, EN,RST,Qbus(K));    
end generate;

GEN_TRI_DB: for K in ( N - 1 )  downto 0 generate 
    TDB: tri_state port map(Qbus(K),Q_SEL,DATA_BUS(K));
end generate;

GEN_TRI_MB: for K in ( N - 1 ) downto 0 generate
    TMB: tri_state port map(MAIN_BUS(K),B_SEL, MDR_B(K));
end generate;

GEN_TRI_DIN: for K in ( N - 1 ) downto 0 generate 
    TDIN: tri_state port map(DATA_BUS(K), BUS_SEL_D, MDR_B(K));
end generate;
    RF <= Qbus;
end Struct ; -- Struct