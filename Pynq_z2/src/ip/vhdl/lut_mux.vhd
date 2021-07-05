
library ieee;
  use ieee.std_logic_1164.all;

library unisim;
  use unisim.vcomponents.all;

entity lut_mux is
  port (
    input_i   : in    std_logic_vector(3 downto 0);
    control_i : in    std_logic_vector(1  downto 0);
    output_o  : out   std_logic
  );
end entity lut_mux;

architecture rtl of lut_mux is

begin

  mux : component lut6
    generic map (
      init => "1111111100000000111100001111000011001100110011001010101010101010"
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

