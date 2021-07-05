
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.math_real.all;

library coso_lib;

entity counter is
  generic (
    MAX : natural := 255
  );
  port (
    clk_i      : in    std_logic; -- clock input
    rst_i      : in    std_logic;
    counter_o  : out   std_logic_vector(integer(ceil(log2(real(MAX + 1)))) - 1 downto 0);
    overflow_o : out   std_logic
  );
end entity counter;

architecture rtl of counter is

  signal s_overflow : std_logic := '0';
  signal s_counter  : unsigned(integer(ceil(log2(real(MAX + 1)))) - 1 downto 0);

begin

  counter : process (rst_i, clk_i) is
  begin

    if (rst_i = '1') then
      s_counter <= (others => '0');
    else
      if (rising_edge(clk_i)) then
        if (s_counter /= MAX) then
          s_counter <= s_counter + 1;
          s_overflow <= '0';
        else
          s_counter <= (others => '0');
          s_overflow <= '1';
        end if;
      end if;
    end if;

  end process counter;

  counter_o  <= std_logic_vector(s_counter);
  overflow_o <= s_overflow;

end architecture rtl;
