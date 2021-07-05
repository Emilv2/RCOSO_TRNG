
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;
  use ieee.numeric_std.all;

library unisim;
  use unisim.vcomponents.all;

library coso_lib;
  use coso_lib.helper_functions.all;

entity trng is
  generic (
    NB_SAMPLES           : natural := 127;
    NB_SAMPLES_MIN_START : natural := 116;
    NB_SAMPLES_MIN       : natural := 108;
    CSCNT_LOW            : natural := 65;
    CSCNT_HIGH           : natural := 120;
    CSCNT_STEP           : natural := 5;
    CONTROL_MAX          : natural := 60;
    WATCHDOG_MAX         : natural := 63;
    COUNTER_MAX          : natural := 1023
  );
  port (
    clk_i    : in    std_logic;
    ack_i    : in    std_logic;
    enable_i : in    std_logic;
    rand_o   : out   std_logic_vector(1 downto 0);
    valid_o  : out   std_logic;
    ready_o  : out   std_logic;
    failed_o : out   std_logic
  );
end entity trng;

architecture rtl of trng is

  type t_state is (
    WAIT_FOR_RISING_EDGE,
    WAIT_FOR_ZERO_RISING,
    WAIT_FOR_FALLING_EDGE,
    WAIT_FOR_ZERO_FALLING
  );

  type t_controller_state is (
    WAIT_FOR_INVALID,
    WAIT_FOR_VALID,
    MATCHING,
    NEXT_CONFIG,
    WAIT_FOR_INVALID_MATCHED,
    WAIT_FOR_VALID_MATCHED,
    MATCHED,
    FAILED
  );

  signal s_state            : t_state;
  signal s_controller_state : t_controller_state;
  signal s_counter          : std_logic_vector(9 downto 0);
  signal s_prev_counter     : std_logic_vector(9 downto 0);
  signal s_prev_counter_d   : std_logic_vector(9 downto 0);
  signal s_rst_cscnt        : std_logic;
  signal s_ro_out_0         : std_logic;
  signal s_ro_out_1         : std_logic;
  signal s_ro_out_1_n       : std_logic;
  signal s_enable_ro_0      : std_logic;
  signal s_enable_ro_1      : std_logic;
  signal s_beat             : std_logic;
  signal s_valid            : std_logic;
  signal s_valid_o          : std_logic;
  signal s_valid_o_d        : std_logic;
  signal s_ready            : std_logic;
  signal s_ack_d            : std_logic;
  signal s_ack_control      : std_logic;
  signal s_valid_control    : std_logic;
  signal s_valid_control_d  : std_logic;
  signal s_control_0        : std_logic_vector(5 downto 0);
  signal s_control_1        : std_logic_vector(5 downto 0);

begin
  s_ro_out_1_n <= not s_ro_out_1;

  ro_inst_0 : entity coso_lib.mux_ro2
    generic map (
      RO_LENGTH => 3
    )
    port map (
      enable_i  => enable_i,
      control_i => s_control_0,
      output_o  => s_ro_out_0
    );

  ro_inst_1 : entity coso_lib.mux_ro2
    generic map (
      RO_LENGTH => 3
    )
    port map (
      enable_i  => enable_i,
      control_i => s_control_1,
      output_o  => s_ro_out_1
    );

  async_ro_counter_inst : entity coso_lib.async_counter
    generic map (
      MAX => COUNTER_MAX
    )
    port map (
      clk_i      => s_ro_out_1_n,
      rst_i      => s_rst_cscnt,
      overflow_o => open,
      counter_o  => s_counter
    );

  beat_ff : fdce
    port map (
      clr => '0',
      ce  => '1',
      d   => s_ro_out_0,
      c   => s_ro_out_1,
      q   => s_beat
    );

  synchronization : process (s_ro_out_1) is
  begin

    if (rising_edge(s_ro_out_1)) then
         s_ack_d <= ack_i;
    end if;

  end process synchronization;

  reset_counter : process (s_ro_out_1) is
  begin

    if (falling_edge(s_ro_out_1)) then

      case (s_state) is

        when WAIT_FOR_RISING_EDGE =>
          s_rst_cscnt <= '0';
          if (s_beat = '1') then
            s_state <= WAIT_FOR_ZERO_RISING;
            s_prev_counter <= s_counter;
          end if;

        when WAIT_FOR_ZERO_RISING =>
          if (is_all(s_counter, '0')) then
            s_rst_cscnt <= '0';
            s_state <= WAIT_FOR_FALLING_EDGE;
          else
            s_rst_cscnt <= '1';
          end if;

        when WAIT_FOR_FALLING_EDGE =>
          s_rst_cscnt <= '0';
          if (s_beat = '0') then
            s_state <= WAIT_FOR_ZERO_FALLING;
            s_prev_counter <= s_counter;
          end if;

        when WAIT_FOR_ZERO_FALLING =>
          if (is_all(s_counter, '0')) then
            s_rst_cscnt <= '0';
            s_state <= WAIT_FOR_RISING_EDGE;
          else
            s_rst_cscnt <= '1';
          end if;

        when others =>
        s_rst_cscnt <= '0';
        s_state <= WAIT_FOR_RISING_EDGE;

      end case;

    end if;

  end process reset_counter;

  valid : process (s_rst_cscnt, clk_i) is
  begin

    if (s_rst_cscnt = '1') then
      s_valid <= '1';
        s_valid_control <= '1';
    elsif (rising_edge(clk_i)) then
      if (s_ack_d = '1') then
         s_valid <= '0';
      end if;
      if (s_ack_control = '1') then
         s_valid_control <= '0';
      end if;
    end if;

  end process valid;

  synchronization_clk_i : process (clk_i) is
  begin

    if (rising_edge(clk_i)) then
      s_prev_counter_d <= s_prev_counter;
      s_valid_control_d <= s_valid_control;
      s_valid_o_d <= s_valid_o;
    end if;

  end process synchronization_clk_i;

  controller : process (clk_i) is

    variable v_sample_count : natural range 0 to NB_SAMPLES := 0;
    variable v_good_samples : natural range 0 to NB_SAMPLES + 1:= 0;
    variable v_watchdog     : natural range 0 to WATCHDOG_MAX;

  begin

    if (rising_edge(clk_i)) then
      if (enable_i = '0') then
            s_ready <= '0';
            failed_o <= '0';
            s_controller_state <= WAIT_FOR_INVALID;
        v_sample_count := 0;
        v_good_samples := 0;
        v_watchdog     := 0;
            s_control_0 <= (others => '0');
            s_control_1 <= (others => '0');
      else

        case (s_controller_state) is

          when WAIT_FOR_INVALID =>
            v_watchdog := v_watchdog + 1;
            s_ready <= '0';
            failed_o <= '0';
            s_ack_control <= '1';

            if (v_watchdog = WATCHDOG_MAX) then
              v_watchdog := 0;
              s_controller_state <= NEXT_CONFIG;
            end if;

            if (s_valid_control_d = '0') then
              v_watchdog := 0;
              s_controller_state <= WAIT_FOR_VALID;
            end if;

          when WAIT_FOR_VALID =>
            v_watchdog := v_watchdog + 1;
            s_ready <= '0';
            failed_o <= '0';
            s_ack_control <= '0';

            if (v_watchdog = WATCHDOG_MAX) then
              v_watchdog := 0;
              s_controller_state <= NEXT_CONFIG;
            end if;

            if (s_valid_control_d = '1') then
              v_watchdog := 0;
              s_controller_state <= MATCHING;
            end if;

          when MATCHING =>
            s_ready <= '0';
            failed_o <= '0';

            if (to_integer(unsigned(s_prev_counter_d)) < CSCNT_HIGH)  and (to_integer(unsigned(s_prev_counter_d)) > CSCNT_LOW) then
              v_good_samples := v_good_samples + 1;
            end if;

            if (v_sample_count = NB_SAMPLES) and (v_good_samples > NB_SAMPLES_MIN_START) then
              v_good_samples := 0;
              v_sample_count := 0;
              s_controller_state <= WAIT_FOR_INVALID_MATCHED;
            elsif (v_sample_count = NB_SAMPLES) then
              v_good_samples := 0;
              v_sample_count := 0;
              s_controller_state <= NEXT_CONFIG;
            else
              v_sample_count := v_sample_count + 1;
              s_controller_state <= WAIT_FOR_INVALID;
            end if;

          when NEXT_CONFIG =>
            s_ready <= '0';
            failed_o <= '0';
            v_sample_count := 0;
            v_good_samples := 0;

            if (to_integer(unsigned(s_control_0)) < CONTROL_MAX) then
              s_control_0 <= std_logic_vector(unsigned(s_control_0) + 1);
              s_controller_state <= WAIT_FOR_INVALID;
            elsif (to_integer(unsigned(s_control_1)) < CONTROL_MAX) then
              s_control_0 <= (others => '0');
              s_control_1 <= std_logic_vector(unsigned(s_control_1) + 1);
              s_controller_state <= WAIT_FOR_INVALID;
            else
              s_controller_state <= FAILED;
            end if;

          when WAIT_FOR_INVALID_MATCHED =>
            v_watchdog := v_watchdog + 1;
            s_ready <= '1';
            failed_o <= '0';
            s_ack_control <= '1';

            if (v_watchdog = WATCHDOG_MAX) then
              v_watchdog := 0;
              s_controller_state <= NEXT_CONFIG;
            end if;

            if (s_valid_control_d = '0') then
              v_watchdog := 0;
              s_controller_state <= WAIT_FOR_VALID_MATCHED;
            end if;

          when WAIT_FOR_VALID_MATCHED =>
            v_watchdog := v_watchdog + 1;
            s_ready <= '1';
            failed_o <= '0';
            s_ack_control <= '0';

            if (v_watchdog = WATCHDOG_MAX) then
              v_watchdog := 0;
              s_controller_state <= NEXT_CONFIG;
            end if;

            if (s_valid_control_d = '1') then
              v_watchdog := 0;
              s_controller_state <= MATCHED;
            end if;

          when MATCHED =>
            s_ready <= '1';
            failed_o <= '0';

            if (to_integer(unsigned(s_prev_counter_d)) < CSCNT_HIGH)  and (to_integer(unsigned(s_prev_counter_d)) > CSCNT_LOW) then
              v_good_samples := v_good_samples + 1;
            end if;

            if (v_sample_count = NB_SAMPLES) and (v_good_samples > NB_SAMPLES_MIN) then
              v_good_samples := 0;
              v_sample_count := 0;
              s_controller_state <= WAIT_FOR_INVALID_MATCHED;
            elsif (v_sample_count = NB_SAMPLES and (v_good_samples <= NB_SAMPLES_MIN)) then
              v_good_samples := 0;
              v_sample_count := 0;
              s_controller_state <= NEXT_CONFIG;
            else
              v_sample_count := v_sample_count + 1;
              s_controller_state <= WAIT_FOR_INVALID_MATCHED;
            end if;

          when FAILED =>
            s_ready <= '0';
            failed_o <= '1';

          when others =>
            s_ready <= '0';
            failed_o <= '0';
            v_sample_count := 0;
            v_good_samples := 0;
            v_watchdog     := 0;
            s_controller_state <= WAIT_FOR_INVALID;

        end case;

      end if;
    end if;

  end process controller;

  s_valid_o <= s_valid and s_ready;
  valid_o   <= s_valid_o_d;
  ready_o   <= s_ready;

  rand_o <= s_prev_counter_d(1 downto 0);

end architecture rtl;

