library IEEE;
use IEEE.std_logic_1164.all;

package procedures is

    subtype t_data is std_logic_vector(7 downto 0);
        
    type t_data_array is array(natural range <>) of t_data;
    type t_1array is array(natural range <>) of std_logic;
    type t_2array is array(natural range <>) of std_logic_vector(1 downto 0);
    type t_3array is array(natural range <>) of std_logic_vector(2 downto 0);

    type t_vliw is
        record
            -- fetch_decode
            arg_type     : t_2array(4 downto 0);
            arg_memchunk : t_2array(4 downto 0);
            
            -- indirect_fetch
            arg_assign   : t_3array(4 downto 0);
            mem_fetch    : t_1array(4 downto 0);
            mem_memchunk : t_2array(4 downto 0);

            -- stage 1

            -- stage 2

            -- stage 3

            -- writeback
        end record;
    constant empty_vliw : t_vliw := (
        arg_type => (others => (others => '0')),
        arg_memchunk => (others => (others => '0')),
        arg_assign => (others => (others => '0')),
        mem_fetch => (others => '0'),
        mem_memchunk => (others => (others => '0'))
    );


end package;

package body procedures is

end procedures;

