Library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity tri_state is 
    generic(trise : time := 2 ns;
            tfall : time := 2 ns;
            this : time := 2 ns);

    port( x : in std_logic;
          en : in std_logic;
          y : out std_logic);
end tri_state;

architecture behav of tri_state is

begin
    one : process   ( x, en)
        begin
            IF ( en = '1' AND x = '1') THEN
            y <= '1' after trise;
            elsif (en = '1' AND x = '0') THEN
            y <= '0' after tfall;
            elsif ( en = '0') THEN -- disable
            y <= 'Z' after THIS;
            ELSE -- INVALID DATA 
            y <= 'X' AFTER ( trise+tfall)/2;
            END IF;

    END process ONE;

end behav ; -- behav
