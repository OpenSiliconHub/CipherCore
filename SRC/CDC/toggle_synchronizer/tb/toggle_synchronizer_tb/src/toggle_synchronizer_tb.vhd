-------------------------------------------------------------------
-- Description: Test bench for the toggle synchronizer
-------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use std.env.all;

use work.toggle_synchronizer_pkg.all;

entity toggle_synchronizer_tb is
  generic
  (
    SYNC_STAGES        : positive range 2 to 10 := 2;
    SRC_CLK_PERIOD_NS  : positive := 10; -- 100 MHz
    DEST_CLK_PERIOD_NS : positive := 8 -- 125 MHz, faster than src_clk by default
  );
end toggle_synchronizer_tb;


architecture sim of toggle_synchronizer_tb is

  -- UUT signals
  signal src_clk   : std_logic;
  signal dest_clk  : std_logic;
  signal src_rst   : std_logic;
  signal dest_rst  : std_logic;
  signal pulse_in  : std_logic;
  signal pulse_out : std_logic;

  -- Clock period constants
  constant SRC_CLK_PERIOD  : time := SRC_CLK_PERIOD_NS * 1 ns;
  constant DEST_CLK_PERIOD : time := DEST_CLK_PERIOD_NS * 1 ns;

begin

  -- Instantiation of the UUT
  uut : entity work.toggle_synchronizer
  generic map 
  (
    SYNC_STAGES => SYNC_STAGES
  )
  port map 
  (
    src_clk   => src_clk,  -- in
    dest_clk  => dest_clk, -- in
    src_rst   => src_rst,  -- in
    dest_rst  => dest_rst, -- in
    pulse_in  => pulse_in, -- in
    pulse_out => pulse_out -- out
  );

  -- Source clock generation with a 10ns clock period (100 MHz clock)
  src_clk_gen_proc : process
  begin
    src_clk <= '0';
    wait for SRC_CLK_PERIOD / 2;
    src_clk <= '1';
    wait for SRC_CLK_PERIOD / 2;
  end process src_clk_gen_proc;

  -- Destination clock generation with a 8ns clock period (125 MHz clock)
  dest_clk_gen_proc : process
  begin
    dest_clk <= '0';
    wait for DEST_CLK_PERIOD / 2;
    dest_clk <= '1';
    wait for DEST_CLK_PERIOD / 2;
  end process dest_clk_gen_proc;

  -- Stimulus process to apply input patterns and control reset
  stimulus_proc : process
  begin
    -- assert reset for few clocks
    src_rst  <= '1';
    dest_rst <= '1';
    pulse_in <= '0';
    wait for maximum(SRC_CLK_PERIOD, DEST_CLK_PERIOD) * 2;
    src_rst  <= '0';
    dest_rst <= '0';

    -- apply input patterns sequentially
    wait for SRC_CLK_PERIOD/2;
    -- pulse_in is high for one clock cycle in src_clk domain
    pulse_in <= '1';
    wait for SRC_CLK_PERIOD;
    pulse_in <= '0';
    -- minimum gap between subsequent pulse inputs
    wait for maximum(SRC_CLK_PERIOD, DEST_CLK_PERIOD) * 2;
    -- pulse_in is high for one clock cycle in src_clk domain
    pulse_in <= '1';
    wait for SRC_CLK_PERIOD;
    pulse_in <= '0';

    -- end simulation
    wait for maximum(SRC_CLK_PERIOD, DEST_CLK_PERIOD) * 5;
    finish;
  end process stimulus_proc;

end architecture sim;