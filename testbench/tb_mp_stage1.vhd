library IEEE;
        use IEEE.STD_LOGIC_1164.ALL;
        use IEEE.NUMERIC_STD.ALL;
library std;
        use std.textio.all;

library work;
        use work.all;
        use work.procedures.all;

entity tb_mp_stage1 is
end tb_mp_stage1;


architecture behav of tb_mp_stage1 is
    signal clk : std_logic := '0';
    signal rst : std_logic := '1';
    signal cmd_in : t_vliw := empty_vliw;
    signal arg_in : t_data_array(4 downto 0) := (others => (others => '0'));
    signal val_in : t_data_array(4 downto 0) := (others => (others => '0'));
    signal arg_out : t_data_array(4 downto 0) := (others => (others => '0'));
    signal val_out : t_data_array(4 downto 0) := (others => (others => '0'));
    signal cmd_out : t_vliw := empty_vliw;

    type op_type is (op_noop, op_add, op_sub, op_umul, op_smul, op_and, op_or, op_xor);
    type op_arr is array(natural range <>) of op_type;
    signal op_lut : op_arr(7 downto 0) := (
        0 => op_noop,
        1 => op_add,
        2 => op_sub,
        3 => op_umul,
        4 => op_smul,
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
                cmd.s1_op1 <= std_logic_vector(to_unsigned(i, cmd.s1_op1'length));
            end if;
            if op2 = op_lut(i) then
                cmd.s1_op2 <= std_logic_vector(to_unsigned(i, cmd.s1_op2'length));
            end if;
        end loop;
        cmd.s1_in1a <= std_logic_vector(to_unsigned(in1a, cmd.s1_in1a'length));
        cmd.s1_in1b <= std_logic_vector(to_unsigned(in1b, cmd.s1_in1b'length));
        cmd.s1_out1 <= std_logic_vector(to_unsigned(out1, cmd.s1_out1'length));
        cmd.s1_in2a <= std_logic_vector(to_unsigned(in2a, cmd.s1_in2a'length));
        cmd.s1_in2b <= std_logic_vector(to_unsigned(in2b, cmd.s1_in2b'length));
        cmd.s1_out2 <= std_logic_vector(to_unsigned(out2, cmd.s1_out2'length));
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
        cmd_in.s1_point1 <= "111";
        cmd_in.s1_point2 <= "111";

        prime_inputs(64, 127, 64, 0, 0,
                     0, 1, 0,
                     2, 3, 1,
                     op_smul, op_smul,
                     val_in, cmd_in);
        wait for 20 ns;
        prime_inputs(0, 75, 64, -64, 64,
                     4, 3, 0,
                     2, 1, 4,
                     op_smul, op_smul,
                     val_in, cmd_in);
        wait for 20 ns;
        prime_inputs(-15, 11, -45, 0, 0,
                     2, 0, 3,
                     2, 1, 4,
                     op_smul, op_smul,
                     val_in, cmd_in);
        -- 64   0  64   0  0
        -- -32 75  64 -64 38
        -- -15 11 -45   5 -4

        wait for 80 ns;
        assert false report "stop" severity failure;
    end process;
    
    mp_stage1_i: entity work.mp_stage1
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
