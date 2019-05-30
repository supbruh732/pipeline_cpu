Library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity dec4to16 is 
    port ( A : in std_logic_vector(3 downto 0);
          En : in std_logic; 
           R : out std_logic_vector( 15 downto 0));

end entity; 


architecture struct of dec4to16 is

    component my_and_5 is
        generic (gate_delay : Time := 2 ps);            -- default delay
         port(X3,X2, X1, X0:in STD_LOGIC;
              EN: in std_logic;
              z:out STD_LOGIC);
      end component my_and_5;
    signal not_A : std_logic_vector(3 downto 0);
    
begin
not_A(0) <= not(A(0));
not_A(1) <= not(A(1));
not_A(2) <= not(A(2));
not_A(3) <= not(A(3));


    D0: my_and_5 port map (not_A(0),not_A(1),not_A(2),not_A(3), En, R(0));
    D1: my_and_5 port map (A(0),not_A(1),not_A(2),not_A(3), En, R(1));
    D2: my_and_5 port map (not_A(0),A(1),not_A(2),not_A(3), En, R(2));
    D3: my_and_5 port map (A(0),A(1),not_A(2),not_A(3), En, R(3));
    D4: my_and_5 port map (not_A(0),not_A(1),A(2),not_A(3), En, R(4));
    D5: my_and_5 port map (A(0),not_A(1),A(2),not_A(3), En, R(5));
    D6: my_and_5 port map (not_A(0),A(1),A(2),not_A(3), En, R(6));
    D7: my_and_5 port map (A(0),A(1),A(2),not_A(3), En, R(7));
    D8: my_and_5 port map (not_A(0),not_A(1),not_A(2),A(3), En, R(8));
    D9: my_and_5 port map (A(0),not_A(1),not_A(2),A(3), En, R(9));
    D10: my_and_5 port map (not_A(0),A(1),not_A(2),A(3), En, R(10));
    D11: my_and_5 port map (A(0),A(1),not_A(2),A(3), En, R(11));
    D12: my_and_5 port map (not_A(0),not_A(1),A(2),A(3), En, R(12));
    D13: my_and_5 port map (A(0),not_A(1),A(2),A(3), En, R(13));
    D14: my_and_5 port map (not_A(0),A(1),A(2),A(3), En, R(14));
    D15: my_and_5 port map (A(0),A(1),A(2),A(3), En, R(15));

end struct ; -- struct