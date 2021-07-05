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

entity ro5_0 is
  port (
    input_i   : in    std_logic;
    enable_i  : in    std_logic;
    control_i : in    std_logic_vector(3 downto 0);
    output_o  : out   std_logic
  );
end entity ro5_0;

architecture rtl of ro5_0 is

  signal s_1   : std_logic;
  signal s_2   : std_logic;
  signal s_3   : std_logic;
  signal s_4   : std_logic;
  signal s_4a  : std_logic;
  signal s_5   : std_logic;
  signal s_6   : std_logic;
  signal s_7   : std_logic;
  signal s_co0 : std_logic_vector(3 downto 0);
  signal s_co1 : std_logic_vector(3 downto 0);
  signal s_o0  : std_logic_vector(3 downto 0);
  signal s_o1  : std_logic_vector(3 downto 0);

  attribute dont_touch : boolean;

  attribute dont_touch of s_1   : signal is true;
  attribute dont_touch of s_2   : signal is true;
  attribute dont_touch of s_3   : signal is true;
  attribute dont_touch of s_4   : signal is true;
  attribute dont_touch of s_4a  : signal is true;
  attribute dont_touch of s_5   : signal is true;
  attribute dont_touch of s_6   : signal is true;
  attribute dont_touch of s_7   : signal is true;
  attribute dont_touch of s_co0 : signal is true;
  attribute dont_touch of s_co1 : signal is true;
  attribute dont_touch of s_o0  : signal is true;
  attribute dont_touch of s_o1  : signal is true;
  attribute dont_touch of rtl   : architecture is true;

  attribute rloc   : string;
  attribute bel    : string;
  attribute hu_set : string;

  attribute hu_set of mux_0 : label is "ro5_hierarchy";
  attribute rloc of mux_0 : label is "X1Y0";
  attribute bel of mux_0 : label is "A6LUT";

  attribute hu_set of inv_4 : label is "ro5_hierarchy";
  attribute rloc of inv_4 : label is "X1Y0";
  attribute bel of inv_4 : label is "B5LUT";

  attribute hu_set of inv_5 : label is "ro5_hierarchy";
  attribute rloc of inv_5 : label is "X1Y0";
  attribute bel of inv_5 : label is "C5LUT";

  attribute hu_set of inv_6 : label is "ro5_hierarchy";
  attribute rloc of inv_6 : label is "X1Y0";
  attribute bel of inv_6 : label is "D5LUT";

  attribute hu_set of mux_0_carry_0 : label is "ro5_hierarchy";
  attribute rloc of mux_0_carry_0 : label is "X1Y0";
  attribute bel of mux_0_carry_0 : label is "CARRY4";

  attribute hu_set of inv_0 : label is "ro5_hierarchy";
  attribute rloc of inv_0 : label is "X0Y0";
  attribute bel of inv_0 : label is "D5LUT";

  attribute hu_set of inv_1 : label is "ro5_hierarchy";
  attribute rloc of inv_1 : label is "X0Y0";
  attribute bel of inv_1 : label is "C5LUT";

  attribute hu_set of inv_2 : label is "ro5_hierarchy";
  attribute rloc of inv_2 : label is "X0Y0";
  attribute bel of inv_2 : label is "B5LUT";

  attribute hu_set of inv_3 : label is "ro5_hierarchy";
  attribute rloc of inv_3 : label is "X0Y0";
  attribute bel of inv_3 : label is "A5LUT";

  attribute hu_set of inv_3_carry_0 : label is "ro5_hierarchy";
  attribute rloc of inv_3_carry_0 : label is "X0Y0";
  attribute bel of inv_3_carry_0 : label is "CARRY4";

begin

  inv_0 : component lut2
    generic map (
      init => "0100"
    )
    port map (
      o  => s_1,
      i0 => input_i,
      i1 => enable_i
    );

  inv_1 : component lut1
    generic map (
      init => "01"
    )
    port map (
      o  => s_2,
      i0 => s_1
    );

  inv_2 : component lut1
    generic map (
      init => "01"
    )
    port map (
      o  => s_3,
      i0 => s_2
    );

  inv_3 : component lut4
    generic map (
      init => "0101010101010101"
    )
    port map (
      o  => s_4,
      i0 => s_3,
      i1 => control_i(0),
      i2 => control_i(1),
      i3 => control_i(2)
    );

  inv_3_carry_0 : component carry4
    port map (
      co             => s_co0,
      o              => s_o0,
      ci             => '0',
      cyinit         => '0',
      di(3 downto 1) => "000",
      di(0)          => s_4,
      s              => "1110"
    );

  mux_0 : component lut6
    generic map (
      -- mux
      -- select = I4,I5
      -- data = I0, I1, I2. I3
      -- 00: I0
      -- 01: I1 xor 1
      -- 10: I2 xor 1
      -- 11: I3 xor 1
      init => "0000000011111111000011110000111100110011001100111010101010101010"
    )
    port map (
      o  => s_4a,
      i0 => s_co0(0),
      i1 => s_o0(1),
      i2 => s_o0(2),
      i3 => s_o0(3),
      i4 => control_i(0),
      i5 => control_i(1)
    );

  mux_0_carry_0 : component carry4
    port map (
      co             => s_co1,
      o              => s_o1,
      ci             => '1',
      cyinit         => '1',
      di(3 downto 1) => "000",
      di(0)          => '0',
      s(3 downto 1)  => "111",
      s(0)           => s_4a
    );

  inv_4 : component lut5
    generic map (
      init => "11110000111100001100110001010101"
    )
    port map (
      o  => s_5,
      i0 => s_co1(0),
      i1 => s_o1(2),
      i2 => s_o1(3),
      i3 => control_i(2),
      i4 => control_i(3)
    );

  inv_5 : component lut1
    generic map (
      init => "01"
    )
    port map (
      o  => s_6,
      i0 => s_5
    );

  inv_6 : component lut1
    generic map (
      init => "01"
    )
    port map (
      o  => s_7,
      i0 => s_6
    );

  output_o <= s_7;

end architecture rtl;

