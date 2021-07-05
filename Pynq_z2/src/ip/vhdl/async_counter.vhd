
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.math_real.all;

library coso_lib;

entity async_counter is
  generic (
    MAX : natural := 255
  );
  port (
    clk_i      : in    std_logic; -- clock input
    rst_i      : in    std_logic;
    counter_o  : out   std_logic_vector(integer(ceil(log2(real(MAX + 1)))) - 1 downto 0);
    overflow_o : out   std_logic
  );
end entity async_counter;

architecture rtl of async_counter is

  signal s_q        : std_logic_vector(integer(ceil(log2(real(MAX + 1)))) - 1 downto 0) := (others => '1');
  signal s_overflow : std_logic := '0';

begin

  overflow_o <= s_overflow;

  overflow : process (clk_i, s_q) is
  begin

    if (rising_edge(clk_i)) then
      if (to_integer(unsigned(not s_q)) = MAX) then
        s_overflow <= '1';
      else
        s_overflow <= '0';
      end if;
    end if;

  end process overflow;

  t_ff0 : process (rst_i, clk_i, s_overflow) is
  begin

    if (rst_i = '1')  or (s_overflow = '1') then
      s_q(0) <= '1';
    elsif (rising_edge(clk_i)) then
      s_q(0) <= not s_q(0);
    end if;

  end process t_ff0;

  gen_cnt : for i in 1 to integer(ceil(log2(real(MAX + 1)))) - 1 generate

    t_ff : process (rst_i, s_q(i - 1), s_overflow) is
    begin

      if (rst_i = '1') or (s_overflow = '1') then
        s_q(i) <= '1';
      elsif (rising_edge(s_q(i - 1))) then
        s_q(i) <= not s_q(i);
      end if;

    end process t_ff;

  end generate gen_cnt;

  counter_o <= not s_q;

end architecture rtl;
