library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity FSM_S is 
generic( N : integer := 4); -- exponent of N

port ( en : in std_logic;
        clk : in std_logic;
        d: in std_logic_vector(N - 1 downto 0 );
        q: out std_logic_vector( N - 1 downto 0);
        qn: out std_logic_vector( N - 1 downto 0);
        RST: in std_logic);
end entity;

architecture Stuct of FSM_S is

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

begin
    GEN_STATES: for K in N - 1 downto 0 generate 
        STATE_BITS: DFF_R port map (d(K),clk,en, RST, q(K), qn(K));

    end generate;

end Stuct ; --FSMStFSMS