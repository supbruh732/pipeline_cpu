Library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity IR is 
    generic( N: integer := 16);
    port( clk : in std_logic := '0';
          EN: in std_logic := '0';
          RST: in std_logic := '0';
          DATA_BUS: in std_logic_vector( N - 1 downto 0 );
          FSM: out std_logic_vector(N - 1 downto 0 )); 
end entity IR;

architecture Struct of IR is

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

GEN_IR: for K in ( N - 1 ) downto 0 generate
    IR_REG: DFF_R port map ( DATA_BUS(K),clk, en, rst, FSM(K));
end generate;

end Struct ; -- Struct