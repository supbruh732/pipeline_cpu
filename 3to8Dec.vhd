Library IEEE;
use IEEE.STD_LOGIC_1164.all;


entity Dec3to8 is 
    generic( K: integer := 3;
             N: integer := 8);
    port ( A : in std_logic_vector(K-1 downto 0);
    En : in std_logic; 
     R : out std_logic_vector( N-1 downto 0));
end entity;

architecture Struct of Dec3to8 is
    
    component N_bit_DEC is 
        generic( K: integer := K;
                N: integer := N);
        port ( A : in std_logic_vector(K-1 downto 0);
        En : in std_logic; 
        R : out std_logic_vector( N-1 downto 0));
    end component;

begin

    DEC_GEN_3to8: N_bit_DEC port map (A,EN,R);

end Struct ; -- Struct

