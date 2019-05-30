Library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity MAR is 
    generic( N: integer := 16);
    port( clk : in std_logic := '0';
          Q_SEL: in std_logic:= '0';
          EN: in std_logic := '0';
          RST: in std_logic := '0';
          ADDRESS_BUS: inout std_logic_vector( N - 1 downto 0 );
          MAIN_BUS: in std_logic_vector(N - 1 downto 0 ));  
end entity MAR;

architecture Struct of MAR is
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

    signal Qbus: std_logic_vector(N - 1 downto 0 );

begin

    GEN_MAR: for K in ( N - 1 ) downto 0 generate
        MAR_REG : DFF_R port map( MAIN_BUS(K),CLK,EN,RST,Qbus(K));
    end generate; 

    GEN_TRI_AB: for K in ( N - 1 ) downto 0 generate
        TRI_AB: tri_state port map (Qbus(K),Q_SEL,ADDRESS_BUS(K));
    end generate;
end Struct ; -- Struct