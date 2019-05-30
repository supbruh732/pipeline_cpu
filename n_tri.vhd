Library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity n_tri is
    generic (N : integer := 16);
  port ( X : in std_logic_vector(n-1 downto 0);
        en : in std_logic;
        y: OUT std_logic_vector(n-1 downto 0)) ;
end n_tri;

architecture struct of n_tri is
    component tri_state is 
    generic(trise : time := 2 ps;
            tfall : time := 2 ps;
            this : time := 2 ps);

    port( x : in std_logic;
          en : in std_logic;
          y : out std_logic);
end component tri_state;
    

begin

    Tri_GEN: for I in n - 1 downto 0 generate 
    Tri_N: tri_state port map (X(I), en, Y(I));
end generate;

end struct ; -- struct