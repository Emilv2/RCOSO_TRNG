
library ieee;
  use ieee.std_logic_1164.all;

library unisim;
  use unisim.vcomponents.all;

entity lut_not_mux is
  port (
    input_i   : in    std_logic_vector(3 downto 0);
    control_i : in    std_logic_vector(1  downto 0);
    output_o  : out   std_logic
  );
end entity lut_not_mux;

architecture rtl of lut_not_mux is

begin

  -- mux with inverted output
  not_mux : component lut6
    generic map (
      init => "0000000011111111000011110000111100110011001100110101010101010101"
    )
    port map (
      o  => output_o,
      i0 => input_i(0),
      i1 => input_i(1),
      i2 => input_i(2),
      i3 => input_i(3),
      i4 => control_i(0),
      i5 => control_i(1)
    );

end architecture rtl;

