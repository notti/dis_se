library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.all;

use work.procedures.all;


entity mp_stage2 is
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
end mp_stage2;

architecture Structural of mp_stage2 is
    signal c1  : t_data;
    signal c2  : t_data;
    signal a1  : t_data;
    signal b1  : t_data;
    signal a2  : t_data;
    signal b2  : t_data;
begin

a1 <= val_in(to_integer(unsigned(cmd_in.s2_in1a)));
b1 <= val_in(to_integer(unsigned(cmd_in.s2_in1b)));
a2 <= val_in(to_integer(unsigned(cmd_in.s2_in2a)));
b2 <= val_in(to_integer(unsigned(cmd_in.s2_in2b)));

p: process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            cmd_out <= empty_vliw;
        else
            cmd_out <= cmd_in;
        end if;
        arg_out <= arg_in;
        vmux: for i in 4 downto 0 loop
            if to_integer(unsigned(cmd_in.s2_out1)) = i then
                val_out(i) <= c1;
            elsif to_integer(unsigned(cmd_in.s2_out2)) = i then
                val_out(i) <= c2;
            else 
                val_out(i) <= val_in(i);
            end if;
        end loop vmux;
    end if;
end process p;

simple_alu_1: entity work.simple_alu
port map(
    clk => clk,
    a => a1,
    b => b1,
    op => cmd_in.s2_op1,
    c => c1
);

simple_alu_2: entity work.simple_alu
port map(
    clk => clk,
    a => a2,
    b => b2,
    op => cmd_in.s2_op2,
    c => c2
);

end Structural;
