Library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity RegFile is
    generic (N : integer := 16;
            M : integer := 16);
  port (WE : in std_logic_vector(3 downto 0);     -- write DCD
        D: in std_logic_vector( n-1 downto 0);
        clk : in std_logic;
        RW_DCD: in std_logic_vector ( 6 downto 0); -- enable for all decoders
        R_0 : in std_logic_vector( n - 1 downto 0); -- scratch reg
        R_A : in std_logic_vector( 3 downto 0);  -- Reg A read DCD
        R_B : in std_logic_vector( 3 downto 0);  -- Reg B read DCD
        FSD : in std_logic_vector( 3 downto 0);  -- flag set DCD
        FRD  :in std_logic_vector( 3 downto 0);  -- flag reset DCD
        FTSD : in std_logic_vector( 3 downto 0);  -- Flag read tri state DCD
        FTSD2: in std_logic_vector( 3 downto 0);  -- 2nd flag read dcd
        B1: out std_logic_vector( n-1 downto 0); -- bus 1 
        B2: out std_logic_vector( n-1 downto 0); -- bus 2
        FRB: out std_logic;                     -- flag read bus
        FRB2: out std_logic;
  	RST_ALL: in std_logic := '0');
end RegFile;

architecture struct of RegFile is

    component dec4to16 is 
    port ( A : in std_logic_vector(3 downto 0);  -- using structure based 4 to 16 dec for testing
          En : in std_logic; 
           R : out std_logic_vector( 15 downto 0));

end component dec4to16; 

    component SR_FF is
        generic(tprop : Time  := 12 ps;
        tsu   : Time  := 4 ps);
      port ( S, R, CLK, en: in std_logic;
            Q: out std_logic); 
    end component SR_FF;

    component reg2R is
        generic (N : integer := 16);
        port ( D : in std_logic_vector(n-1 downto 0);
              clk: in std_logic;
              en : in std_logic;
              RST: in std_logic := '0';
               Q : out std_logic_vector(n-1 downto 0));
    end component reg2R;

    component n_tri is
        generic (N : integer := 16);
      port ( X : in std_logic_vector(n-1 downto 0);
            en : in std_logic;
            y: OUT std_logic_vector(n-1 downto 0)) ;
    end component n_tri;

    component tri_state is 
    generic(trise : time := 2 ps;
            tfall : time := 2 ps;
            this : time := 2 ps);

    port( x : in std_logic;
          en : in std_logic;
          y : out std_logic);
end component tri_state;

component my_or is
  generic (gate_delay : Time := 2 ps);            -- default delay
   port(x,y:in STD_LOGIC;
        z:out STD_LOGIC);
end component my_or;
    
    --signal genout : std_logic_vector(n-1 downto 0);

type int_wire is array (0 to M - 1) of std_logic_vector(n-1 downto 0);

signal reg_out : int_wire;    
signal W_DCD : std_logic_vector(M-1 downto 0);
signal RA_DCD : std_logic_vector( M - 1 downto 0 ); 
signal RB_DCD : std_logic_vector( M - 1 downto 0 );
signal SF : std_logic_vector(M - 1 downto 0 );
signal RF : std_logic_vector(M - 1 downto 0);
signal RF_op: std_logic_vector(M - 1 downto 0);
signal ReadFLG: std_logic_vector(M - 1 downto 0);
signal ReadFLG2: std_logic_vector(M - 1 downto 0);
signal flg2TSB : std_logic_vector(M - 1 downto 0); -- signal between flag and tri state to Tri bus

begin
   gen_RSTF: for I in M - 1 downto 0 generate 
	RSTFN: my_or port map (RST_ALL, RF(I), RF_op(I));
end generate;
    gen1: for K  in 1 to m - 1 generate
        RegRow: reg2R port map(D,clk, W_DCD(K),RST_ALL, reg_out(K));   -- old gen reg port map(D,clk, en(K), reg_out(K));
    end generate;
        
    reg_out(0) <= R_0; -- scratch register

    gen_Tri_A_row: for K in  m - 1 downto 0 generate
            TSB_A: n_tri port map(reg_out(K),RA_DCD(K),B1);   -- old gen n_tri port map(reg_out(K),OEN_A(K),B1);
        end generate;

    gen_Tri_B_row: for K in m - 1  downto 0 generate
        TSB_B: n_tri port map(reg_out(K),RB_DCD(K),B2);
    end generate;

     --   SR_F_PC: SR_FF port map(SF(0),RF_op(0), '0', '0', flg2TSB(0));  -- prevent pc flag from being set by decoder
    flg2TSB(0) <= '0';
   gen_FLGS: for I in m - 1 downto 1 generate
        SR_F: SR_FF port map(SF(I),RF_op(I),CLK, '1', flg2TSB(I));
   end generate;

   gen_FTSB: for I in m - 1 downto 0 generate
        FTSB: tri_state port map(flg2TSB(I),ReadFLG(I),FRB);
   end generate;

   gen_FTSB2: for I in m - 1 downto 0 generate
   FTSB2: tri_state port map(flg2TSB(I),ReadFLG2(I),FRB2);
end generate;

   DCD_W_REG: dec4to16 port map(WE,RW_DCD(0),W_DCD);
   DCD_RA_REG: dec4to16 port map(R_A,RW_DCD(1),RA_DCD);
   DCD_RB_REG: dec4to16 port map(R_B,RW_DCD(2),RB_DCD);
   DCD_SF_SR: dec4to16 port map(FSD,RW_DCD(3),SF);
   DCD_RF_SR: dec4to16 port map(FRD,RW_DCD(4),RF);
   DCD_READ_SR: dec4to16 port map(FTSD,RW_DCD(5),ReadFLG);
   DCD_READ_SR2: dec4to16 port map(FTSD2,RW_DCD(6),ReadFLG2);
end struct ; -- struct