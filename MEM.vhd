Library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.std_logic_arith.all;
use STD.textio.all;
use ieee.std_logic_textio.all;

entity MEM is 
    generic( RAM_FILE_PATH : STRING := "D:\Program.txt";
             N : integer := 16;
             M : integer := 255);

    port ( -- D_IN: INOUT std_logic_vector(N - 1 downto 0);
           INIT: out std_logic := '0';
           ADDR: INOUT std_logic_vector(N - 1 downto 0);
           R_ENX: in std_logic := '0';
           W_ENX: in std_logic := '0';
           Data: inout std_logic_vector(N - 1 downto 0));
end entity;

architecture Behav of MEM is
    type memory is array ( 0 to M ) of std_logic_vector(N - 1 downto 0);
    signal RAM : memory;
    signal AD : integer range 0 to M;
    Signal R_EN: std_logic := '0'; 
    Signal W_EN: std_logic := '0';
    Signal D_IN: std_logic_vector(N - 1 downto 0);

    
    file DataFile : text;
begin

    process (ADDR, D_IN,R_ENX,W_ENX, R_EN, W_EN)
        begin
            AD <= conv_integer(ADDR);
            if (W_EN = '1' and R_EN /= '1') then
                RAM(AD) <= D_IN;
                elsif (R_EN = '1' and W_EN /= '1') then
                    Data <= RAM(AD);
                else
              
                if (W_ENX = '1' and R_ENX /= '1') then
                    RAM(AD) <= Data;
                    elsif (R_ENX = '1' and W_ENX /= '1') then
                        Data <= RAM(AD);
                    else
                    Data <="ZZZZZZZZZZZZZZZZ";
                end if;
            end if;
 
        end process;

     one:   process 
                variable v_Iline : line;
                variable d_txt : std_logic_vector( N - 1 downto 0);
                variable D : integer := 0;

            begin
                file_open(DataFile, RAM_FILE_PATH, read_mode);

                while not endfile(DataFile) loop
                    readline(DataFile, v_Iline);
                    read(v_Iline, d_txt);
                    D_IN <= d_txt;
                  --  RAM(D) <= d_txt;
                 ADDR <= conv_std_logic_vector(D,16);
                    wait for 10 ps;
                    W_EN <= '1';
                    wait for 40 ps;
                    W_EN <= '0' ;
                    wait for 40 ps;
                    D := D + 1;
                    wait for 20 ps;
                end loop;
                if (W_EN = '0') then
                ADDR <="ZZZZZZZZZZZZZZZZ";
                end if ;
                wait for 50 ps;
                INIT <= '1' ;
            wait;
        end process;

end Behav ; -- Behav
          