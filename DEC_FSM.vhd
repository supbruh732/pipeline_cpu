Library IEEE;
use IEEE.STD_LOGIC_1164.all;


entity DecUnit is 
    generic( N: integer := 16);
    port (  RST: in std_logic := '0';
            ALL_RST: out std_logic := '0'; -- notifies MU FSM Dec is ready to use
            HLT_MC: out std_logic := '0'; -- alerts MC halt read
            clk: in std_logic := '0'; 
            IRD : in std_logic_vector( N - 1 downto 0); -- Instruct reg between Fetch - Dec
            IRE_EN: out std_logic := '0'; -- instruct reg between Dec - EXE
            -- regfile interface-- 
            RW_DCD: out std_logic_vector(6 downto 0); -- main enable decoder
            R_A: out std_logic_vector(3 downto 0);  -- decoder for Register bus A
            R_B: out std_logic_vector( 3 downto 0); -- decoder for Register bus B
            WE : out std_logic_vector(3 downto 0); -- decoder for write register
            FSD: out std_logic_vector( 3 downto 0);  -- decoder for seting flag
            FRD: out std_logic_vector( 3 downto 0);  -- decoder for reseting flag
            FTSD: out std_logic_vector( 3 downto 0);  -- decoder for reading first reg flag
            FTSD2: out std_logic_vector( 3 downto 0); -- 2nd flag read for 2nd operand
            FRB: in std_logic;  -- read bus for write flag A 
            FRB2: in std_logic; -- read bus for write flag B
            Rd1: out std_logic := '0';  -- RegA
            Rd2: out std_logic := '0';  -- RegB
            -- inter handshake --
            NewD: out std_logic;
            DoneE: in std_logic := '0';
            DoneD: out std_logic;
            NewFD: in std_logic := '0';
            XBIT: out std_logic_vector (1 downto 0); -- extend bits for 00 Rd2 01 4bit extend, 10 8 bit extend 11 12bit extend for immed
            imm: out std_logic_vector(11 downto 0);
            FLAGS: in std_logic_vector(4 downto 0); -- 5 bit Status flags reg
            rst_imm: out std_logic := '0'
            );
end entity DecUnit;

architecture Behav of DecUnit is
    type states is (init, Ready, Decode, HLT, CHKFLG, Type1, Type2, Type3, ReadRF, LD_Op, BX);
    signal next_state, curr_state : states := init;
    signal OPCODE : std_logic_vector(3 downto 0);
    signal OperandA: std_logic_vector(3 downto 0);
    signal OperandB: std_logic_vector(3 downto 0);
    Signal OperandC: std_logic_vector(3 downto 0);
    Signal immd12 : std_logic_vector ( 11 downto 0);
    signal rst_imm_sig : std_logic := '0';
    signal T1_SIG: std_logic := '0';
    signal T2_SIG: std_logic := '0';
    signal T3_SIG: std_logic := '0';
    signal Branch: std_logic := '0';
    constant period : time := 15 ps;

begin
    rst_imm <= rst_imm_sig;
    OPCODE <= IRD(N - 1 downto N - 4);
    OperandA <= IRD(N - 5 downto N - 8);
    OperandB <= IRD(N - 9 downto N - 12);
    OperandC <= IRD(N- 13 downto N - 16);
    immd12 <= IRD(N - 5 downto N - 16);
    imm <= immd12;
    CLK_PROC: process is 
    begin
        wait until (clk'event and clk = '1' and clk'last_value = '0');
        if RST = '1' then curr_state <= init;  -- MC either init or hault state
        else curr_state <= next_state after 20 ps;
        end if;
    end process CLK_PROC;

    NS_PROC: process (curr_state, NewFD, DoneE, IRD) is 
    begin
        case curr_state is 

        when init => next_state <= Ready after period;
        when Decode =>
            case OPCODE is
                when "0000" | "0001"| "0011"| "0100"  => next_state <= Type3 after period;
                when "0010"| "0101"| "1100"| "1110" => next_state <= Type2 after period;
                when "1111" => next_state <= HLT after period;                
                when "1101" => next_state <= Type1 after period;
                when "0110" => next_state <= BX after period;
                when others => next_state <= CHKFLG after period;
            end case;

        when HLT => next_state <= HLT after period; 
        when CHKFLG => 
                case OPCODE is 
                    when "0111" => if FLAGS(4) = '1'then next_state <= BX after period; else next_state <= Ready after period; end if;
                    when "1000" => if FLAGS(3) = '1'then next_state <= BX after period; else next_state <= Ready after period; end if;
                    when "1001" => if FLAGS(2) = '1'then next_state <= BX after period; else next_state <= Ready after period; end if;
                    when "1010" => if FLAGS(1) = '1'then next_state <= BX after period; else next_state <= Ready after period; end if;
                    when "1011" => if FLAGS(0) = '1'then next_state <= BX after period; else next_state <= Ready after period; end if;
                    when others => next_state <= Ready;
                end case;

        when TYPE1 => next_state <= ReadRF after period;
        when Type2 => next_state <= ReadRF after period;
        when Type3 => next_state <= ReadRF after period;   

        when ReadRF => if  (FRB = '1' or FRB2 = '1') or DoneE = '0'  then next_state <= ReadRF after period; else next_state <= LD_OP after period; end if;
        when LD_OP => next_state <= ready after period; 
        when BX => if DoneE = '1'then next_state <= LD_op after period; else next_state <= BX after period; end if;
        when Ready => if NewFD = '1' then next_state <= Decode after period; else next_state <= Ready after period; end if;
        end case;

    end process;

    OP_PROC: process(curr_state, FRB, FRB2) is 

    begin

        case curr_state is 

        when init => 
            HLT_MC <= '0' after period;
            ALL_RST <= '1' after period;

        when Ready =>
            rst_imm_sig <= '0';
            RW_DCD <= "ZZZZZZZ";
            NewD <= '0' ;
            ALL_RST <= '0' ; 
            DoneD <= '1' ; 
            Rd1 <= '0' ;
            Rd2 <= '0' ;
            IRE_EN <= '0'; 
            XBIT <= "00";
            T1_SIG <= '0';
            T2_SIG <= '0';
            T3_SIG <= '0';
            Branch <= '0';

        when Decode =>
            case OPCODE is
                when "0000" | "0001"| "0011"| "0100"  =>  
                    WE <= OperandA after period;
                    R_A <= OperandB after period;
                    R_B <= OperandC after period;
                    FTSD <= OperandB after period; 
                    FTSD2 <= OperandC after period;
                    DoneD <= '0' after period; 
                    XBIT <= "00";
                    FSD <= OperandA after period; -- set flag since we will be writing to this reg

                when "0010"| "1100" =>  -- ADD imm and Load IMM TYPE 2 opeartion
                    WE <= OperandA after period;
                    R_A <= OperandB after period;
                    FTSD <= OperandB after period; 
                    XBIT <= "01";
                    FSD <= OperandA after period; -- set flag since we will be writing to this reg after period;
                    DoneD <= '0' after period; 
          
                when "1110" =>   --- STORE --- operation
                    R_A <= OperandB after period;
                    R_B <= OPerandA after period;
                    XBIT <= "01"; 
                    DoneD <= '0' after period; 
                    FSD <= "0000" after period;

                when "0101" =>  -- Compare
                    R_A <= OperandA after period;
                    R_B <= OperandB after period;
                    XBIT <= "00";
                    DoneD <= '0' after period;
                    FSD <= "0000" after period; 

                when "1101" => --- LOAD IMM --- OPERATION       
                    WE <= OperandA after period;      
                    XBIT <= "10";
                    FSD <= OperandA after period; -- set flag since we will be writing to this reg after period; after period;
                -- RW_DCD <= "0001000" after period;
                    DoneD <= '0' after period; 
                    FSD <= OperandA after period;

                when "0110" => 
                    XBIT <= "11" after period;
                    DoneD <= '0' after period; 
                    FSD <= "0000" after period;

                when others => XBIT <= "11" after period;
                    DoneD <= '0' after period; 
                    FSD <= "0000" after period;
            end case;

        when HLT =>
            HLT_MC <= '1' after period; 

        when CHKFLG => 
                XBIT <= "11" after period; 
                DoneD <= '0' after period; 
        when BX =>              
                R_A <= "0000" after period; -- R0 is PC
                RW_DCD <= "0000010" after period;
                XBIT <= "11" after period;  -- offset BX always afterCHKFLG we can set signal early
                DoneD <= '0' after period; 
                Branch <= '1';

        when LD_OP =>
                 if T1_SIG = '1' THEN 
                    Rd2 <='1';
                    RW_DCD <= "0101010";
                    rst_imm_sig <= '1';
            
                 elsif T2_SIG = '1' then
                    Rd1 <= '1';
                    Rd2 <= '1';
                    RW_DCD <= "1101110";
        
                 elsif T3_SIG = '1' then
                    Rd1 <= '1';
                    Rd2 <= '1';
                    RW_DCD <= "1101110";

                elsif Branch = '1' then
                    Rd1 <= '1';
                    Rd2 <= '1';
        
                 end if;

                 IRE_EN <= '1' after 20 ps; 
                 NewD <= '1' after 25 ps;

        when ReadRF =>
                DoneD <= '0' after period; 
              
        when Type1 =>
                T1_SIG <= '1';
        when type2 =>
                T2_SIG <= '1';
        when type3 =>
                T3_SIG <= '1';
           
        when others =>
             RW_DCD <= "ZZZZZZZ";
             XBIT <= "ZZ";
             IRE_EN <= 'Z';
             Rd1 <= 'Z';
             Rd2 <= 'Z';
             NewD <= 'Z';
            
        end case;

    end process;

end Behav ; -- Behav