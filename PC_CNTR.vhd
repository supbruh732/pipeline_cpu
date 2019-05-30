Library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity PC_CNTR is
    generic( N : integer := 16);
  port (clk : in std_logic;
        PC_LD : in std_logic := '0';
        PC_SEL: in std_logic := '0';
        PC_CONN: in std_logic := '0';
        RST: in std_logic := '0';
        Main_Bus: in std_logic_vector(N - 1 downto 0);
        Q_A: out std_logic_vector(N-1 downto 0);
        Q_R: out std_logic_vector(N-1 downto 0)    
  ) ;
end PC_CNTR;

architecture struct of PC_CNTR is

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

component CLA_P2 is
    generic( N : INTEGER := 16;     --SIZE 2^E = (N)
          E : INTEGER := 4);     --EXPONENT part -> 2^(E) = N
    port( a : in std_logic_vector( N-1 downto 0) ;
          b : in std_logic_vector( N-1 downto 0) ;
         cin: in std_logic ;
        S: out std_logic_vector(N-1 downto 0);
        OVR: out std_logic; -- for 2's comp
        cout: out std_logic); -- ovr for unsigned
    end component CLA_P2;

component tri_state is 
    generic(trise : time := 2 ps;
            tfall : time := 2 ps;
            this : time := 2 ps);

    port( x : in std_logic;
          en : in std_logic;
          y : out std_logic);
end component tri_state;

    signal INC_PC : std_logic;
    signal PCR_B: std_logic_vector(N - 1 downto 0);
    signal Qbus : std_logic_vector(N - 1 downto 0);
    signal CLA_B: std_logic_vector(N - 1 downto 0);

begin 
INC_PC <= not PC_SEL;

CLA: CLA_P2 port map(Qbus,"0000000000000001",'0',CLA_B);

GEN_TRI: for K in ( N - 1 ) downto 0 generate 
    TAddBus: tri_state port map (Qbus(K),PC_CONN,Q_A(K));
end generate;

GEN_PCR: for K in ( N - 1 ) downto 0 generate 
    PC_REG: DFF_R port map(PCR_B(K),clk, PC_LD, RST, Qbus(K));
end generate;

GEN_TRI_MB: for K in ( N - 1 ) downto 0 generate
    TB_MB: tri_state port map(Main_Bus(K),PC_SEL, PCR_B(K));
end generate;

GEN_TRI_CLA: for K in (N - 1) downto 0 generate
    TCLA: tri_state port map(CLA_B(K),INC_PC, PCR_B(K));
end generate;
    Q_R <= Qbus;
end struct ; -- struct