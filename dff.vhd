Library IEEE;
use IEEE.STD_LOGIC_1164.all;


entity DFF is 
    generic(tprop : Time  := 12 ps;
            tsu   : Time  := 4 ps);
    port( d : in std_logic;
        clk : in std_logic;
        en  : in std_logic;
        q   : out std_logic;
        qn  : out std_logic);
end DFF;

architecture behav of DFF is


begin

    one : process (clk)
        begin
            if ((clk = '1' and clk'LAST_VALUE = '0') AND en = '1') then
                    -- check if setup req is met
                    if (d'STABLE(tsu)) then
                       if( d = '0') then
                          q <= '0' after tprop;
                           qn <= '1' after tprop;
                         elsif ( d = '1') then
                            q <= '1' after tprop;
                            qn <= '0' after tprop;
                          else -- data invalid
                           q <= 'X';
                            qn <= 'X';
                        END IF;
                    ELSE  -- setup fail
                    q <= 'X';
                    qn <= 'X';
                    END if;
            END if;

        end process one;

end behav ; -- behav