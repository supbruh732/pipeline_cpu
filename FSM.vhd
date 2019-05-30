Library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity FSM_BM is 
generic(CNTR : integer := 4);
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
end entity;

architecture behav of FSM_BM is

    component SR_FF is
        generic(tprop : Time  := 12 ps;
        tsu   : Time  := 4 ps);
      port ( S, R, CLK, en: in std_logic;
            Q: out std_logic);
      
    end component SR_FF;

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

component N_counter is 
generic( E : integer := CNTR); -- exponent of N

port ( en : in std_logic;
        clk : in std_logic;
        q: out std_logic_vector( E - 1 downto 0);
        RST : in std_logic := '0';
        status: out std_logic );
end component;
    
    type states is (ready,start,ShiftDec, ADD, SUB, STORE,complete, Load);
    signal next_state,curr_state : states := ready;
    signal en_sig : std_logic := '0';
    signal cntr_sig : std_logic_vector( CNTR - 1 downto 0) ;
    signal en_QP: std_logic := '0';
    signal QP: std_logic := '0';
    signal F_RST: std_logic := '0';
    signal QC_SIG: std_logic;
    signal notCLK: std_logic;
begin
QC_SIG <=( Qc and not F_RST);
    notCLK <= not clk;
    ns_proc : process (curr_state, status, strt_b) is 
    begin
        case curr_state is 
        when start => if status = '1'  then next_state <= complete after 2 ps; 
            elsif (Qc = '1' and QP = '0') then next_state <= SUB after 20 ps;
            elsif (Qc ='0' and QP = '1') then next_state <= ADD after 20 ps;
            else 
                next_state <= store after 20 ps;
            end if;
        when ready => if strt_b = '1' then next_state <= Load after 40 ps; 
            end if;
        when load => next_state <= start after 40 ps;
        when complete => next_state <= ready after 20 ps; 
        when ADD => next_state <= store after 80 ps;
        when SUB => next_state <= store after 80 ps;
        When store =>  next_state <= ShiftDec after 20 ps;
        when ShiftDec =>  next_state <= start after 20 ps;      
        end case;
    end process ns_proc;

    ff1_proc_SS: process is 
    begin
        wait until (clk'event and clk = '1');
        if rst = '1' then curr_state <= ready; 
        else curr_state <= next_state;
        end if;
    end process ff1_proc_SS;

     op_proc: process(curr_state) is
        begin
            case curr_state is 
            when Load => LD_X <= "11" after 1 ps;
            when ADD => ALU <= '0' after 1 ps;
            LD_AC <= "11" after 60 ps;
            when SUB => ALU <= '1' after 1 ps;
            LD_AC <= "11" after 60 ps;
            when store => en_QP <= '1' after 1 ps;
                LD_AC <= "00" after 1 ps;
       
            when ShiftDec =>  en_QP <= '0' after 1 ps;
   
            shift_B <= '1' after 1 ps;
            LD_AC <= "11" after 1 ps;
            LD_X <= "10" after 1 ps;
            en_sig <= '1' after 10 ps;

            when start => en_sig <= '0' after 1 ps;
            shift_B <= '0' after 1 ps;
            LD_AC <= "00" after 1 ps;
            LD_X <= "00" after 1 ps;
            en_QP <= '0' after 2 ps;
                
            when ready => 
                Done <= '0' after 2 ps;
                F_RST <= '0' after 2 ps;
                en_QP <= '0' after 2 ps;
                shift_B <= '0' after 2 ps;
                LD_AC <= "00" after 1 ps;
                LD_X <= "00" after 1 ps;

            when complete => 
                Done <= '1' after 2 ps;
                LD_AC <= "10" after 1 ps;
                LD_X <= "10" after 1 ps;
                shift_B <= '0' after 2 ps;
                F_RST <= '1' after 2 ps;
                en_QP <= '1' after 1 ps;

            end case;
        end process op_proc;
--status <= '0';
   gen_counter: N_counter port map(en_sig, notclk, cntr_sig,RST, status );

   Q_PREV: DFF_R port map(QC_SIG,notclk,en_QP, rst,QP);
   --Q_PREV: SR_FF port map (Qc, RST_SR,clk, en_QP, QP);
end behav;