----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 04/15/2020 10:09:30 PM
-- Design Name:
-- Module Name: test_ro - Behavioral
-- Project Name:
-- Target Devices:
-- Tool Versions:
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
  use ieee.numeric_std.all;

library coso_lib;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity up_counter_tb is
  --  Port ( );
end entity up_counter_tb;

architecture rtl of up_counter_tb is

  constant COUNT_WIDTH : integer := 16;
  constant LOOP_MAX    : unsigned(COUNT_WIDTH - 1 downto 0) := (others => '1');
  constant HALF_PERIOD : time := 10 ns;
  constant PERIOD      : time := 2 * HALF_PERIOD;

  signal s_clk         : std_logic := '0';
  signal s_rst         : std_logic;
  signal s_counter_out : std_logic_vector(COUNT_WIDTH - 1  downto 0);

begin

  up_counter_inst_0 : entity coso_lib.up_counter_0
    generic map (
      count_width => COUNT_WIDTH
    )
    port map (
      clk_i     => s_clk,
      rst_i     => s_rst,
      counter_o => s_counter_out
    );

  s_clk <= not s_clk after HALF_PERIOD;

  tb : process is
  begin

    s_rst <= '1';

    wait for PERIOD;
    s_rst <= '0';

    for i in 0 to to_integer(LOOP_MAX) loop
      assert (s_counter_out = std_logic_vector(to_unsigned(i, s_counter_out'length)))
        report "s_counter_out should be " & integer'image(i)
               & ", but is " & integer'image(to_integer(unsigned(s_counter_out)))
        severity FAILURE;
      wait for PERIOD;
    end loop;
    assert (s_counter_out = std_logic_vector(LOOP_MAX))
      report "s_counter_out should be " & integer'image(to_integer(LOOP_MAX))
             & ", but is " & integer'image(to_integer(unsigned(s_counter_out)))
      severity FAILURE;
    wait for PERIOD;
    assert (s_counter_out = std_logic_vector(LOOP_MAX))
      report "s_counter_out should be " & integer'image(to_integer(LOOP_MAX))
             & ", but is " & integer'image(to_integer(unsigned(s_counter_out)))
      severity FAILURE;
    wait for PERIOD;

    s_rst <= '1';
    wait for PERIOD;
    assert (s_counter_out = std_logic_vector(to_unsigned(0, s_counter_out'length)))
      report "s_counter_out should be " & integer'image(0)
             & ", but is " & integer'image(to_integer(unsigned(s_counter_out)))
      severity FAILURE;
    wait for PERIOD;
    assert (s_counter_out = std_logic_vector(to_unsigned(0, s_counter_out'length)))
      report "s_counter_out should be " & integer'image(0)
             & ", but is " & integer'image(to_integer(unsigned(s_counter_out)))
      severity FAILURE;
    s_rst <= '0';
    wait for PERIOD;
    assert (s_counter_out = std_logic_vector(to_unsigned(1, s_counter_out'length)))
      report "s_counter_out should be " & integer'image(1)
             & ", but is " & integer'image(to_integer(unsigned(s_counter_out)))
      severity FAILURE;

  report "End up_counter test" severity NOTE;
    std.env.finish;

  end process tb;

end architecture rtl;
