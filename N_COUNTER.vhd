Library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity N_counter is 
generic( E : integer := 4); -- exponent of N

port ( en : in std_logic;
        clk : in std_logic;
        q: out std_logic_vector( E - 1 downto 0);
        RST: in std_logic := '0';
        status: out std_logic);
end N_counter;

architecture struct of N_counter is 

component DFF_R is 
    generic(tprop : Time  := 10 ps;
            thld : Time := 5 ps;
            tsu   : Time  := 1 ps);
    port( d : in std_logic ;
        clk : in std_logic;
        en  : in std_logic;
        RST : in std_logic := '0';
        q   : out std_logic := '1';
        qn  : out std_logic := '0') ;
end component DFF_R;

component my_nor4e is
    generic (gate_delay : Time := 2 ps);            -- default delay
     port(X3,X2, X1, X0:in STD_LOGIC;
          EN: in std_logic;
          z:out STD_LOGIC);
  end component my_nor4e;

signal cntr_op : std_logic_vector (E  downto 0) ;
signal D_ip : std_logic_vector( E - 1 downto 0) ;
signal status_sig: std_logic := '0';
signal EN_RST: std_logic := '0';
begin
    EN_RST <= en or RST;
cntr_op(0) <= clk;
    gen_cntr: for K in (E - 1) downto  0 generate
        CNTR_BIT: DFF_R port map(D_ip(K), cntr_op((E - 1 ) - K ), EN_RST, RST, cntr_op( (E - 1) - K + 1), D_ip( K ));
    end generate;
 
    q(E - 1 downto 0) <= cntr_op(E downto 1);
 --   gen_status: dff generic map(tprop => 8 ps, thld => 2 ps,tsu => 2 ps) port map(en, clk, en, status_sig);
    gen_nor: my_nor4e port map(cntr_op(E), cntr_op(3), cntr_op(2), cntr_op(1), en, status);
    

end architecture;