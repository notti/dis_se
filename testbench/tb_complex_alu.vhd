library IEEE;
        use IEEE.STD_LOGIC_1164.ALL;
        use IEEE.NUMERIC_STD.ALL;
library std;
        use std.textio.all;

library work;
        use work.all;
        use work.procedures.all;

entity tb_complex_alu is
end tb_complex_alu;


architecture behav of tb_complex_alu is
    signal clk : std_logic := '0';
    signal a : t_data := (others => '0');
    signal b : t_data := (others => '0');
    signal op : std_logic_vector(2 downto 0) := (others => '0');
    signal c : t_data := (others => '0');
    signal point : std_logic_vector(2 downto 0) := (others => '0');
    type op_type is (op_noop, op_add, op_sub, op_umul, op_smul, op_and, op_or, op_xor);
    type op_arr is array(natural range <>) of op_type;
    signal current_op : op_type;
    signal op_lut : op_arr(7 downto 0) := (
        0 => op_noop,
        1 => op_add,
        2 => op_sub,
        3 => op_umul,
        4 => op_smul,
        5 => op_and,
        6 => op_or,
        7 => op_xor);

    procedure prime_inputs(a, b : in integer;
                           signal a_out, b_out : out t_data;
                           signal op_out : out std_logic_vector(2 downto 0)) is
    begin
        a_out <= std_logic_vector(to_signed(a, t_data'length));
        b_out <= std_logic_vector(to_signed(b, t_data'length));
        op_out <= "011";
        wait for 20 ns;
        op_out <= "100";
        wait for 20 ns;
    end procedure;

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

        wait for 80 ns;

        point <= "111";
        prime_inputs(64, 127, a, b, op);
        prime_inputs(64, 0, a, b, op);
        prime_inputs(64, -64, a, b, op);
        prime_inputs(64, 75, a, b, op);
        prime_inputs(-45, -15, a, b, op);
        prime_inputs(-45, 11, a, b, op);

        wait for 40 ns;
        assert false report "stop" severity failure;
    end process;
    
complex_alu_1: entity work.complex_alu
port map(
    clk => clk,
    a => a,
    b => b,
    op => op,
    point => point,
    c => c
);

end behav;
