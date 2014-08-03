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
    signal umul_c    : t_data;
    signal smul_c    : t_data;
    signal umul      : std_logic_vector(t_data'high*2+1 downto 0);
    signal smul      : std_logic_vector(t_data'high*2+1 downto 0);
    signal umulshift : std_logic_vector(t_data'high*2+1 downto 0);
    signal smulshift : std_logic_vector(t_data'high*2+1 downto 0);
    signal point_1   : std_logic_vector(2 downto 0);
    signal op_1      : std_logic_vector(2 downto 0);
    signal umul_p    : unsigned(0 downto 0);
    signal smul_p    : unsigned(0 downto 0);
begin

p: process(clk)
begin
    if rising_edge(clk) then
        point_1 <= point;
        op_1 <= op;
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

umul_p(0) <= umul(6) when point_1 = "111" else
             umul(5) when point_1 = "110" else
             umul(4) when point_1 = "101" else
             umul(3) when point_1 = "100" else
             umul(2) when point_1 = "011" else
             umul(1) when point_1 = "010" else
             umul(0) when point_1 = "001" else
             '0';

smul_p(0) <= smul(6) when point_1 = "111" else
             smul(5) when point_1 = "110" else
             smul(4) when point_1 = "101" else
             smul(3) when point_1 = "100" else
             smul(2) when point_1 = "011" else
             smul(1) when point_1 = "010" else
             smul(0) when point_1 = "001" else
             '0';

umul_c <= std_logic_vector(unsigned(umulshift(t_data'range)) + umul_p);
smul_c <= std_logic_vector(unsigned(smulshift(t_data'range)) + smul_p);

alu: process(clk)
begin
    if rising_edge(clk) then
        umul <= std_logic_vector(unsigned(a) * unsigned(b));
        smul <= std_logic_vector(signed(a) * signed(b));
        case op is
            when CALU_ADD => 
                imm_c <= std_logic_vector(unsigned(a) + unsigned(b));
            when CALU_SUB =>
                imm_c <= std_logic_vector(unsigned(a) - unsigned(b));
            when CALU_AND =>
                imm_c <= a and b;
            when CALU_OR =>
                imm_c <= a or b;
            when CALU_XOR =>
                imm_c <= a xor b;
            when others =>
                imm_c <= (others => '0');
        end case;
        case op_1 is
            when CALU_ADD | CALU_SUB | CALU_AND | CALU_OR | CALU_XOR =>
                c <= imm_c;
            when CALU_UMUL =>
                c <= umul_c;
            when CALU_SMUL =>
                c <= smul_c;
            when others =>
                c <= (others => '0');
        end case;
    end if;
end process alu;

end Structural;
