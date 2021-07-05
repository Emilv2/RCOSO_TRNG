
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.math_real.all;

library unisim;
  use unisim.vcomponents.all;

library coso_lib;

entity open_loop_mux_ro is
  generic (
    RO_LENGTH : natural;
    MUX_WIDTH : natural := 4
  );
  port (
    -- input_i will be connected to output_o in mux_ro, used for testing
    input_i   : in    std_logic_vector(MUX_WIDTH - 1 downto 0);
    enable_i  : in    std_logic;
    control_i : in    std_logic_vector(natural(ceil(log2(real(MUX_WIDTH)))) * RO_LENGTH - 1  downto 0);
    output_o  : out   std_logic_vector(MUX_WIDTH - 1 downto 0)
  );
end entity open_loop_mux_ro;

architecture rtl of open_loop_mux_ro is

  constant SELECT_WIDTH : natural := natural(ceil(log2(real(MUX_WIDTH))));

  signal s_wire : std_logic_vector(RO_LENGTH * MUX_WIDTH - 1 downto 0);

  attribute dont_touch : boolean;
  attribute dont_touch of s_wire   : signal is true;

begin

  -- TODO merge nands and mux:
  -- extra configurability for no speed cost

  gen_nand : for i in 0 to MUX_WIDTH - 1 generate

    nand_inst : entity coso_lib.lut_nand
      port map (
        input_a_i => enable_i,
        input_b_i => input_i(i),
        output_o  => s_wire(i)
      );

  end generate gen_nand;

  gen_mux_i : for i in 1 to RO_LENGTH generate

    gen_mux_j : for j in 0 to MUX_WIDTH - 1 generate

      gen_mux_row : if i < RO_LENGTH generate

        lut_mux_inst : entity coso_lib.lut_mux
          port map (
            control_i => control_i(i * SELECT_WIDTH - 1 downto (i - 1) * SELECT_WIDTH),
            input_i   => s_wire(i * MUX_WIDTH - 1 downto (i - 1) * MUX_WIDTH),
            output_o  => s_wire(i * MUX_WIDTH + j)
          );

      end generate gen_mux_row;

      gen_last_mux_row : if i = RO_LENGTH generate

        lut_mux_inst : entity coso_lib.lut_mux
          port map (
            control_i => control_i(i * SELECT_WIDTH - 1 downto (i - 1) * SELECT_WIDTH),
            input_i   => s_wire(i * MUX_WIDTH - 1 downto (i - 1) * MUX_WIDTH),
            output_o  => output_o(j)
          );

      end generate gen_last_mux_row;

    end generate gen_mux_j;

  end generate gen_mux_i;

end architecture rtl;

