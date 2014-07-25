library IEEE;
        use IEEE.STD_LOGIC_1164.ALL;
        use IEEE.NUMERIC_STD.ALL;
library std;
        use std.textio.all;

library work;
        use work.all;
        use work.procedures.all;

entity tb_simple_alu is
end tb_simple_alu;


architecture behav of tb_simple_alu is
    signal clk : std_logic := '0';
    signal a : t_data := (others => '0');
    signal b : t_data := (others => '0');
    signal op : std_logic_vector(2 downto 0) := (others => '0');
    signal c : t_data := (others => '0');
    type op_type is (op_noop, op_add, op_sub, op_sar, op_slr, op_and, op_or, op_xor);
    type op_arr is array(natural range <>) of op_type;
    signal current_op : op_type;
    signal op_lut : op_arr(7 downto 0) := (
        0 => op_noop,
        1 => op_add,
        2 => op_sub,
        3 => op_sar,
        4 => op_slr,
        5 => op_and,
        6 => op_or,
        7 => op_xor);

begin

    clock: process
    begin
        clk <= '0', '1' after 10 ns;
        wait for 20 ns;
    end process clock;

    current_op <= op_lut(to_integer(unsigned(op)));
    
    process
        variable l : line;
    begin
        wait for 10 ns;
        wait for 20 ns;
        a <= X"00";
        b <= X"00";
        for i in 0 to 7 loop
            op <= std_logic_vector(to_unsigned(i, op'length));
            wait for 20 ns;
        end loop;

        wait for 20 ns;

        a <= X"AA";
        b <= X"55";
        for i in 0 to 7 loop
            op <= std_logic_vector(to_unsigned(i, op'length));
            wait for 20 ns;
        end loop;

        wait for 20 ns;

        a <= X"55";
        b <= X"AA";
        for i in 0 to 7 loop
            op <= std_logic_vector(to_unsigned(i, op'length));
            wait for 20 ns;
        end loop;

        wait for 20 ns;

        a <= X"FF";
        b <= X"FF";
        for i in 0 to 7 loop
            op <= std_logic_vector(to_unsigned(i, op'length));
            wait for 20 ns;
        end loop;

        wait for 20 ns;

        a <= X"01";
        b <= X"01";
        for i in 0 to 7 loop
            op <= std_logic_vector(to_unsigned(i, op'length));
            wait for 20 ns;
        end loop;

        wait for 20 ns;
        assert false report "stop" severity failure;
    end process;
    
simple_alu_1: entity work.simple_alu
port map(
    clk => clk,
    a => a,
    b => b,
    op => op,
    c => c
);

end behav;
