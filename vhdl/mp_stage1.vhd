library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.all;

use work.procedures.all;


entity mp_stage1 is
    port(
        rst     : in  std_logic;
        clk     : in  std_logic;

        cmd_in  : in  t_vliw;
        arg_in  : in  t_data_array(4 downto 0);
        val_in  : in  t_data_array(4 downto 0);

        arg_out : out t_data_array(4 downto 0);
        val_out : out t_data_array(4 downto 0);
        cmd_out : out t_vliw
    );
end mp_stage1;

architecture Structural of mp_stage1 is
    signal cmd_1 : t_vliw;
    signal cmd_2 : t_vliw;
    signal val_1 : t_data_array(4 downto 0);
    signal val_2 : t_data_array(4 downto 0);
    signal val   : t_data_array(4 downto 0);
    signal arg_1 : t_data_array(4 downto 0);
    signal arg_2 : t_data_array(4 downto 0);
    signal c1  : t_data;
    signal c2  : t_data;
    signal a1  : t_data;
    signal b1  : t_data;
    signal a2  : t_data;
    signal b2  : t_data;
    signal bypass : std_logic;
begin

a1 <= index2val(val_in, cmd_in.s1_in1a);
b1 <= index2val(val_in, cmd_in.s1_in1b);
a2 <= index2val(val_in, cmd_in.s1_in2a);
b2 <= index2val(val_in, cmd_in.s1_in2b);

p: process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            cmd_1 <= empty_vliw;
            cmd_2 <= empty_vliw;
        else
            if bypass = '1' then
                cmd_1 <= empty_vliw;
            else
                cmd_1 <= cmd_in;
            end if;
            cmd_2 <= cmd_1;
        end if;
        val_1 <= val_in;
        val_2 <= val_1;
        arg_1 <= arg_in;
        arg_2 <= arg_1;
    end if;
end process p;

complex_alu_1: entity work.complex_alu
port map(
    clk => clk,
    a => a1,
    b => b1,
    op => cmd_in.s1_op1,
    point => cmd_in.s1_point1,
    c => c1
);

complex_alu_2: entity work.complex_alu
port map(
    clk => clk,
    a => a2,
    b => b2,
    op => cmd_in.s1_op2,
    point => cmd_in.s1_point2,
    c => c2
);

bypass <= '1' when cmd_in.noop = '0' and cmd_in.s1_op1 = CALU_NOOP and cmd_in.s1_op2 = CALU_NOOP and cmd_2.noop = '1' else
          '0';

vmux: for i in 4 downto 0 generate
    val(i) <= c1 when to_integer(unsigned(cmd_2.s1_out1)) = i and cmd_2.s1_op1 /= CALU_NOOP else
              c2 when to_integer(unsigned(cmd_2.s1_out2)) = i and cmd_2.s1_op2 /= CALU_NOOP else
              val_2(i);
end generate vmux;

val_out <= val_in when bypass = '1' else
           val;
cmd_out <= cmd_in when bypass = '1' else
           cmd_2;
arg_out <= arg_in when bypass = '1' else
           arg_2;

end Structural;
