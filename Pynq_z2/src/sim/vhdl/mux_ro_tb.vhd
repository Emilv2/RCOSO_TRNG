----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 04/15/2020 10:09:30 PM
-- Design Name:
-- Module Name: test_ro - Behavioral
-- Project Name:
-- Target Devices:
-- Tool Versions:
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
  use ieee.math_real.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library coso_lib;
  use coso_lib.helper_functions.all;

entity mux_ro_tb is
  --  Port ( );
end entity mux_ro_tb;

architecture behavioral of mux_ro_tb is

  constant PERIOD    : time := 10 ns;
  constant MUX_WIDTH : integer := 4;
  constant RO_LENGTH : integer := 4;
  signal   s_input   : std_logic_vector(MUX_WIDTH - 1 downto 0);
  signal   s_enable  : std_logic;
  signal   s_control : std_logic_vector(natural(ceil(log2(real(MUX_WIDTH)))) * RO_LENGTH - 1  downto 0);
  signal   s_ro_out  : std_logic_vector(MUX_WIDTH - 1 downto 0);

  -- component ro4_0
  -- port(   s_input : in std_logic;
  --         s_enable : in std_logic;
  --         s_control : in std_logic_vector(4 downto 0);
  --         output : out std_logic );
  -- end component;

begin

  open_loop_mux_ro_inst_0 : entity coso_lib.open_loop_mux_ro
    generic map (
      ro_length => 4,
      mux_width => 4
    )
    port map (
      input_i   => s_input,
      enable_i  => s_enable,
      control_i => s_control,
      output_o  => s_ro_out
    );

  tb : process is

    variable v_loop_max : integer;
    variable v_j        : integer;

  begin

    s_control <= (others => '1');
    wait for PERIOD;
    --v_loop_max <= to_integer(unsigned(s_control));
    v_loop_max := to_integer(unsigned(s_control));
    s_control <= (others => '0');

    -- test inverting logic
    s_input     <= (others => '0');
    s_enable    <= '1';
    s_control   <= (others => '0');
    for i in 0 to v_loop_max loop
      wait for PERIOD;
      assert (s_ro_out = not s_input) report "s_ro_out should be ""1111"" (inverse of s_input) but is "
                                             & slv_to_string(s_ro_out)
                                             & " with s_control "
                                             & slv_to_string(s_control)
        severity FAILURE;
      s_control <= std_logic_vector(unsigned(s_control) + 1);
    end loop;

    s_input     <= (others => '1');
    s_enable    <= '1';
    s_control   <= (others => '0');
    for i in 0 to v_loop_max loop
      wait for PERIOD;
      assert (s_ro_out = not s_input) report "s_ro_out should be ""0000"" (inverse of s_input) but is "
                                             & slv_to_string(s_ro_out)
                                             & " with s_control "
                                             & slv_to_string(s_control)
        severity FAILURE;
      s_control <= std_logic_vector(unsigned(s_control) + 1);
    end loop;

    -- test s_enable
    s_input     <= (others => '0');
    s_enable    <= '0';
    s_control   <= (others => '0');
    for i in 0 to v_loop_max loop
      wait for PERIOD;
      assert (s_ro_out = std_logic_vector'("1111")) report "s_ro_out should be ""1111"" when disabled but is "
                                                           & slv_to_string(s_ro_out)
                                                           & " with s_control "
                                                           & slv_to_string(s_control)
        severity FAILURE;
      s_control <= std_logic_vector(unsigned(s_control) + 1);
    end loop;

    s_input     <= (others => '1');
    s_enable    <= '0';
    s_control   <= (others => '0');
    for i in 0 to v_loop_max loop
      wait for PERIOD;
      assert (s_ro_out = std_logic_vector'("1111")) report "s_ro_out should be ""1111"" when disabled but is "
                                                           & slv_to_string(s_ro_out)
                                                           & " with s_control "
                                                           & slv_to_string(s_control)
        severity FAILURE;
      s_control <= std_logic_vector(unsigned(s_control) + 1);
    end loop;

    -- test if the muxes actually work
    s_input     <= "XXX0";
    s_enable    <= '1';
    v_j   := 0;
    s_control   <= std_logic_vector(to_unsigned(v_j, s_control'length));
    while v_j <= v_loop_max loop
      wait for PERIOD;
      assert (s_ro_out = std_logic_vector'("1111")) report "s_ro_out should be ""1111"" but is "
                                                           & slv_to_string(s_ro_out)
                                                           & " with s_control "
                                                           & slv_to_string(s_control)
        severity FAILURE;
      v_j := v_j + MUX_WIDTH;
      s_control <= std_logic_vector(to_unsigned(v_j, s_control'length));
    end loop;

    s_input      <= "XX0X";
    s_enable     <= '1';
    v_j   := 1;
    s_control    <= std_logic_vector(to_unsigned(v_j, s_control'length));
    while (v_j <= v_loop_max) loop
      wait for PERIOD;
      assert (s_ro_out = std_logic_vector'("1111")) report "s_ro_out should be ""1111"" but is "
                                                           & slv_to_string(s_ro_out)
                                                           & " with s_control "
                                                           & slv_to_string(s_control)
        severity FAILURE;
      v_j := v_j + MUX_WIDTH;
      s_control  <= std_logic_vector(to_unsigned(v_j, s_control'length));
    end loop;

    s_input      <= "X0XX";
    s_enable     <= '1';
    v_j   := 2;
    s_control    <= std_logic_vector(to_unsigned(v_j, s_control'length));
    while (v_j <= v_loop_max) loop
      wait for PERIOD;
      assert (s_ro_out = std_logic_vector'("1111")) report "s_ro_out should be ""1111"" but is "
                                                           & slv_to_string(s_ro_out)
                                                           & " with s_control "
                                                           & slv_to_string(s_control)
        severity FAILURE;
      v_j := v_j + MUX_WIDTH;
      s_control  <= std_logic_vector(to_unsigned(v_j, s_control'length));
    end loop;

    s_input      <= "0XXX";
    s_enable     <= '1';
    v_j   := 3;
    s_control    <= std_logic_vector(to_unsigned(v_j, s_control'length));
    while (v_j <= v_loop_max) loop
      wait for PERIOD;
      assert (s_ro_out = std_logic_vector'("1111")) report "s_ro_out should be ""1111"" but is "
                                                           & slv_to_string(s_ro_out)
                                                           & " with s_control "
                                                           & slv_to_string(s_control)
        severity FAILURE;
      v_j := v_j + MUX_WIDTH;
      s_control  <= std_logic_vector(to_unsigned(v_j, s_control'length));
    end loop;

    -- sanity check
    s_input     <= "X0XX";
    s_enable    <= '1';
    v_j   := 3;
    s_control   <= std_logic_vector(to_unsigned(v_j, s_control'length));
    while (v_j  <= v_loop_max) loop
      wait for PERIOD;
      assert (s_ro_out = std_logic_vector'("XXXX")) report "s_ro_out should be ""XXXX"" but is "
                                                           & slv_to_string(s_ro_out)
                                                           & " with s_control "
                                                           & slv_to_string(s_control)
        severity FAILURE;
      v_j := v_j + MUX_WIDTH;
      s_control <= std_logic_vector(to_unsigned(v_j, s_control'length));
    end loop;

    std.env.finish;

  end process tb;

end architecture behavioral;
