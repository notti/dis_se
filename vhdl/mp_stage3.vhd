library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.all;

use work.procedures.all;


entity mp_stage3 is
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
end mp_stage3;

architecture Structural of mp_stage3 is
    signal c1  : t_data;
    signal c2  : t_data;
    signal a1  : t_data;
    signal b1  : t_data;
    signal a2  : t_data;
    signal b2  : t_data;
    signal val : t_data_array(4 downto 0);
    signal cmd : t_vliw;
begin

a1 <= index2val(val_in, cmd_in.s3_in1a);
b1 <= index2val(val_in, cmd_in.s3_in1b);
a2 <= index2val(val_in, cmd_in.s3_in2a);
b2 <= index2val(val_in, cmd_in.s3_in2b);

p: process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            cmd <= empty_vliw;
        else
            cmd <= cmd_in;
        end if;
        arg_out <= arg_in;
        val <= val_in;
    end if;
end process p;

cmd_out <= cmd;
vmux: for i in 4 downto 0 generate
    val_out(i) <= c1 when to_integer(unsigned(cmd.s3_out1)) = i else
                  c2 when to_integer(unsigned(cmd.s3_out2)) = i else
                  val(i);
end generate vmux;

simple_alu_1: entity work.simple_alu
port map(
    clk => clk,
    a => a1,
    b => b1,
    op => cmd_in.s3_op1,
    c => c1
);

simple_alu_2: entity work.simple_alu
port map(
    clk => clk,
    a => a2,
    b => b2,
    op => cmd_in.s3_op2,
    c => c2
);

end Structural;
