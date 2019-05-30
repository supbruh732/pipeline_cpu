-- Created by fizzim.pl version 5.20 on 2019:04:25 at 19:16:00 (www.fizzim.com)

library ieee;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity cliff is
port (
  ds : out STD_LOGIC;
  rd : out STD_LOGIC;
  clk : in STD_LOGIC;
  go : in STD_LOGIC;
  rst_n : in STD_LOGIC;
  ws : in STD_LOGIC
);
end cliff;

architecture fizzim of cliff is

-- state bits
subtype state_type is STD_LOGIC_VECTOR(2 downto 0);

constant IDLE: state_type:="000"; -- extra=0 rd=0 ds=0 
constant DLY: state_type:="010"; -- extra=0 rd=1 ds=0 
constant DONE: state_type:="001"; -- extra=0 rd=0 ds=1 
constant readx: state_type:="110"; -- extra=1 rd=1 ds=0 

signal state,nextstate: state_type;
signal ds_internal: STD_LOGIC;
signal rd_internal: STD_LOGIC;

-- comb always block
begin
  COMB: process(state,go,ws) begin
    -- Warning I2: Neither implied_loopback nor default_state_is_x attribute is set on state machine - defaulting to implied_loopback to avoid latches being inferred 
    nextstate <= state; -- default to hold value because implied_loopback is set
    case state is
      when IDLE =>
        if (go = '1') then
          nextstate <= readx;
        else
          nextstate <= IDLE;
        end if;

      when DLY  =>
        if (ws = '1') then
          nextstate <= readx;
        else
          nextstate <= DONE;
        end if;

      when DONE =>
        nextstate <= IDLE;

      when readx =>
        nextstate <= DLY;

      when others =>
            state <= nextstate;
    end case;
  end process;

  -- Assign reg'd outputs to state bits
  ds_internal <= state(0);
  rd_internal <= state(1);

  -- Port renames for vhdl
  ds <= ds_internal;
  rd <= rd_internal;

  -- sequential always block
  FF: process(clk,rst_n,nextstate) begin
    if (rst_n='0') then
      state <= IDLE;
    elsif (rising_edge(clk)) then
      state <= nextstate;
    end if;
  end process;
end fizzim;
