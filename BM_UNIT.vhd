Library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity BM_UNIT is 
        generic( N: integer := 16;
                 E: integer := 4);
    port (START_BOOTH: in std_logic := '1';
          RST: in std_logic := '0';
          clk: in std_logic;
          X : in std_logic_vector( N - 1 downto 0) := "0000000001001101";
          Y : in std_logic_vector( N - 1 downto 0) := "1111111111100111";
          DONE_BOOTH: out std_logic;
          ovr : out std_logic;
          p : out std_logic_vector ( 2*N - 1 downto 0);
          T: out std_logic_vector( N - 1 downto 0 ));
end entity;

architecture STRUCT of BM_UNIT is

component FSM_BM is 
generic(CNTR : integer := E);
 port (strt_b : in std_logic := '0';
        rst: in std_logic :='0';
        clk : in std_logic;
        Done : out std_logic;
        status: inout std_logic := '0';
        shift_B: out std_logic := '0';
        ALU: out std_logic := '0';
        LD_AC: out std_logic_vector(1 downto 0) := "00";
        LD_X : out std_logic_vector(1 downto 0) := "00";
        Qc: in std_logic);
end component ;

component BM is
    generic( N : integer := N;
             E : integer := E);
  port ( X: in std_logic_vector ( N - 1 downto 0);
         Y: in std_logic_vector ( N - 1 downto 0);
         P: out std_logic_vector( 2*N - 1 downto 0);
         T: out std_logic_vector( N - 1 downto 0 );
         clk: in std_logic;
         shift: in std_logic;
         LD_AC: in std_logic_vector( 1 downto 0);  -- 10 -> reset, 11 -> ld reg
         LD_X: in std_logic_vector( 1 downto 0); -- 10 -> reset , 11 -> ld reg 
         ALU: in std_logic; -- 0 add, 1 sub
         RST: in std_logic := '0';
         status: out std_logic;
         Qc: out std_logic; -- current Q
         OVR: out std_logic);
end component BM;


    signal LD_AC_SIG: std_logic_vector( 1 downto 0);
    signal LD_X_SIG: std_logic_vector( 1 downto 0);
    signal ALU_SIG: std_logic;
    signal STATUS_SIG: std_logic;
    signal status_Sig2: std_logic;
    signal QC_SIG: std_logic;
    signal shift_SIG: std_logic;


begin

    FSM_INST: FSM_BM port map(START_BOOTH,RST,clk,DONE_BOOTH,STATUS_SIG2,SHIFT_SIG,ALU_SIG,LD_AC_SIG,LD_X_SIG,QC_SIG);

    BM_INST: BM port map(X, Y, P, T, clk,shift_SIG,LD_AC_SIG,LD_X_SIG,ALU_SIG,RST,STATUS_SIG,QC_SIG,ovr);

end STRUCT ; --BM_UNITTRBM_UNIT