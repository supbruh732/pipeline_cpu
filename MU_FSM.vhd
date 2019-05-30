Library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity MU is 
    port( RST: out std_logic := '0';
    CLK : in std_logic;
    ALL_RST: in std_logic := '0';
    startM: in std_logic := '0';
    NewM: out std_logic := '0';
    DoneF: in std_logic := '0';
    M_LD: in std_logic := '0';
    M_W: in std_logic := '0';
    LOAD: out std_logic := '0';
    STORE: out std_logic := '0';
    WB: in std_logic :=  '0';
    booted: out std_logic := '0';
    RNG_SEQ: in std_logic_vector(2 downto 0) := "000");
end entity MU;

architecture Behav of MU is

    type states is (init, boot, standby, ready, W_RAM, L_RAM, cache);
    signal next_state, curr_state : states := init;
    constant period : time := 100 ps;

begin
    CLK_PROC: process is 
    begin
        wait until (clk'event and clk = '1' and clk'last_value = '0');
        if StartM = '0' then curr_state <= init;  -- MC either init or hault state
        else curr_state <= next_state;
        end if;
    end process CLK_PROC;


    NS_PROC: process (curr_state,startM, DoneF,ALL_RST,RNG_SEQ,WB,M_LD,M_W) is
    begin

        case curr_state is 
            when init => if StartM = '1'  then next_state <= boot after period; 
                else 
                    next_state <= init after period;
                end if;
            when boot => if ALL_RST = '1' then next_state <= ready after period;
                else 
                    next_state <= boot after period;
                end if;
            when ready => if M_W = '1' then next_state <= W_RAM after period;
                elsif M_LD = '1' then next_state <= L_RAM after period;
                else 
                    next_state <= ready after period;
                end if;

            when W_RAM => next_state <= ready after period;

            when L_RAM => if WB = '1' then next_state <= L_RAM after period;
                else 
                    next_state <= cache after period; 
                end if; 

            when cache => if RNG_SEQ = "000" then next_state <= standby after period; 
                elsif RNG_SEQ = "001" then next_state <= standby after 2 * period;
                elsif RNG_SEQ = "010" then next_state <= standby after 3 * period;
                elsif RNG_SEQ = "011" then next_state <= standby after 4 * period;
                else 
                    next_state <= standby after 5 * period;
                end if;

            when standby => if DoneF = '1' then next_state <= ready after period;
                else 
                    next_state <= standby after period; 
                end if;
        end case;

    end process; 


    OP_PROC: process(curr_state) is 
    begin
        case curr_state is 
        when boot =>
            RST <= '1';

        when ready => 
            booted <= '1';
            RST <= '0';
            NewM <= '0';
            LOAD <= '0';
            STORE <= '0';

        when W_RAM =>
            NewM <= '0'; 
            STORE <= '1';
            
        when L_RAM =>
            NewM <= '0';
        when cache =>
            LOAD <= '1';

        when standby =>
            NewM <= '1';

        when others =>
            RST <= '0';
            NewM <= '0';
            LOAD <= '0';
            STORE <= '0';
            booted <= '0';
             
        end case;
    end process OP_PROC;

end Behav ; -- Behav