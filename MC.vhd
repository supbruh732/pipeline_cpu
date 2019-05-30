Library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity MC is 
    port( RST: in std_logic := '0';
          CLK : in std_logic;
          startM: out std_logic := '0';
          startF: out std_logic := '0';
          HLT : in std_logic := '0';
          booted: in std_logic := '0');
end entity MC;

architecture BEHAV of MC is
    type states is (ready, memory, running);
    signal next_state, curr_state : states := ready;
    constant period : time := 40 ps;
begin
    CLK_PROC: process is 
    begin
        wait until (clk'event and clk = '1' and clk'last_value = '0');
        if rst = '1' and HLT = '0' then curr_state <= ready; 
        else curr_state <= next_state;
        end if;
    end process CLK_PROC;

    NS_PROC: process (curr_state,Booted, HLT, RST) is 
    begin
        case curr_state is 
        when ready => if HLT = '1' and RST ='0' then next_state <= Ready after period;
            else
                next_state <= memory after period;
            end if;
        when memory => if booted = '1' then next_state <= running after period;
            else 
                next_state <= memory after period;
            end if;      
        when running => if HLT = '1' then next_state <= Ready after period;
            else 
                next_state <= running after period;
            end if ;
        end case;
    end process NS_PROC;

    OP_PROC: process(curr_state) is 
    begin
        case curr_state is 
        when ready => 
            StartM <= '0';
            StartF <= '0';
        when memory =>
            StartM <= '1';
            StartF <= '0';
        when running =>
            StartM <= '1';
            StartF <= '1';  
        end case;
    end process OP_PROC;

end BEHAV ; -- BEHAV