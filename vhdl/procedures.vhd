library IEEE;
use IEEE.std_logic_1164.all;

package procedures is

    subtype t_data is std_logic_vector(7 downto 0);
        
    type t_data_array is array(natural range <>) of t_data;

end package;

package body procedures is

end procedures;

