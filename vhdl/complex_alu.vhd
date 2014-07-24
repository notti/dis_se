library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.all;

use work.procedures.all;


entity complex_alu is
    port(
        clk     : in  std_logic;

        a       : in  t_data;
        b       : in  t_data;
        op      : in  std_logic_vector(2 downto 0);
        point   : in  std_logic_vector(2 downto 0);
        c       : out t_data
    );
end complex_alu;

architecture Structural of complex_alu is
    signal imm_c     : t_data;
    signal umul      : std_logic_vector(t_data'high*2+1 downto 0);
    signal smul      : std_logic_vector(t_data'high*2+1 downto 0);
    signal umulshift : std_logic_vector(t_data'high*2+1 downto 0);
    signal smulshift : std_logic_vector(t_data'high*2+1 downto 0);
    signal point_1   : std_logic_vector(2 downto 0);
    signal point_1_1 : unsigned(2 downto 0);
begin

p: process(clk)
begin
    if rising_edge(clk) then
        point_1 <= point;
        point_1_1 <= unsigned(point) - 1;
    end if;
end process p;

ashift: entity work.shift_ra
port map(
    a => smul,
    b => point_1,
    c => smulshift
);

lshift: entity work.shift_rl
port map(
    a => umul,
    b => point_1,
    c => umulshift
);
-- 0 noop
-- 1 add
-- 2 sub
-- 3 umul
-- 4 smul
-- 5 and
-- 6 or
-- 7 xor
alu: process(clk)
begin
    if rising_edge(clk) then
        case op is
            when "001" => 
                imm_c <= std_logic_vector(unsigned(a) + unsigned(b));
                c <= imm_c;
            when "010" =>
                imm_c <= std_logic_vector(unsigned(a) - unsigned(b));
                c <= imm_c;
            when "011" =>
                umul <= std_logic_vector(unsigned(a) * unsigned(b));
                if point_1 = "000" then
                    c <= umulshift(t_data'range);
                elsif umul(to_integer(point_1_1)) = '1' then
                    c <= std_logic_vector(unsigned(umulshift(t_data'range)) + 1);
                else
                    c <= umulshift(t_data'range);
                end if;
            when "100" =>
                smul <= std_logic_vector(signed(a) * signed(b));
                if point_1 = "000" then
                    c <= smulshift(t_data'range);
                elsif smul(to_integer(point_1_1)) = '1' then
                    c <= std_logic_vector(unsigned(smulshift(t_data'range)) + 1);
                else
                    c <= smulshift(t_data'range);
                end if;
            when "101" =>
                imm_c <= a and b;
                c <= imm_c;
            when "110" =>
                imm_c <= a or b;
                c <= imm_c;
            when "111" =>
                imm_c <= a xor b;
                c <= imm_c;
            when others =>
        end case;
    end if;
end process alu;

end Structural;
