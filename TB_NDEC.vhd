
Library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_arith.all;


entity TB_DEC is
   
end entity TB_DEC;

architecture structure_proc of TB_DEC is


component N_bit_DEC is 
    generic( K: integer := 4;
             N: integer := 16);
    port ( A : in std_logic_vector(K-1 downto 0);
    En : in std_logic; 
     R : out std_logic_vector( N-1 downto 0));
end component;



signal ip:Std_logic_vector(3 downto 0);
signal op:STD_LOGIC_vector(1 downto 0);

-- signal inp1:std_logic_vector(15 downto 0);
-- signal inp2: std_logic_vector(15 downto 0);
-- signal z:std_logic_vector(15 downto 0);
-- signal xCIN, xCOUT : std_logic;
constant PERIOD : time := 20 ns;

begin
  UUT: N_bit_DEC port map(ip,'1');
 -- UUT: Bang port map(ip(3), ip(2), ip(1), ip(0), op(1), op(0));
P:process
variable index:integer;
 
variable temp:std_logic_vector(3 downto 0);
--variable temp2:std_logic_vector(15 downto 0);
  begin

    for n in 0 to 15 loop  -- in a loop use index variable to get input value
        temp := conv_std_logic_vector(n,4); -- take value of n convert 3 bit vector  
					-- as soon as we assign value to ip

	--temp2 := conv_std_logic_vector((n), 16);
       --  ip <= to_bitvector(temp);
	 ip <= (temp);
	-- inp2 <= (temp2);
        wait for PERIOD; -- wait 8 ns (this time needs to be somewhat larger
                       -- than the worst case circuit delay (6 ns for 2-4 dec)
    end loop; 
    wait;
   end process P;
   
end architecture structure_proc;