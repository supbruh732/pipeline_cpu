Library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity SR_FF is
    generic(tprop : Time  := 12 ps;
    tsu   : Time  := 4 ps);
  port ( S, R, CLK, en: in std_logic;
        Q: out std_logic);
  
end SR_FF;

architecture behav of SR_FF is
 

begin
   one :process(clk, en, R)
   variable mem: std_logic := '0';
     begin
     
        if (clk = '1' and clk'LAST_VALUE = '0' and en = '1' )  then
            -- check if setup req is met
            if (S'STABLE(tsu)) then
               if( S = '1' and R = '0') then
               mem := '1';
                q <= '1' after tprop;
          
                 elsif ( S = '0' and R = '1') then
                    q <= '0' after tprop;
                    mem := '0';
                elsif ( S = '1' and R = '1') then
                    q <= 'Z';
                    mem := 'Z';
                elsif (S = '0' and R = '0') then
                    q <= mem;
         
                  else -- data invalid
                   q <= 'X';
                   mem := 'X';
                END IF;
            ELSE  -- setup fail
            q <= 'X';
            mem := 'X';
            END if;

 

    end if;


    end process;

end behav ; -- behav