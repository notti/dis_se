library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.all;

use work.procedures.all;


entity simple_alu is
    port(
        clk     : in  std_logic;

        a       : in  t_data;
        b       : in  t_data;
        op      : in  std_logic_vector(2 downto 0);
        c       : out t_data
    );
end simple_alu;

architecture Structural of simple_alu is
    signal arith : t_data;
    signal logic : t_data;
begin

ashift: entity work.shift_ra
port map(
    a => a,
    b => b,
    c => arith
);

lshift: entity work.shift_rl
port map(
    a => a,
    b => b,
    c => logic 
);


alu: process(clk)
begin
    if rising_edge(clk) then
        case op is
            when SALU_ADD => c <= std_logic_vector(unsigned(a) + unsigned(b));
            when SALU_SUB => c <= std_logic_vector(unsigned(a) - unsigned(b));
            when SALU_SAR => c <= arith;
            when SALU_SLR => c <= logic;
            when SALU_AND => c <= a and b;
            when SALU_OR  => c <= a or b;
            when SALU_XOR => c <= a xor b;
            when others =>
        end case;
    end if;
end process alu;

end Structural;
