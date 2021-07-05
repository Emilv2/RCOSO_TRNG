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
  use coso_lib.helper_functions.all;

entity helper_functions_tb is
end entity helper_functions_tb;

architecture rtl of helper_functions_tb is

begin

  tb : process is

    variable v_test_7_downto_0 : std_logic_vector(7 downto 0);
    variable v_test_0_to_7     : std_logic_vector(0 to 7);
    variable v_test_8_downto_1 : std_logic_vector(8 downto 1);
    variable v_test_1_to_8     : std_logic_vector(1 to 8);
    variable v_test_4_to_11    : std_logic_vector(4 to 11);
    variable v_test_0_downto_0 : std_logic_vector(0 downto 0);
    variable v_test_1_downto_1 : std_logic_vector(1 downto 1);
    variable v_test_7_downto_7 : std_logic_vector(7 downto 7);
    variable v_test_0_to_0     : std_logic_vector(0 to 0);
    variable v_test_1_to_1     : std_logic_vector(1 to 1);
    variable v_test_7_to_7     : std_logic_vector(7 to 7);
    variable v_result_1        : string(8 downto 1) := "00001111";
    variable v_result_2        : string(8 downto 1) := "00111001";
    variable v_result_3        : string(8 downto 1) := "01010101";
    variable v_result_4        : string(8 downto 1) := "10101010";
    variable v_result_5        : string(8 downto 1) := "101HLXU-";
    variable v_result_6        : string(1 downto 1) := "1";

  begin

    -- std_logic_vector(7 downto 0)
    v_test_7_downto_0 := "00001111";
    assert (v_result_1 = slv_to_string(v_test_7_downto_0))
      report "test 1a: result is " & slv_to_string(v_test_7_downto_0) & ", but should be " & v_result_1
      severity FAILURE;

    v_test_7_downto_0 := "00111001";
    assert (v_result_2 = slv_to_string(v_test_7_downto_0))
      report "test 1b: result is " & slv_to_string(v_test_7_downto_0) & ", but should be " & v_result_2
      severity FAILURE;

    v_test_7_downto_0 := "01010101";
    assert (v_result_3 = slv_to_string(v_test_7_downto_0))
      report "test 1c: result is " & slv_to_string(v_test_7_downto_0) & ", but should be " & v_result_3
      severity FAILURE;

    v_test_7_downto_0 := "10101010";
    assert (v_result_4 = slv_to_string(v_test_7_downto_0))
      report "test 1d: result is " & slv_to_string(v_test_7_downto_0) & ", but should be " & v_result_4
      severity FAILURE;

    v_test_7_downto_0 := "101HLXU-";
    assert (v_result_5 = slv_to_string(v_test_7_downto_0))
      report "test 1e: result is " & slv_to_string(v_test_7_downto_0) & ", but should be " & v_result_5
      severity FAILURE;

    -- std_logic_vector(0 to 7)
    v_test_0_to_7 := "00001111";
    assert (v_result_1 = slv_to_string(v_test_0_to_7))
      report "test 2a: result is " & slv_to_string(v_test_0_to_7) & ", but should be " & v_result_1
      severity FAILURE;

    v_test_0_to_7 := "00111001";
    assert (v_result_2 = slv_to_string(v_test_0_to_7))
      report "test 2b: result is " & slv_to_string(v_test_0_to_7) & ", but should be " & v_result_2
      severity FAILURE;

    v_test_0_to_7 := "01010101";
    assert (v_result_3 = slv_to_string(v_test_0_to_7))
      report "test 2c: result is " & slv_to_string(v_test_0_to_7) & ", but should be " & v_result_3
      severity FAILURE;

    v_test_0_to_7 := "10101010";
    assert (v_result_4 = slv_to_string(v_test_0_to_7))
      report "test 2d: result is " & slv_to_string(v_test_0_to_7) & ", but should be " & v_result_4
      severity FAILURE;

    v_test_0_to_7 := "101HLXU-";
    assert (v_result_5 = slv_to_string(v_test_0_to_7))
      report "test 2e: result is " & slv_to_string(v_test_0_to_7) & ", but should be " & v_result_5 severity FAILURE;

    -- std_logic_vector(8 downto 1)
    v_test_8_downto_1 := "00001111";
    assert (v_result_1 = slv_to_string(v_test_8_downto_1))
      report "test 3a: result is " & slv_to_string(v_test_8_downto_1) & ", but should be " & v_result_1
      severity FAILURE;

    v_test_8_downto_1 := "00111001";
    assert (v_result_2 = slv_to_string(v_test_8_downto_1))
      report "test 3b: result is " & slv_to_string(v_test_8_downto_1) & ", but should be " & v_result_2
      severity FAILURE;

    v_test_8_downto_1 := "01010101";
    assert (v_result_3 = slv_to_string(v_test_8_downto_1))
      report "test 3c: result is " & slv_to_string(v_test_8_downto_1) & ", but should be " & v_result_3
      severity FAILURE;

    v_test_8_downto_1 := "10101010";
    assert (v_result_4 = slv_to_string(v_test_8_downto_1))
      report "test 3d: result is " & slv_to_string(v_test_8_downto_1) & ", but should be " & v_result_4
      severity FAILURE;

    v_test_8_downto_1 := "101HLXU-";
    assert (v_result_5 = slv_to_string(v_test_8_downto_1))
      report "test 3e: result is " & slv_to_string(v_test_8_downto_1) & ", but should be " & v_result_5
      severity FAILURE;

    -- std_logic_vector(1 to 8)
    v_test_1_to_8 := "00001111";
    assert (v_result_1 = slv_to_string(v_test_1_to_8))
      report "test 4a: result is " & slv_to_string(v_test_1_to_8) & ", but should be " & v_result_1
      severity FAILURE;

    v_test_1_to_8 := "00111001";
    assert (v_result_2 = slv_to_string(v_test_1_to_8))
      report "test 4b: result is " & slv_to_string(v_test_1_to_8) & ", but should be " & v_result_2
      severity FAILURE;

    v_test_1_to_8 := "01010101";
    assert (v_result_3 = slv_to_string(v_test_1_to_8))
      report "test 4c: result is " & slv_to_string(v_test_1_to_8) & ", but should be " & v_result_3
      severity FAILURE;

    v_test_1_to_8 := "10101010";
    assert (v_result_4 = slv_to_string(v_test_1_to_8))
      report "test 4d: result is " & slv_to_string(v_test_1_to_8) & ", but should be " & v_result_4
      severity FAILURE;

    v_test_1_to_8 := "101HLXU-";
    assert (v_result_5 = slv_to_string(v_test_1_to_8))
      report "test 4e: result is " & slv_to_string(v_test_1_to_8) & ", but should be " & v_result_5
      severity FAILURE;

    -- std_logic_vector(4 to 11)
    v_test_4_to_11 := "00001111";
    assert (v_result_1 = slv_to_string(v_test_4_to_11))
      report "test 5a: result is " & slv_to_string(v_test_4_to_11) & ", but should be " & v_result_1
      severity FAILURE;

    v_test_4_to_11 := "00111001";
    assert (v_result_2 = slv_to_string(v_test_4_to_11))
      report "test 5b: result is " & slv_to_string(v_test_4_to_11) & ", but should be " & v_result_2
      severity FAILURE;

    v_test_4_to_11 := "01010101";
    assert (v_result_3 = slv_to_string(v_test_4_to_11))
      report "test 5c: result is " & slv_to_string(v_test_4_to_11) & ", but should be " & v_result_3
      severity FAILURE;

    v_test_4_to_11 := "10101010";
    assert (v_result_4 = slv_to_string(v_test_4_to_11))
      report "test 5d: result is " & slv_to_string(v_test_4_to_11) & ", but should be " & v_result_4
      severity FAILURE;

    v_test_4_to_11 := "101HLXU-";
    assert (v_result_5 = slv_to_string(v_test_4_to_11))
      report "test 5e: result is " & slv_to_string(v_test_4_to_11) & ", but should be " & v_result_5
      severity FAILURE;

    -- std_logic_vector(0 downto 0)
    v_test_0_downto_0 := "1";
    assert (v_result_6 = slv_to_string(v_test_0_downto_0))
      report "test 6: result is " & slv_to_string(v_test_0_downto_0) & ", but should be " & v_result_6
      severity FAILURE;

    -- std_logic_vector(1 downto 1)
    v_test_1_downto_1 := "1";
    assert (v_result_6 = slv_to_string(v_test_1_downto_1))
      report "test 7: result is " & slv_to_string(v_test_1_downto_1) & ", but should be " & v_result_6
      severity FAILURE;

    -- std_logic_vector(7 downto 7)
    v_test_7_downto_7 := "1";
    assert (v_result_6 = slv_to_string(v_test_7_downto_7))
      report "test 8: result is " & slv_to_string(v_test_7_downto_7) & ", but should be " & v_result_6
      severity FAILURE;

    -- std_logic_vector(0 to 0)
    v_test_0_to_0 := "1";
    assert (v_result_6 = slv_to_string(v_test_0_to_0))
      report "test 9: result is " & slv_to_string(v_test_0_to_0) & ", but should be " & v_result_6
      severity FAILURE;

    -- std_logic_vector(1 to 1)
    v_test_1_to_1 := "1";
    assert (v_result_6 = slv_to_string(v_test_1_to_1))
      report "test 10: result is " & slv_to_string(v_test_1_to_1) & ", but should be " & v_result_6
      severity FAILURE;

    -- std_logic_vector(7 to 7)
    v_test_7_to_7 := "1";
    assert (v_result_6 = slv_to_string(v_test_7_to_7))
      report "test 11: result is " & slv_to_string(v_test_7_to_7) & ", but should be " & v_result_6
      severity FAILURE;

  report "Succesfully finished helper functions test" severity NOTE;
    std.env.finish;

  end process tb;

end architecture rtl;
