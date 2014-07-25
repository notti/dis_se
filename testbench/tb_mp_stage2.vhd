library IEEE;
        use IEEE.STD_LOGIC_1164.ALL;
        use IEEE.NUMERIC_STD.ALL;
library std;
        use std.textio.all;

library work;
        use work.all;
        use work.procedures.all;

entity tb_mp_stage2 is
end tb_mp_stage2;


architecture behav of tb_mp_stage2 is
    signal clk : std_logic := '0';
    signal rst : std_logic := '1';
    signal cmd_in : t_vliw := empty_vliw;
    signal arg_in : t_data_array(4 downto 0) := (others => (others => '0'));
    signal val_in : t_data_array(4 downto 0) := (others => (others => '0'));
    signal arg_out : t_data_array(4 downto 0) := (others => (others => '0'));
    signal val_out : t_data_array(4 downto 0) := (others => (others => '0'));
    signal cmd_out : t_vliw := empty_vliw;

    type op_type is (op_noop, op_add, op_sub, op_sar, op_slr, op_and, op_or, op_xor);
    type op_arr is array(natural range <>) of op_type;
    signal op_lut : op_arr(7 downto 0) := (
        0 => op_noop,
        1 => op_add,
        2 => op_sub,
        3 => op_sar,
        4 => op_slr,
        5 => op_and,
        6 => op_or,
        7 => op_xor);

    procedure prime_inputs(a0, a1, a2, a3, a4 : in integer;
                           in1a, in1b, out1, in2a, in2b, out2: in integer;
                           op1, op2 : in op_type;
                           signal args : out t_data_array(4 downto 0);
                           signal cmd : out t_vliw) is
    begin
        args(0) <= std_logic_vector(to_signed(a0, t_data'length));
        args(1) <= std_logic_vector(to_signed(a1, t_data'length));
        args(2) <= std_logic_vector(to_signed(a2, t_data'length));
        args(3) <= std_logic_vector(to_signed(a3, t_data'length));
        args(4) <= std_logic_vector(to_signed(a4, t_data'length));
        for i in 7 downto 0 loop
            if op1 = op_lut(i) then
                cmd.s2_op1 <= std_logic_vector(to_unsigned(i, cmd.s2_op1'length));
            end if;
            if op2 = op_lut(i) then
                cmd.s2_op2 <= std_logic_vector(to_unsigned(i, cmd.s2_op1'length));
            end if;
        end loop;
        cmd.s2_in1a <= std_logic_vector(to_unsigned(in1a, cmd.s2_in1a'length));
        cmd.s2_in1b <= std_logic_vector(to_unsigned(in1b, cmd.s2_in1b'length));
        cmd.s2_out1 <= std_logic_vector(to_unsigned(out1, cmd.s2_out1'length));
        cmd.s2_in2a <= std_logic_vector(to_unsigned(in2a, cmd.s2_in2a'length));
        cmd.s2_in2b <= std_logic_vector(to_unsigned(in2b, cmd.s2_in2b'length));
        cmd.s2_out2 <= std_logic_vector(to_unsigned(out2, cmd.s2_out2'length));
    end procedure;

begin

    clock: process
    begin
        clk <= '0', '1' after 10 ns;
        wait for 20 ns;
    end process clock;

    process
        variable l : line;
    begin
        wait for 10 ns;
        wait for 60 ns;
        rst <= '0';

        prime_inputs(64, 10, 64, 0, 0,
                     0, 1, 0,
                     2, 3, 1,
                     op_add, op_add,
                     val_in, cmd_in);
        wait for 20 ns;
        prime_inputs(0, 45, 64, -64, 64,
                     4, 3, 0,
                     2, 1, 4,
                     op_add, op_add,
                     val_in, cmd_in);
        wait for 20 ns;
        prime_inputs(-15, 11, -45, 0, 0,
                     2, 0, 3,
                     2, 1, 4,
                     op_add, op_add,
                     val_in, cmd_in);
        --  74 64  64   0   0
        --   0 45  64 -64 109
        -- -15 11 -45 -60 -34

        wait for 80 ns;
        assert false report "stop" severity failure;
    end process;
    
    mp_stage2_i: entity work.mp_stage2
    port map(
        rst => rst,
        clk => clk,
        cmd_in => cmd_in,
        arg_in => arg_in,
        val_in => val_in,
        arg_out => arg_out,
        val_out => val_out,
        cmd_out => cmd_out
    );

end behav;
