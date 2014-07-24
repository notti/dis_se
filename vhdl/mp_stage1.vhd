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
    signal cmd : t_vliw;
    signal val : t_data_array(4 downto 0);
    signal arg : t_data_array(4 downto 0);
    signal c1  : t_data;
    signal c2  : t_data;
    signal a1  : t_data;
    signal b1  : t_data;
    signal a2  : t_data;
    signal b2  : t_data;
begin

a1 <= val_in(to_integer(unsigned(cmd_in.s1_in1a)));
b1 <= val_in(to_integer(unsigned(cmd_in.s1_in1b)));
a2 <= val_in(to_integer(unsigned(cmd_in.s1_in2a)));
b2 <= val_in(to_integer(unsigned(cmd_in.s1_in2b)));

p: process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            cmd <= empty_vliw;
            cmd_out <= empty_vliw;
        else
            cmd <= cmd_in;
            cmd_out <= cmd;
        end if;
        val <= val_in;
        arg <= arg_in;
        arg_out <= arg;
        vmux: for i in 4 downto 0 loop
            if to_integer(unsigned(cmd_in.s1_out1)) = i then
                val_out(i) <= c1;
            elsif to_integer(unsigned(cmd_in.s1_out2)) = i then
                val_out(i) <= c2;
            else 
                val_out(i) <= val(i);
            end if;
        end loop vmux;
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

end Structural;
