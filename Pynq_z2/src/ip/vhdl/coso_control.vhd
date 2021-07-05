----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    23:28:20 03/05/2020
-- Design Name:
-- Module Name:    ro2 - Behavioral
-- Project Name:
-- Target Devices:
-- Tool versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity coso_control_0 is
  generic (
    COUNT_WIDTH : integer := 32
  );
  port (
    clk_i              : in    std_logic;
    n_rst_i            : in    std_logic;
    enable_i           : in    std_logic;
    beat_rising_edge_i : in    std_logic;
    count_i            : in    std_logic_vector(COUNT_WIDTH - 1 downto 0);
    high_i             : in    std_logic_vector(COUNT_WIDTH - 1  downto 0);
    low_i              : in    std_logic_vector(COUNT_WIDTH - 1  downto 0);
    control_0_o        : out   std_logic_vector(3 downto 0);
    control_1_o        : out   std_logic_vector(3 downto 0);
    valid_o            : out   std_logic;
    -- for debug
    state_o : out   std_logic_vector(2 downto 0);
    bool_o  : out   boolean
  );
end entity coso_control_0;

architecture rtl of coso_control_0 is

  signal s_control : unsigned(7 downto 0);

  type t_state is (
    IDLE,   -- This is the initial/idle state
    WAIT_1, -- This state initializes the counter, once
    WAIT_2, -- In this state the
    WAIT_3, -- In this state the
    CHECK   -- In this state the
  );

  signal s_state : t_state;

begin

  control_0_o <= std_logic_vector(s_control(3 downto 0));
  --  control_0_o <= (others => '0');
  control_1_o <= std_logic_vector(s_control(7 downto 4));

  state_out : process (s_state) is
  begin

    case (s_state) is

      when(IDLE) =>
        state_o <= "000";
      when(WAIT_1) =>
        state_o <= "001";
      when(WAIT_2) =>
        state_o <= "010";
      when(WAIT_3) =>
        state_o <= "011";
      when(CHECK) =>
        state_o <= "100";

    end case;

  end process state_out;

  state_machine : process (clk_i, n_rst_i) is
  begin

    if (rising_edge(clk_i)) then
      if (n_rst_i = '0') then
        s_state   <= IDLE;
        s_control <= (others => '0');
      else
        if (enable_i = '0') then
          s_state <= IDLE;
        elsif (beat_rising_edge_i = '1') then

          case (s_state) is

            when IDLE =>
              if (enable_i = '1') then
                s_state <= WAIT_1;
              end if;
            when WAIT_1 =>
              s_state <= WAIT_2;
            when WAIT_2 =>
              s_state <= WAIT_3;
            when WAIT_3 =>
              s_state <= CHECK;
            when CHECK =>
              bool_o <= (unsigned(low_i) <= unsigned(count_i) and unsigned(count_i) < unsigned(high_i));
              if (unsigned(low_i) <= unsigned(count_i) and unsigned(count_i) <= unsigned(high_i)) then
                s_state <= CHECK;
                valid_o <= '1';
              else
                s_state   <= WAIT_1;
                valid_o   <= '0';
                s_control <= s_control + 1;
              end if;
            when OTHERS =>
              s_state <= IDLE;

          end case;

        end if;
      end if;
    end if;

  end process state_machine;

end architecture rtl;

