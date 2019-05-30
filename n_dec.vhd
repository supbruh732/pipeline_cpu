Library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity N_bit_DEC is 
    generic( K: integer := 4;
             N: integer := 16);
    port ( A : in std_logic_vector(K-1 downto 0);
    En : in std_logic; 
     R : out std_logic_vector( N-1 downto 0));
end entity;

architecture Struct of N_bit_DEC is

component my_and is
generic (gate_delay : Time := 2 ps);            -- default delay
port(x,y:in STD_LOGIC;
    z:out STD_LOGIC);
end component my_and;

signal not_A : std_logic_vector( K-1 downto 0);
type Int_SIG_MAT is array ( 0 to K - 2, N-1 downto 0) of std_logic;
type TT_MAT is array (0 to N - 1, K - 1 downto 0) of std_logic;
signal g_out: int_sig_mat;
signal TT: TT_MAT;
begin

gen_NegA: for I in K - 1 downto 0 generate
    not_A(I) <= not(A(I));
end generate;

gen_TT: for K in 0 to N - 1 generate
    gen_TTC: for I in 3 downto 0 generate  -- should be K - 1 but model sim is having strange index errors if we use K - 1
       TTT: if K/(2**I) mod 2 = 1 generate
          TT(K,I) <= A(I);         -- TT(K,I) <= '1';
       end generate;

       oCND: if K/(2**I) mod 2 /= 1 generate
        TT(K,I) <= not_A(I);       -- TT(K,I) <= '0';
        end generate;
    end generate;
end generate;

MultXAND: for M in N - 1 downto 0 generate
        multi_AND: for J in K - 1 downto  0 generate 
            leaf_AND_COND: if J = 0 generate
                LFAND: my_and port map(TT(M,1), TT(M,0),g_out(J,M));       
            end generate;
            other_AND: if J > 0 and J < K - 1 generate
                CNAND: my_and port map(TT(M,J + 1),g_out(J-1,M),g_out(J,M));
            end generate;
            Final_AND: if J = K-1 generate
                    ENAND: my_and port map(En, g_out(J - 1,M), R(M));
                end generate;
        end generate; 

end generate; 

end architecture;