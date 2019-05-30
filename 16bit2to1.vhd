Library IEEE;
use IEEE.STD_LOGIC_1164.all;


entity Mux16_2_1 is 
    generic (N : integer := 16 );
    port(I : in std_logic_vector( N - 1 downto 0);
         I2 : in std_logic_vector( N - 1 downto 0);
         sel : in std_logic := '0';
         EN : in std_logic := '0'; 
         OP: out std_logic_vector( N - 1 downto 0)
    );

end entity;

architecture Struct of Mux16_2_1 is

    component tri_state is 
            generic(trise : time := 2 ps;
                    tfall : time := 2 ps;
                    this : time := 2 ps);

            port( x : in std_logic;
                en : in std_logic;
                y : out std_logic);
    end component tri_state;

    signal T_BUS : std_logic_vector( N - 1 downto 0); 
    signal SEL_A: std_Logic := '0';
    signal SEL_B: std_logic := '0';

begin
    SEL_A <= not SEL and EN;
    SEL_B <= SEL and EN;

    GEN_TS_GATESA: for K in N - 1 downto 0 generate 
           GENTRIA: tri_state port map(I(K), SEL_A, T_BUS(K));

    end generate; 

    GEN_TS_GATESB: for K in N - 1 downto 0 generate 
    GENTRIB: tri_state port map(I2(K), SEL_B, T_BUS(K));

end generate; 
OP <= T_BUS;

end Struct ; -- Struct
