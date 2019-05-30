Library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity Mux16_4_1 is 
    generic (N : integer := 16 );
    port(I : in std_logic_vector( N - 1 downto 0);
         I2 : in std_logic_vector( N - 1 downto 0);
         I3 : in std_Logic_vector( N - 1 downto 0);
         I4 : in std_logic_vector( N - 1 downto 0);
         sel : in std_logic_vector( 1 downto 0);
         EN : in std_logic := '0'; 
         OP: out std_logic_vector( N - 1 downto 0)
    );

end entity;

architecture Struct of Mux16_4_1 is
    component Mux16_2_1 is 
        generic (N : integer := 16 );
        port(I : in std_logic_vector( N - 1 downto 0);
            I2 : in std_logic_vector( N - 1 downto 0);
            sel : in std_logic := '0';
            EN : in std_logic := '0'; 
            OP: out std_logic_vector( N - 1 downto 0)
        );
    end component ;
    signal L_B_out : std_logic_vector( N - 1 downto 0);
    signal R_B_out : std_logic_vector( N - 1 downto 0);

begin
    MAIN_MUX: Mux16_2_1 port map( L_B_out, R_B_out,sel(1), EN, OP);
    LEFT_MUX: Mux16_2_1 port map( I, I2, sel(0), EN, L_B_out);
    RIGHT_MUX: Mux16_2_1 port map( I3, I4, sel(0), EN, R_B_out);
end Struct ; -- Struct
