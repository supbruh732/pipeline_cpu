Library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity SX4to1 is 
    generic( M: integer := 16;
             E: integer := 4;
             N: integer := 4);
    port ( I : in std_logic_vector(M - 1 downto 0);
           I2: in std_logic_vector(M/4 - 1 downto 0);
           I3: in std_logic_vector(M/2 - 1 downto 0);
           I4: in std_logic_vector(M - 5 downto 0);
           sel: in std_logic_vector( 1 downto 0);
    En : in std_logic; 
     op : out std_logic_vector(M - 1 downto 0));
end entity;

architecture Struct of SX4to1 is
    component Nto1_Mux is 
    generic( E: integer := E;
             N: integer := N);
    port ( I : in std_logic_vector(N - 1 downto 0);
           sel: in std_logic_vector(E - 1 downto 0);
    En : in std_logic; 
     op : out std_logic);
end component;
    signal NUL_SEL: std_logic_vector( 3 downto 0);
    signal inmux: std_logic_vector( 4*M - 1  downto 0);
    signal I_SIG : std_logic_vector( M - 1 downto 0);
    signal I2_SIG : std_logic_vector( M - 1 downto 0);
    signal I3_SIG : std_logic_vector( M - 1 downto 0);
    signal I4_SIG : std_logic_vector( M - 1 downto 0);

begin
    NUL_SEL(3) <= '0';
    NUL_SEL(2) <= '0';
    NUL_SEL(1) <= Sel(1);
    NUL_SEL(0) <= Sel(0);
    I_SIG <= I ;
    GEN_SIGN_X4: for K in M - 1 downto 0 generate
        UPPER: if K > 3 generate  
            I2_SIG(K) <= I2(3);
        end generate; 
        LOWER: if K <= 3 generate  
        I2_SIG(K) <= I2(K);
        end generate;
    end generate;

    GEN_SIGN_X8: for K in M - 1 downto 0 generate
        UPPER: if K > 7 generate  
            I3_SIG(K) <= I3(7);
        end generate;
        LOWER: if K <= 7 generate  
        I3_SIG(K) <= I3(K);
        end generate;
    end generate;

    GEN_SIGN_X12: for K in M - 1 downto 0 generate
        UPPER: if K > 11 generate  
            I4_SIG(K) <= I4(11);
        end generate; 
        LOWER: if K <= 11 generate  
        I4_SIG(K) <= I4(K);
        end generate; 
    end generate;

    gen_sig: for K in (M - 1)  downto 0 generate
        inmux(4*K) <= I_SIG(K);
        inmux(4*K+1) <= I2_SIG(K);
        inmux(4*K+2) <= I3_SIG(K);
        inmux(4*K+3) <= I4_SIG(K);
    end generate;

    GEN_MUX: for K in ( M - 1 ) downto 0 generate
        nbit2_1_MUX: Nto1_Mux port map(inmux(4*K + 3 downto 4*K ),NUL_SEL,en,op(K));
    end generate;

end Struct ; -- Struct
