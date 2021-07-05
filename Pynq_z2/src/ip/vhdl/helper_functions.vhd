
library ieee;
  use ieee.std_logic_1164.all;

package helper_functions is

  function slv_to_string (vec_in: std_logic_vector) return string;

  function is_all (vec : std_logic_vector; val : std_logic) return boolean;

end package helper_functions;

package body helper_functions is

  function slv_to_string (vec_in: std_logic_vector) return string is
    variable v_str_out   : string (vec_in'length downto 1) := (others => NUL);
    variable v_str_index : integer := 1;
  begin
    for vec_index in vec_in'reverse_range loop
      v_str_out(v_str_index) := std_logic'image(vec_in((vec_index)))(2);
      v_str_index := v_str_index + 1;
    end loop;
    return v_str_out;
  end function;

  function is_all (vec : std_logic_vector; val : std_logic) return boolean is
    constant ALL_BITS : std_logic_vector(vec'range) := (others => val);
  begin
    return vec = ALL_BITS;
  end function;

end package body helper_functions;
