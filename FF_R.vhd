Library IEEE;
use IEEE.STD_LOGIC_1164.all;


entity DFF_R is 
    generic(tprop : Time  := 12 ps;
            thld : Time := 4 ps;
            tsu   : Time  := 4 ps);
    port( d : in std_logic ;
        clk : in std_logic;
        en  : in std_logic;
        RST : in std_logic := '0';
        q   : out std_logic := '0';
        qn  : out std_logic := '1') ;
end DFF_R;

architecture behav of DFF_R is


begin

    one : process (clk, RST)
        begin
            
            if ((clk = '1' and clk'LAST_VALUE = '0') AND en = '1' and d /= 'Z' ) then
                    -- check if setup req is met
                    if (d'STABLE(tsu)) then
                       if (d'STABLE(thld)) then
                       if( d = '0') then
                          q <= '0' after tprop - thld;
                           qn <= '1' after tprop - thld;
                         elsif ( d = '1') then
                            q <= '1' after tprop - thld;
                            qn <= '0' after tprop - thld;
                          else -- data invalid
                           q <= 'X' after tprop - thld;
                            qn <= 'X' after tprop - thld; 
                            end if;
                        END IF;
                    ELSE  -- setup fail
                    q <= 'X' after tprop;
                    qn <= 'X' after tprop;
                    END if;
            END if;
        if (RST = '1') then
        q <= '0' after tprop;
        qn <= '1' after tprop;
        end if;
        end process one;

end behav ; -- behav