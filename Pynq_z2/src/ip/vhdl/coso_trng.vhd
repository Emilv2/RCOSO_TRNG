----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    23:28:20 03/05/2020
-- Design Name:
-- Module Name:    ro2 - Behavioral
-- Project Name:
-- Target Devices:
-- Tool versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;

library unisim;
  use unisim.vcomponents.all;

library coso_lib;

entity coso_trng is
  generic (
    COUNT_WIDTH : integer := 32
  );
  port (
    clk_i       : in    std_logic;
    n_rst_i     : in    std_logic;
    enable_i    : in    std_logic;
    low_i       : in    std_logic_vector(COUNT_WIDTH - 1 downto 0);
    high_i      : in    std_logic_vector(COUNT_WIDTH - 1 downto 0);
    manual_i    : in    std_logic;
    control_0_i : in    std_logic_vector(3 downto 0);
    control_1_i : in    std_logic_vector(3 downto 0);
    output_o    : out   std_logic_vector(COUNT_WIDTH - 1 downto 0);
    valid_o     : out   std_logic;
    -- for debug
    counter_output_o : out   std_logic_vector(COUNT_WIDTH - 1 downto 0);
    control_0_o      : out   std_logic_vector(3 downto 0);
    control_1_o      : out   std_logic_vector(3 downto 0);
    state_o          : out   std_logic_vector(2 downto 0)
  );
end entity coso_trng;

architecture rtl of coso_trng is

  signal s_ro_out_0            : std_logic;
  signal s_ro_out_1            : std_logic;
  signal s_beat                : std_logic;
  signal s_beat_last           : std_logic;
  signal s_beat_rising_edge    : std_logic;
  signal s_counter             : std_logic_vector(COUNT_WIDTH - 1  downto 0);
  signal s_control_0           : std_logic_vector(3 downto 0);
  signal s_control_1           : std_logic_vector(3 downto 0);
  signal s_control_automatic_0 : std_logic_vector(3 downto 0);
  signal s_control_automatic_1 : std_logic_vector(3 downto 0);

  attribute dont_touch : boolean;
  attribute dont_touch of rtl : architecture is true;

begin

  counter_output_o <= s_counter;
  s_control_0      <= control_0_i when manual_i = '1' else
                      s_control_automatic_0;
  s_control_1      <= control_1_i when manual_i = '1' else
                      s_control_automatic_1;
  control_0_o      <= s_control_0;
  control_1_o      <= s_control_1;

  ro_inst_0 : entity coso_lib.ro5_0
    port map (
      input_i   => s_ro_out_0,
      enable_i  => enable_i,
      control_i => s_control_0,
      output_o  => s_ro_out_0
    );

  ro_inst_1 : entity coso_lib.ro5_0
    port map (
      input_i   => s_ro_out_1,
      enable_i  => enable_i,
      control_i => s_control_1,
      output_o  => s_ro_out_1
    );

  beat_ff : component fdce
    port map (
      clr => '0',
      ce  => '1',
      d   => s_ro_out_0,
      c   => s_ro_out_1,
      q   => s_beat
    );

  beat_rising_edge : process (clk_i) is
  begin

    if (rising_edge(clk_i)) then
      s_beat_last <= s_beat;
      if (s_beat_last = '0' and s_beat = '1') then
        s_beat_rising_edge <= '1';
      else
        s_beat_rising_edge <= '0';
      end if;
    end if;

  end process beat_rising_edge;

  counter_inst : entity coso_lib.up_counter_0
    generic map (
      COUNT_WIDTH => COUNT_WIDTH
    )
    port map (
      clk_i     => s_ro_out_1,
      rst_i     => s_beat_rising_edge,
      counter_o => s_counter
    );

  control_inst_0 : entity coso_lib.coso_control_0
    generic map (
      COUNT_WIDTH => COUNT_WIDTH
    )
    port map (
      clk_i              => clk_i,
      n_rst_i            => n_rst_i,
      enable_i           => enable_i,
      beat_rising_edge_i => s_beat_rising_edge,
      count_i            => s_counter,
      high_i             => high_i,
      low_i              => low_i,
      control_0_o        => s_control_automatic_0,
      control_1_o        => s_control_automatic_1,
      valid_o            => valid_o,
      state_o            => state_o
    );

end architecture rtl;

