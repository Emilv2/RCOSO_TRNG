
library ieee;
  use ieee.std_logic_1164.all;

library unisim;
  use unisim.vcomponents.all;

entity lut_nand is
  port (
    input_a_i : in    std_logic;
    input_b_i : in    std_logic;
    output_o  : out   std_logic
  );
end entity lut_nand;

architecture rtl of lut_nand is

begin

  lut6_inst : component lut6
    generic map (
      init => x"0000FFFFFFFFFFFF"
    )
    port map (
      o  => output_o,
      i0 => '1',
      i1 => '1',
      i2 => '1',
      i3 => '1',
      i4 => input_a_i,
      i5 => input_b_i
    );

end architecture rtl;

