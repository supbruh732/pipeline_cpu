Library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity my_booth_downcounter is
--generic (unit_delay: time := 2 ns;
	--		t_hold: time :=  4 ns;
		--	set_up: time := 4 ns);
   port (clk,set:in std_logic;
        Q:out std_logic_vector(3 downto 0));
end my_booth_downcounter;

architecture struct_bdc of my_booth_downcounter is

component my_dff_RS is
 -- generic (unit_delay : Time := 12 ps;
		--		t_hold: Time := 4 ps;
			--	set_up: Time := 4 ps);    
   port(d:in std_logic;
		  clk:in std_logic;
		  enable:in std_logic;
		  reset:in std_logic;
		  q:out std_logic;
		  qu:out std_logic;
		  set:in std_logic
        );
end component;


signal qa,qb,qc,qd,qau,qbu,qcu,qdu:std_logic;
signal vcc:std_logic:='1';
signal gnd:std_logic:='0';

begin
dffA: my_dff_RS
		--generic map(unit_delay, t_hold, set_up)
		port map(qau,clk,vcc,set,qa,qau,gnd);
dffB: my_dff_RS
		--generic map(unit_delay, t_hold, set_up)
		port map(qbu,qa,vcc,set,qb,qbu,gnd);
dffC: my_dff_RS
		--generic map(unit_delay, t_hold, set_up)
		port map(qcu,qb,vcc,set,qc,qcu,gnd);
dffD: my_dff_RS
		--generic map(unit_delay, t_hold, set_up)
		port map(qdu,qc,vcc,set,qd,qdu,gnd);
Q(0)<=qa;
Q(1)<=qb;
Q(2)<=qc;
Q(3)<=qd;
		 

end architecture struct_bdc;
