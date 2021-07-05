
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.math_real.all;

library unisim;
  use unisim.vcomponents.all;

library coso_lib;

entity mux_ro2 is
  generic (
    RO_LENGTH : natural;
    MUX_WIDTH : natural := 4
  );
  port (
    enable_i  : in    std_logic;
    control_i : in    std_logic_vector(natural(ceil(log2(real(MUX_WIDTH)))) * RO_LENGTH - 1  downto 0);
    output_o  : out   std_logic
  );
end entity mux_ro2;

architecture rtl of mux_ro2 is

  constant SELECT_WIDTH : natural := natural(ceil(log2(real(MUX_WIDTH))));

  signal s_loop : std_logic_vector(MUX_WIDTH - 1 downto 0);

begin

  open_loop_mux_ro_inst : entity coso_lib.open_loop_mux_ro2
    generic map (
      RO_LENGTH => RO_LENGTH,
      MUX_WIDTH => MUX_WIDTH
    )
    port map (
      input_i   => s_loop,
      enable_i  => enable_i,
      control_i => control_i,
      output_o  => s_loop
    );

  output_mux : entity coso_lib.lut_mux
    port map (
      control_i => control_i(SELECT_WIDTH - 1 downto 0),
      input_i   => s_loop,
      output_o  => output_o
    );

end architecture rtl;

