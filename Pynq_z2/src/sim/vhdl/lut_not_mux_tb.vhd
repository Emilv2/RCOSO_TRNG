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
  use ieee.math_real.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library coso_lib;
  use coso_lib.helper_functions.all;

entity lut_not_mux_tb is
  --  Port ( );
end entity lut_not_mux_tb;

architecture behavioral of lut_not_mux_tb is

  constant PERIOD    : time := 10 ns;
  constant MUX_WIDTH : integer := 4;
  signal   s_input   : std_logic_vector(MUX_WIDTH - 1 downto 0);
  signal   s_control : std_logic_vector(natural(ceil(log2(real(MUX_WIDTH)))) - 1  downto 0);
  signal   s_output  : std_logic;

  -- component ro4_0
  -- port(   s_input : in std_logic;
  --         s_enable : in std_logic;
  --         s_control : in std_logic_vector(4 downto 0);
  --         output : out std_logic );
  -- end component;

begin

  lut_not_mux_inst_0 : entity coso_lib.lut_not_mux
    port map (
      input_i   => s_input,
      control_i => s_control,
      output_o  => s_output
    );

  tb : process is

  begin

    s_input <= "0001";
    s_control <= "00";
    wait for PERIOD;
    assert (s_output = '0') report "s_ro_out should be '0' (inverse of s_input) but is "
                                   & std_logic'image(s_output) & " with input "
                                   & slv_to_string(s_input) & " and select "
                                   & slv_to_string(s_control);

    s_input <= "1111";
    s_control <= "00";
    wait for PERIOD;
    assert (s_output = '0') report "s_ro_out should be '0' (inverse of s_input) but is "
                                   & std_logic'image(s_output) & " with input "
                                   & slv_to_string(s_input) & " and select "
                                   & slv_to_string(s_control);

    s_input <= "1110";
    s_control <= "00";
    wait for PERIOD;
    assert (s_output = '1') report "s_ro_out should be '1' (inverse of s_input) but is "
                                   & std_logic'image(s_output) & " with input "
                                   & slv_to_string(s_input) & " and select "
                                   & slv_to_string(s_control);
    std.env.finish;

    s_input <= "0000";
    s_control <= "00";
    wait for PERIOD;
    assert (s_output = '1') report "s_ro_out should be '1' (inverse of s_input) but is "
                                   & std_logic'image(s_output) & " with input "
                                   & slv_to_string(s_input) & " and select "
                                   & slv_to_string(s_control);
    std.env.finish;

    s_input <= "0010";
    s_control <= "01";
    wait for PERIOD;
    assert (s_output = '0') report "s_ro_out should be '0' (inverse of s_input) but is "
                                   & std_logic'image(s_output) & " with input "
                                   & slv_to_string(s_input) & " and select "
                                   & slv_to_string(s_control);

    s_input <= "1111";
    s_control <= "01";
    wait for PERIOD;
    assert (s_output = '0') report "s_ro_out should be '0' (inverse of s_input) but is "
                                   & std_logic'image(s_output) & " with input "
                                   & slv_to_string(s_input) & " and select "
                                   & slv_to_string(s_control);

    s_input <= "1101";
    s_control <= "01";
    wait for PERIOD;
    assert (s_output = '1') report "s_ro_out should be '1' (inverse of s_input) but is "
                                   & std_logic'image(s_output) & " with input "
                                   & slv_to_string(s_input) & " and select "
                                   & slv_to_string(s_control);
    std.env.finish;

    s_input <= "0000";
    s_control <= "01";
    wait for PERIOD;
    assert (s_output = '1') report "s_ro_out should be '1' (inverse of s_input) but is "
                                   & std_logic'image(s_output) & " with input "
                                   & slv_to_string(s_input) & " and select "
                                   & slv_to_string(s_control);
    std.env.finish;

    s_input <= "0100";
    s_control <= "10";
    wait for PERIOD;
    assert (s_output = '0') report "s_ro_out should be '0' (inverse of s_input) but is "
                                   & std_logic'image(s_output) & " with input "
                                   & slv_to_string(s_input) & " and select "
                                   & slv_to_string(s_control);

    s_input <= "1111";
    s_control <= "10";
    wait for PERIOD;
    assert (s_output = '0') report "s_ro_out should be '0' (inverse of s_input) but is "
                                   & std_logic'image(s_output) & " with input "
                                   & slv_to_string(s_input) & " and select "
                                   & slv_to_string(s_control);

    s_input <= "1011";
    s_control <= "10";
    wait for PERIOD;
    assert (s_output = '1') report "s_ro_out should be '1' (inverse of s_input) but is "
                                   & std_logic'image(s_output) & " with input "
                                   & slv_to_string(s_input) & " and select "
                                   & slv_to_string(s_control);
    std.env.finish;

    s_input <= "0000";
    s_control <= "10";
    wait for PERIOD;
    assert (s_output = '1') report " s_ro_out should be '1' (inverse of s_input) but is "
                                   & std_logic'image(s_output) & "with input "
                                   & slv_to_string(s_input) & " and select "
                                   & slv_to_string(s_control);
    std.env.finish;

    s_input <= "1000";
    s_control <= "11";
    wait for PERIOD;
    assert (s_output = '0') report "s_ro_out should be '0' (inverse of s_input) but is "
                                   & std_logic'image(s_output) & " with input "
                                   & slv_to_string(s_input) & " and select "
                                   & slv_to_string(s_control);

    s_input <= "1111";
    s_control <= "11";
    wait for PERIOD;
    assert (s_output = '0') report "s_ro_out should be '0' (inverse of s_input) but is "
                                   & std_logic'image(s_output) & " with input "
                                   & slv_to_string(s_input) & " and select "
                                   & slv_to_string(s_control);

    s_input <= "0111";
    s_control <= "11";
    wait for PERIOD;
    assert (s_output = '1') report "s_ro_out should be '1' (inverse of s_input) but is "
                                   & std_logic'image(s_output) & " with input "
                                   & slv_to_string(s_input) & " and select "
                                   & slv_to_string(s_control);

    s_input <= "0000";
    s_control <= "11";
    wait for PERIOD;
    assert (s_output = '1') report "s_ro_out should be '1' (inverse of s_input) but is "
                                   & std_logic'image(s_output) & " with input "
                                   & slv_to_string(s_input) & " and select "
                                   & slv_to_string(s_control);

    s_input <= "0XXX";
    s_control <= "11";
    wait for PERIOD;
    assert (s_output = '1') report "s_ro_out should be '1' (inverse of s_input) but is "
                                   & std_logic'image(s_output) & " with input "
                                   & slv_to_string(s_input) & " and select "
                                   & slv_to_string(s_control);

    std.env.finish;

  end process tb;

end architecture behavioral;
