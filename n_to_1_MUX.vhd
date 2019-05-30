Library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity Nto1_Mux is 
    generic( E: integer := 2;
             N: integer := 4);
    port ( I : in std_logic_vector(N - 1 downto 0);
           sel: in std_logic_vector(E - 1 downto 0);
    En : in std_logic; 
     op : out std_logic);
end entity;

architecture struct of Nto1_Mux is

component N_bit_DEC is 
    generic( K: integer := E;
             N: integer := N);
    port ( A : in std_logic_vector(K-1 downto 0);
    En : in std_logic; 
     R : out std_logic_vector( N-1 downto 0));
end component;

component tri_state is 
    generic(trise : time := 2 ps;
            tfall : time := 2 ps;
            this : time := 2 ps);
    port( x : in std_logic;
          en : in std_logic;
          y : out std_logic);
end component tri_state;

    signal en_tri : std_logic_vector( N - 1 downto 0);
    
begin

    init_dec : N_bit_DEC port map(sel,En,en_tri);

    GEN_NTSB: for Z in N - 1 downto 0 generate 
        N_TSB: tri_state port map(I(Z),en_tri(Z),op);
    end generate;

end struct ; --Nto1_MuxtrNto1_Mux