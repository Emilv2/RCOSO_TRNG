
library ieee;
  use ieee.std_logic_1164.all;

-- https://stackoverflow.com/questions/34590157/generic-mux-and-demux-using-generics

package mux_p is

  type slv_array_t is array (natural range <>) of std_logic_vector;

end package mux_p;

package body mux_p is

end package body mux_p;

library ieee;
  use ieee.std_logic_1164.all;
  use work.mux_p;

entity mux is
  generic (
    LEN : natural; -- Bits in each input
    NUM : natural  -- Number of inputs
  );
  port (
    v_i   : in    mux_p.slv_array_t(0 to NUM - 1)(LEN - 1 downto 0);
    sel_i : in    natural range 0 to NUM - 1;
    z_o   : out   std_logic_vector(LEN - 1 downto 0)
  );
end entity mux;

architecture rtl of mux is

begin

  z_o <= v_i(sel_i);

end architecture rtl;

library ieee;
  use ieee.std_logic_1164.all;
  use work.mux_p;

entity demux is
  generic (
    LEN : natural; -- Bits in input
    NUM : natural  -- Number of outputs
  );
  port (
    v_i   : in    std_logic_vector(LEN - 1 downto 0);
    sel_i : in    natural range 0 to NUM - 1;
    z_o   : out   mux_p.slv_array_t(NUM - 1 downto 0)(LEN - 1 downto 0)
  );
end entity demux;

architecture rtl of demux is

begin

  sel : process (v_i, sel_i) is
  begin

    z_o <= (others => (others => '0'));
    z_o(sel_i) <= v_i;

  end process sel;

end architecture rtl;

library ieee;
  use ieee.std_logic_1164.all;
  use work.mux_p;

entity one_bit_demux is
  generic (
    NUM : natural -- Number of outputs
  );
  port (
    v_i   : in    std_logic;
    sel_i : in    natural range 0 to NUM - 1;
    z_o   : out   std_logic_vector(NUM - 1 downto 0)
  );
end entity one_bit_demux;

architecture rtl of one_bit_demux is

begin

  sel : process (v_i, sel_i) is
  begin

    z_o <= (others => '0');
    z_o(sel_i) <= v_i;

  end process sel;

end architecture rtl;
