Library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity TFF_R is 
    generic(tprop : Time  := 12 ps;
            thld : Time := 4 ps;
            tsu   : Time  := 4 ps);
    port( T : in std_logic ;
        clk : in std_logic;
        RST : in std_logic := '0';
        q   : out std_logic := '0');

end TFF_R;

architecture behav of TFF_R is
    signal temp: std_logic := '0';

begin

    one : process (clk,RST)
        begin   
            if ((clk = '1' and clk'LAST_VALUE = '0')  and T /= 'Z' ) then
                    -- check if setup req is met
                    if (T'STABLE(tsu)) then
                       if (T'STABLE(thld)) then
                       if( T = '1') then
                          q <= not temp after tprop - thld; 
                          temp <= not temp ;
                                   
                         elsif ( T = '0') then
                            q <= temp after tprop - thld;
                          else -- data invalid
                           q <= 'X' after tprop - thld; 
                            end if;
                        END IF;
                    ELSE  -- setup fail
                    q <= 'X' after tprop;
                    temp <= 'X' after tprop; 
                    END if;
            END if;
        if (RST = '1') then
        q <= '0' after tprop;
        temp <= '0';
        end if;
        end process one;

end behav ; -- behav