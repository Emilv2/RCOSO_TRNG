
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity up_counter_0 is
  generic (
    COUNT_WIDTH : integer := 32
  );
  port (
    clk_i     : in    std_logic;
    rst_i     : in    std_logic;
    counter_o : out   std_logic_vector(COUNT_WIDTH - 1 downto 0)
  );
end entity up_counter_0;

architecture rtl of up_counter_0 is

  signal   s_counter_up : unsigned(COUNT_WIDTH - 1  downto 0);
  constant COUNT_MAX    : unsigned(COUNT_WIDTH - 1 downto 0) := (others => '1');

begin

  up_counter : process (clk_i, rst_i) is
  begin

    if (rst_i = '1') then
      s_counter_up <= (others => '0');
    elsif (rising_edge(clk_i)) then
      if (s_counter_up /= COUNT_MAX) then
        s_counter_up <= s_counter_up + 1;
      end if;
    end if;

  end process up_counter;

  counter_o <= std_logic_vector(s_counter_up);

end architecture rtl;
