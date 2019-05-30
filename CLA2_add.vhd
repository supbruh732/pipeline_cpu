Library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity CLA_P2 is
generic( N : INTEGER := 16;     --SIZE 2^E = (N)
 	 E : INTEGER := 4);     --EXPONENT part -> 2^(E) = N
port( a : in std_logic_vector( N-1 downto 0) ;
      b : in std_logic_vector( N-1 downto 0) ;
     cin: in std_logic ;
	S: out std_logic_vector(N-1 downto 0);
	OVR: out std_logic; -- for 2's comp
	cout: out std_logic); -- ovr for unsigned
end CLA_P2;

architecture STRUCT of CLA_P2 is 

type Sig_array is array ( 0 to E, 2*N-1 downto 0) of std_logic;
signal grid: Sig_array;      -- prefix grid all connections are done here
signal xCIN : std_logic_vector( N-1 downto 0);
signal MFA_OUT: std_logic_vector(2*N-1 downto 0);
signal Pout: std_logic;
signal V: std_logic;

component my_and is
  generic (gate_delay : Time := 2 ps);            -- default delay
   port(x,y:in STD_LOGIC;
        z:out STD_LOGIC);
end component ;


component my_or is
  generic (gate_delay : Time := 2 ps);            -- default delay
   port(x,y:in STD_LOGIC;
        z:out STD_LOGIC);
end component my_or;

component my_xor is
	generic (gate_delay : Time := 3 ps);            -- default delay
	 port(x,y:in STD_LOGIC;
		  z:out STD_LOGIC);
  end component my_xor;

component MFA is
Port( a, b, cin : in std_logic;
	s, P, G: out std_logic);
end component MFA;

component Bang is
Port( P1, G1, P0 ,G0 : in std_logic ;
	xP, xG : out std_logic);
end component Bang;

begin
xcin(0) <= cin;

GEN_MFA: for M in N-1 downto 0 generate
    N_MFA: MFA port map(a(M),b(M),xcin(M),S(M),MFA_OUT(2*M+1),MFA_OUT(2*M));

end generate;

GEN_MFA_CONN: for L in N-1 downto 0 generate  -- first component to connect to grid wire
    grid(0,2*L+1) <= MFA_OUT(2*L+1);
    grid(0,2*L) <= MFA_OUT(2*L);
end generate;

--P <= MFA_OUT(2*N-1); -- if we want to connect more units in a chain we have P & G outputs avaiable 
--G <= grid(E,(N-2)*2);  --
--G <= MFA_OUT(2*N-2);
-- carry out logic
ANDP : my_and port map (MFA_OUT(2*N-1),xCin(N-1),Pout);
OrOut: my_or port map (MFA_OUT(2*N-2), Pout, V);
cout <= V;

BG_ROW: FOR K in 1 to E generate
	BG_COL: FOR i in (N-2) downto 0 generate
		BANG_CON: IF (((i+1) mod (2**K)) >  (((N-2)+ 1) - (2**(K-1))) mod (2**K)) and ((K + i) > 1) generate
			BANG_INST: Bang port map(grid(K-1,2*i+1),grid(K-1,2*i),grid(K,2*((i-2**(K-1)) + ((N-2) mod 2**K) - (i mod 2**K)) + 1),grid(K,2*((i-2**(K-1)) + ((N-2) mod 2**K) - (i mod 2**K)) ),grid(K,i*2+1),grid(K,i*2));
		end generate;

		SIG_CON: IF (((i+1) mod (2**K)) <= (((N-2)+ 1) - (2**(K-1))) mod (2**K)) and ((K + i) > 1)  generate
			grid(K,2*i + 1) <= grid(K-1,2*i + 1);
			grid(K,2*i) <= grid(K-1,2*i);
		end generate;
	end generate;
end generate;

--case for initial carry
Intial_BG: Bang port map(grid(0,1),grid(0,0),xcin(0),xcin(0),grid(1,1),grid(1,0));

-- case for internal carry
 CARRY_GEN: for R in  1 to N - 1 generate
	xcin(R) <= grid(E,(2*R-2));
end generate;

-- overflow logic

OVRXOR: my_xor port map(xcin(N-1), V, OVR);

end architecture STRUCT;
