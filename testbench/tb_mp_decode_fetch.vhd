library IEEE;
        use IEEE.STD_LOGIC_1164.ALL;
        use IEEE.NUMERIC_STD.ALL;
library std;
        use std.textio.all;

library work;
        use work.all;
        use work.procedures.all;

entity tb_mp_decode_fetch is
end tb_mp_decode_fetch;


architecture behav of tb_mp_decode_fetch is
       signal rst     :  std_logic := '1';
       signal clk     :  std_logic := '0';
       signal pdata   :  t_data := (others => '0');
       signal pdata_rd : std_logic := '0';
       signal start   :  std_logic := '0';
       signal busy    :  std_logic := '0';
       signal mem_addr :  std_logic_vector(9 downto 0) := (others => '0'); 
       signal mem_rd   :  std_logic := '0';
       signal mem_data :  t_data := (others => '0');
       signal reg_addr :  t_data := (others => '0');
       signal reg_rd   :  std_logic := '0';
       signal reg_data :  t_data := (others => '0');
       signal arg      :  t_data_array(4 downto 0) := (others => (others => '0'));
       signal cmd_out  :  t_vliw := empty_vliw;
       signal finished :  std_logic := '0';


       procedure prog_cmd(cmd     : in t_vliw;
                        which     : in natural;
                        signal start   : out std_logic;
                        signal pdata   : out t_data) is
       begin
           start <= '1';
           pdata <= "11111" & std_logic_vector(to_unsigned(which, 3));
           wait for 20 ns;
           start <= '0';
           pdata(1 downto 0) <= cmd.arg_type(0);
           pdata(3 downto 2) <= cmd.arg_type(1);
           pdata(5 downto 4) <= cmd.arg_type(2);
           pdata(7 downto 6) <= cmd.arg_type(3);
           wait for 20 ns;
           pdata(1 downto 0) <= cmd.arg_type(4);
           pdata(3 downto 2) <= cmd.arg_memchunk(0);
           pdata(5 downto 4) <= cmd.arg_memchunk(1);
           pdata(7 downto 6) <= cmd.arg_memchunk(2);
           wait for 20 ns;
           pdata(1 downto 0) <= cmd.arg_memchunk(3);
           pdata(3 downto 2) <= cmd.arg_memchunk(4);
           pdata(4) <= cmd.last_val;
           pdata(7 downto 5) <= cmd.arg_assign(0);
           wait for 20 ns;
           pdata(2 downto 0) <= cmd.arg_assign(1);
           pdata(5 downto 3) <= cmd.arg_assign(2);
           pdata(7 downto 6) <= cmd.arg_assign(3)(1 downto 0);
           wait for 20 ns;
           pdata(0) <= cmd.arg_assign(3)(2);
           pdata(3 downto 1) <= cmd.arg_assign(4);
           pdata(7 downto 4) <= cmd.mem_fetch(3 downto 0);
           wait for 20 ns;
           pdata(0) <= cmd.mem_fetch(4);
           pdata(2 downto 1) <= cmd.mem_memchunk(0);
           pdata(4 downto 3) <= cmd.mem_memchunk(1);
           pdata(6 downto 5) <= cmd.mem_memchunk(2);
           pdata(7) <= cmd.mem_memchunk(3)(0);
           wait for 20 ns;
           pdata(0) <= cmd.mem_memchunk(3)(1);
           pdata(2 downto 1) <= cmd.mem_memchunk(4);
           pdata(5 downto 3) <= cmd.s1_in1a;
           pdata(7 downto 6) <= cmd.s1_in1b(1 downto 0);
           wait for 20 ns;
           pdata(0) <= cmd.s1_in1b(2);
           pdata(3 downto 1) <= cmd.s1_op1;
           pdata(6 downto 4) <= cmd.s1_point1;
           pdata(7) <= cmd.s1_out1(0);
           wait for 20 ns;
           pdata(1 downto 0) <= cmd.s1_out1(2 downto 1);
           pdata(4 downto 2) <= cmd.s1_in2a;
           pdata(7 downto 5) <= cmd.s1_in2b;
           wait for 20 ns;
           pdata(2 downto 0) <= cmd.s1_op2;
           pdata(5 downto 3) <= cmd.s1_point2;
           pdata(7 downto 6) <= cmd.s1_out2(1 downto 0);
           wait for 20 ns;
           pdata(0) <= cmd.s1_out2(2);
           pdata(3 downto 1) <= cmd.s2_in1a;
           pdata(6 downto 4) <= cmd.s2_in1b;
           pdata(7) <= cmd.s2_op1(0);
           wait for 20 ns;
           pdata(1 downto 0) <= cmd.s2_op1(2 downto 1);
           pdata(4 downto 2) <= cmd.s2_out1;
           pdata(7 downto 5) <= cmd.s2_in2a;
           wait for 20 ns;
           pdata(2 downto 0) <= cmd.s2_in2b;
           pdata(5 downto 3) <= cmd.s2_op2;
           pdata(7 downto 6) <= cmd.s2_out2(1 downto 0);
           wait for 20 ns;
           pdata(0) <= cmd.s2_out2(2);
           pdata(3 downto 1) <= cmd.s3_in1a;
           pdata(6 downto 4) <= cmd.s3_in1b;
           pdata(7) <= cmd.s3_op1(0);
           wait for 20 ns;
           pdata(1 downto 0) <= cmd.s3_op1(2 downto 1);
           pdata(4 downto 2) <= cmd.s3_out1;
           pdata(7 downto 5) <= cmd.s3_in2a;
           wait for 20 ns;
           pdata(2 downto 0) <= cmd.s3_in2b;
           pdata(5 downto 3) <= cmd.s3_op2;
           pdata(7 downto 6) <= cmd.s3_out2(1 downto 0);
           wait for 20 ns;
           pdata(0) <= cmd.s3_out2(2);
           pdata(5 downto 1) <= cmd.wb(4 downto 0);
           pdata(7 downto 6) <= cmd.wb_memchunk(0);
           wait for 20 ns;
           pdata(1 downto 0) <= cmd.wb_memchunk(1);
           pdata(3 downto 2) <= cmd.wb_memchunk(2);
           pdata(5 downto 4) <= cmd.wb_memchunk(3);
           pdata(7 downto 6) <= cmd.wb_memchunk(4);
           wait for 20 ns;
           pdata(2 downto 0) <= cmd.wb_bitrev(0);
           pdata(5 downto 3) <= cmd.wb_bitrev(1);
           pdata(7 downto 6) <= cmd.wb_bitrev(2)(1 downto 0);
           wait for 20 ns;
           pdata(0) <= cmd.wb_bitrev(2)(2);
           pdata(3 downto 1) <= cmd.wb_bitrev(3);
           pdata(6 downto 4) <= cmd.wb_bitrev(4);
           pdata(7) <= cmd.wb_assign(0)(0);
           wait for 20 ns;
           pdata(1 downto 0) <= cmd.wb_assign(0)(2 downto 1);
           pdata(4 downto 2) <= cmd.wb_assign(1);
           pdata(7 downto 5) <= cmd.wb_assign(2);
           wait for 20 ns;
           pdata <= (others => '0');
           pdata(2 downto 0) <= cmd.wb_assign(3);
           pdata(5 downto 3) <= cmd.wb_assign(4);
           wait for 20 ns;
       end procedure;

begin
    
    clock: process
    begin
        clk <= '0', '1' after 10 ns;
        wait for 20 ns;
    end process clock;

    process(clk)
        variable i : unsigned(7 downto 0) := (others => '0');
    begin
        if rising_edge(clk) then
            if rst = '1' then
                i := (others => '0');
            else
                i := i + 1;
                mem_data <= std_logic_vector(i);
                reg_data <= std_logic_vector(i + 128);
            end if;
        end if;
    end process;

    process
        variable l : line;
    begin
        wait for 10 ns;
        wait for 40 ns;
        rst <= '0';

        wait for 40 ns;

        prog_cmd(
            (
            arg_type => (
                0 => ARG_REG, -- i
                1 => ARG_REG, -- j
                2 => ARG_REG, -- r_lut
                3 => ARG_REG, -- i_lut
                4 => ARG_NONE
            ),
            arg_memchunk => (others => (others => '0')),
            last_val => '0',
            arg_assign => (
                0 => "000", -- i
                1 => "001", -- j
                2 => "001", -- j
                3 => "010", -- r_lut
                4 => "011"  -- i_lut
            ),
            mem_fetch => (
                0 => '1',
                1 => '1',
                2 => '1',
                3 => '0',
                4 => '0'),
            mem_memchunk => (
                0 => "10", -- R
                1 => "10", -- R
                2 => "11", -- I
                3 => "00",
                4 => "00"
            ),
            s1_in1a => "011", -- r_lut
            s1_in1b => "001", -- R[j]
            s1_op1  => CALU_SMUL,
            s1_point1 => "111",
            s1_out1 => "001",
            s1_in2a => "100", -- i_lut
            s1_in2b => "010", -- I[j]
            s1_op2 => CALU_SMUL,
            s1_point2 => "111",
            s1_out2 => "010",

            s2_in1a => "001",
            s2_in1b => "010",
            s2_op1  => SALU_SUB,
            s2_out1 => "001", -- tr
            s2_in2a => "000", -- R[i]
            s2_in2b => ALUIN_1, -- 1
            s2_op2  => SALU_SAR,
            s2_out2  => "000",

            s3_in1a => "001",
            s3_in1b => "000",
            s3_op1  => SALU_SUB,
            s3_out1 => "001",
            s3_in2a => "001",
            s3_in2b => "000",
            s3_op2  => SALU_ADD,
            s3_out2 => "000",

            wb => (
                0 => '1',
                1 => '1',
                2 => '0',
                3 => '0',
                4 => '0'),
            wb_memchunk => (
                0 => "10", -- R
                1 => "10", -- R
                2 => "00",
                3 => "00",
                4 => "00"),
            wb_bitrev => (others => (others => '0')),
            wb_assign => (
                0 => "000",
                1 => "001",
                2 => "010",
                3 => "011",
                4 => "100")
            ),
            0,
            start,
            pdata);
        wait for 40 ns;
        pdata <= "11100000";
        start <= '1';
        wait for 20 ns;
        start <= '0';
        pdata <= "00000001";
        wait for 20 ns;
        pdata <= (others => '0');
        wait for 200 ns;

        assert false report "stop" severity failure;
    end process;
    
    mp_decode_fetch_i: entity work.mp_decode_fetch
    port map(
        rst => rst,
        clk => clk,
        pdata => pdata,
        pdata_rd => pdata_rd,
        start => start,
        busy => busy,
        mem_addr => mem_addr,
        mem_rd => mem_rd,
        mem_data => mem_data,
        reg_addr => reg_addr,
        reg_rd => reg_rd,
        reg_data => reg_data,
        arg => arg,
        cmd_out => cmd_out,
        finished => finished
    );

end behav;
