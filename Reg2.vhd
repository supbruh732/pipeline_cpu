Library IEEE;
use IEEE.STD_LOGIC_1164.all;


entity reg2R is
    generic (N : integer := 16);
    port ( D : in std_logic_vector(n-1 downto 0);
          clk: in std_logic;
          en : in std_logic;
          RST: in std_logic := '0';
           Q : out std_logic_vector(n-1 downto 0));
end entity reg2R;

architecture struct of reg2R is

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

    GEN1: for I in n - 1 downto 0 generate 
        reg2R1: DFF_R port map (D(I), clk, en, RST, Q(I));
    end generate;

end struct ; -- struct