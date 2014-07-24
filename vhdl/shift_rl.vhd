library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.all;

use work.procedures.all;


entity shift_rl is
    port(
        a       : in  std_logic_vector;
        b       : in  std_logic_vector;
        c       : out std_logic_vector
    );
end shift_rl;

architecture Structural of shift_rl is
    signal a_u : unsigned(a'range);
    signal c_u : unsigned(c'range);
    signal sel : unsigned(2 downto 0);

begin
    a_u <= unsigned(a);
    c <= std_logic_vector(c_u);
    sel <= unsigned(b(2 downto 0));
    with sel select
        c_u <= a_u                 when "000",
               shift_right(a_u, 1) when "001",
               shift_right(a_u, 2) when "010",
               shift_right(a_u, 3) when "011",
               shift_right(a_u, 4) when "100",
               shift_right(a_u, 5) when "101",
               shift_right(a_u, 6) when "110",
               shift_right(a_u, 7) when others;

end Structural;
