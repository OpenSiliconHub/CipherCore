-------------------------------------------------------------------
-- Description: Open-loop toggle synchronizer
-------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity toggle_synchronizer is
  generic
  (
    SYNC_STAGES : positive range 2 to 10 := 2
  );
  port 
  (
    src_clk   : in std_logic;
    dest_clk  : in std_logic;
    src_rst   : in std_logic;
    dest_rst  : in std_logic;
    pulse_in  : in std_logic;
    pulse_out : out std_logic
  );
end entity toggle_synchronizer;

-------------------------------------------------------------------
-- Component Declaration
-------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

package toggle_synchronizer_pkg is
  component toggle_synchronizer is
    generic
    (
      SYNC_STAGES : positive range 2 to 10 := 2
    );
    port 
    (
      src_clk   : in std_logic;
      dest_clk  : in std_logic;
      src_rst   : in std_logic;
      dest_rst  : in std_logic;
      pulse_in  : in std_logic;
      pulse_out : out std_logic
    );
  end component toggle_synchronizer;
end package toggle_synchronizer_pkg;


architecture rtl of toggle_synchronizer is

  -- internal signal for the toggle level signal
  signal toggle_bit : std_logic;
  -- destination-domain synchronizer flip-flops
  signal sync_ff : std_logic_vector(SYNC_STAGES-1 downto 0);
  -- add the ASYNC_REG attribute to the signals that capture the async input
  attribute ASYNC_REG : string;
  attribute ASYNC_REG of sync_ff : signal is "TRUE";

begin

  -- Convert pulse to level signal in source clock domain
  pulse_to_level_src_clk_proc: process(src_clk) is
  begin
    if (rising_edge(src_clk)) then
      if src_rst = '1' then
        toggle_bit <= '0';
      else
        if pulse_in = '1' then
          toggle_bit <= not toggle_bit;
        end if;
      end if;
    end if;
  end process pulse_to_level_src_clk_proc;

-- Synchronize and convert level-to-pulse from source clock domain
-- to destination clock domain
  level_to_pulse_dest_clk_proc: process(dest_clk) is
  begin
    if (rising_edge(dest_clk)) then
      if dest_rst = '1' then
        sync_ff   <= (others => '0');
        pulse_out <= '0';
      else
        -- synchronize the pulse signal to the first FF
        sync_ff(0) <= toggle_bit;
        -- synchronize the rest of the FFs
        for stage in 1 to SYNC_STAGES-1 loop
          sync_ff(stage) <= sync_ff(stage - 1);
        end loop;
        pulse_out <= sync_ff(SYNC_STAGES - 1) xor sync_ff(SYNC_STAGES - 2);
      end if;
    end if;
  end process level_to_pulse_dest_clk_proc;

end architecture rtl;