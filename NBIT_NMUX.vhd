Library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity x16bit_2_1MUX is 
    generic( M: integer := 16;
             E: integer := 2;
             N: integer := 2);
    port ( I : in std_logic_vector(M - 1 downto 0);
           I2: in std_logic_vector(M - 1 downto 0);
           sel: in std_logic :='0';
    En : in std_logic; 
     op : out std_logic_vector(M - 1 downto 0));
end entity;

architecture Struct of x16bit_2_1MUX is
    component Nto1_Mux is 
    generic( E: integer := E;
             N: integer := N);
    port ( I : in std_logic_vector(N - 1 downto 0);
           sel: in std_logic_vector(E - 1 downto 0);
    En : in std_logic; 
     op : out std_logic);
end component;

    signal inmux: std_logic_vector( 2*M - 1  downto 0);
    signal sel_nul: std_logic_vector(1 downto 0);
begin
    sel_nul(1) <= '0';
    sel_nul(0) <= sel;
    gen_sig: for K in (M - 1)  downto 0 generate
        inmux(2*K) <= I(K);
        inmux(2*K+1) <= I2(K);
    end generate;

    GEN_2MUX: for G in  M - 1   downto 0 generate
        n2_1_MUX: Nto1_Mux port map(inmux(2*G + 1 downto 2*G ),sel_nul,en,op(G));
    end generate;

end Struct ; -- Struct

