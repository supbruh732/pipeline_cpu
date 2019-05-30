Library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity SYNC_CNTR is 
--generic( E : integer := 4); -- exponent of N

port ( en : in std_logic;
        clk : in std_logic;
        q: out std_logic_vector( 3 downto 0);
        RST: in std_logic := '0');     
end SYNC_CNTR;

architecture Struct of SYNC_CNTR is

    component my_and is
        generic (gate_delay : Time := 2 ps);            -- default delay
         port(x,y:in STD_LOGIC;
              z:out STD_LOGIC);
      end component my_and;

    component TFF_R is 
        generic(tprop : Time  := 12 ps;
                thld : Time := 4 ps;
                tsu   : Time  := 4 ps);
        port( T : in std_logic ;
            clk : in std_logic;
            RST : in std_logic := '0';
            q   : out std_logic := '0');

    end component TFF_R;

    signal T_SIG : std_logic_vector(0 to 3);
    signal Q_SIG : std_logic_vector(0 to 3);

begin
    T_SIG(0) <= en;
    GEN_TFF: for K in 0 to 3 generate 
        TFF: TFF_R port map(T_SIG(K),clk,RST,Q_SIG(K));
    end generate;

    GEN_AND: for K in 1 to 3 generate 
        ANDG: my_and port map(T_SIG(K - 1), Q_SIG(K - 1), T_SIG(K));
    end generate;

    q(3) <= Q_SIG(3);
    q(2) <= Q_SIG(2);
    q(1) <= Q_SIG(1);
    q(0) <= Q_SIG(0);
    
end Struct ; -- Struct