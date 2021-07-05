
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.math_real.all;

library unisim;
  use unisim.vcomponents.all;

library coso_lib;

entity open_loop_mux_ro2 is
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
end entity open_loop_mux_ro2;

architecture rtl of open_loop_mux_ro2 is

  constant SELECT_WIDTH : natural := natural(ceil(log2(real(MUX_WIDTH))));

  signal s_wire    : std_logic_vector(RO_LENGTH * MUX_WIDTH - 1 downto 0);
  signal s_control : std_logic_vector(RO_LENGTH * SELECT_WIDTH - 1  downto 0);

  attribute dont_touch : boolean;
  attribute dont_touch of s_wire   : signal is true;

begin

  s_control(SELECT_WIDTH * (RO_LENGTH - 2) - 1 downto 0)
 <= control_i(SELECT_WIDTH * (RO_LENGTH - 2) - 1 downto 0);

  -- When RO is disabled, select the fixed zero input.
  -- We lose 2 ** (log2(MUX_WIDTH) * RO_LENGTH - 4) configuration options,
  -- which is only 4 out of 64 if RO_LENGTH = 3 or 16 out of 256 if RO_LENGTH = 4.
  -- We don't need the extra row of nands, so we gain ~30% speed for RO_LENGTH = 3,
  -- and ~25% for RO_LENGTH = 4.
  -- Since the output is constant the controller doesn't even
  -- have to know about this and will automatically reject them.
  s_control(RO_LENGTH * SELECT_WIDTH - 1 downto (RO_LENGTH - 2) * SELECT_WIDTH)
 <= control_i(RO_LENGTH * SELECT_WIDTH - 1 downto (RO_LENGTH - 2) * SELECT_WIDTH) when enable_i = '1' else
    (others => '1');

  gen_not_mux : for j in 0 to MUX_WIDTH - 1 generate

    not_mux_inst : entity coso_lib.lut_not_mux
      port map (
        control_i => s_control(SELECT_WIDTH - 1 downto 0),
        input_i   => input_i,
        output_o  => s_wire(j)
      );

  end generate gen_not_mux;

  gen_mux_i : for i in 2 to RO_LENGTH generate

    gen_mux_j : for j in 0 to MUX_WIDTH - 1 generate

      gen_mux_row : if i < RO_LENGTH - 1 generate

        lut_mux_inst : entity coso_lib.lut_mux
          port map (
            control_i => s_control(i * SELECT_WIDTH - 1 downto (i - 1) * SELECT_WIDTH),
            input_i   => s_wire((i - 1) * MUX_WIDTH - 1 downto (i - 2) * MUX_WIDTH),
            output_o  => s_wire((i - 1) * MUX_WIDTH + j)
          );

      end generate gen_mux_row;

      gen_mid_mux_row : if i = RO_LENGTH - 1 generate

        gen_other_mid_mux_row : if j < MUX_WIDTH - 1 generate

          lut_mux_inst : entity coso_lib.lut_mux
            port map (
              control_i => s_control(i * SELECT_WIDTH - 1 downto (i - 1) * SELECT_WIDTH),
              input_i   => s_wire((i - 1) * MUX_WIDTH - 1 downto (i - 2) * MUX_WIDTH),
              output_o  => s_wire((i - 1) * MUX_WIDTH + j)
            );

        end generate gen_other_mid_mux_row;

        gen_last_mid_mux_row : if j = MUX_WIDTH - 1 generate

          lut_fixed_mux_inst : entity coso_lib.lut_mux
            port map (
              control_i                       => s_control(i * SELECT_WIDTH - 1 downto (i - 1) * SELECT_WIDTH),
              input_i(MUX_WIDTH - 2 downto 0) => s_wire((i - 1) * MUX_WIDTH - 2 downto (i - 2) * MUX_WIDTH),
              -- one input is fixed to one for disable
              input_i(3) => '1',
              output_o   => s_wire((i - 1) * MUX_WIDTH + j)
            );

        end generate gen_last_mid_mux_row;

      end generate gen_mid_mux_row;

      gen_last_mux_row : if i = RO_LENGTH generate

        lut_mux_inst : entity coso_lib.lut_mux
          port map (
            control_i => s_control(i * SELECT_WIDTH - 1 downto (i - 1) * SELECT_WIDTH),
            input_i   => s_wire((i - 1) * MUX_WIDTH - 1 downto (i - 2) * MUX_WIDTH),
            output_o  => output_o(j)
          );

      end generate gen_last_mux_row;

    end generate gen_mux_j;

  end generate gen_mux_i;

end architecture rtl;

