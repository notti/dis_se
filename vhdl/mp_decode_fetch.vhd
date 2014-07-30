library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.all;

use work.procedures.all;


entity mp_decode_fetch is
    port(
        rst     : in  std_logic;
        clk     : in  std_logic;
        pdata   : in  t_data;
        pdata_rd : out std_logic;
        start   : in  std_logic;
        busy    : out std_logic;

        -- sync ram 0 clk
        mem_addr : out std_logic_vector(9 downto 0); 
        mem_rd   : out std_logic;
        mem_data : in  t_data;
        reg_addr : out t_data;
        reg_rd   : out std_logic;
        reg_data : in  t_data;

        arg      : out t_data_array(4 downto 0);

        cmd_out  : out t_vliw;
        finished : out std_logic
    );
end mp_decode_fetch;

-- 1111WXXX

architecture Structural of mp_decode_fetch is
    type fetch_type is (idle, fetch_mem, fetch_reg, fetch_imm, store_arg, store_cmd);
    signal fetch_state : fetch_type;
    signal fetch_state_1 : fetch_type;

    signal cmd : t_vliw;
    signal cmd_in : t_vliw;
    type t_vliw_arr is array (natural range <>) of t_vliw;

    signal cmd_store : t_vliw_arr(7 downto 0);

    signal which : unsigned(2 downto 0);
    signal which_1 : unsigned(2 downto 0);

    signal cmd_index : unsigned(2 downto 0);

    signal wr_cycle : unsigned(4 downto 0);
begin
-- argtype
--   00 no arg/last value
--   01 reg
--   10 mem
--   11 imm

cmd_in <= cmd_store(to_integer(unsigned(pdata(2 downto 0))));

state: process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            fetch_state <= idle;
            fetch_state_1 <= idle;
            cmd <= empty_vliw;
        else
            case fetch_state is
                when idle =>
                    if start = '1' then
                        if pdata(3) = '1' then
                            fetch_state <= store_cmd;
                            cmd_index <= unsigned(pdata(2 downto 0));
                        else
                            cmd <= cmd_in;
                            case cmd_in.arg_type(to_integer(which)) is
                                when "01" =>
                                    fetch_state <= fetch_reg;
                                when "10" =>
                                    fetch_state <= fetch_mem;
                                when "11" =>
                                    fetch_state <= fetch_imm;
                                when others =>
                                    fetch_state <= idle;
                            end case;
                        end if;
                    end if;
                when store_arg =>
                    fetch_state <= idle;
                when store_cmd =>
                    case to_integer(wr_cycle) is
                        when 0 =>
                            cmd_store(to_integer(cmd_index)).arg_type(0) <= pdata(1 downto 0);
                            cmd_store(to_integer(cmd_index)).arg_type(1) <= pdata(3 downto 2);
                            cmd_store(to_integer(cmd_index)).arg_type(2) <= pdata(5 downto 4);
                            cmd_store(to_integer(cmd_index)).arg_type(3) <= pdata(7 downto 6);
                        when 1 =>
                            cmd_store(to_integer(cmd_index)).arg_type(4) <= pdata(1 downto 0);
                            cmd_store(to_integer(cmd_index)).arg_memchunk(0) <= pdata(3 downto 2);
                            cmd_store(to_integer(cmd_index)).arg_memchunk(1) <= pdata(5 downto 4);
                            cmd_store(to_integer(cmd_index)).arg_memchunk(2) <= pdata(7 downto 6);
                        when 2 =>
                            cmd_store(to_integer(cmd_index)).arg_memchunk(3) <= pdata(1 downto 0);
                            cmd_store(to_integer(cmd_index)).arg_memchunk(4) <= pdata(3 downto 2);
                            cmd_store(to_integer(cmd_index)).last_val <= pdata(4);
                            cmd_store(to_integer(cmd_index)).arg_assign(0) <= pdata(7 downto 5);
                        when 3 =>
                            cmd_store(to_integer(cmd_index)).arg_assign(1) <= pdata(2 downto 0);
                            cmd_store(to_integer(cmd_index)).arg_assign(2) <= pdata(5 downto 3);
                            cmd_store(to_integer(cmd_index)).arg_assign(3)(1 downto 0) <= pdata(7 downto 6);
                        when 4 =>
                            cmd_store(to_integer(cmd_index)).arg_assign(3)(2) <= pdata(0);
                            cmd_store(to_integer(cmd_index)).arg_assign(4) <= pdata(3 downto 1);
                            cmd_store(to_integer(cmd_index)).mem_fetch(3 downto 0) <= pdata(7 downto 4);
                        when 5 =>
                            cmd_store(to_integer(cmd_index)).mem_fetch(4) <= pdata(0);
                            cmd_store(to_integer(cmd_index)).mem_memchunk(0) <= pdata(2 downto 1);
                            cmd_store(to_integer(cmd_index)).mem_memchunk(1) <= pdata(4 downto 3);
                            cmd_store(to_integer(cmd_index)).mem_memchunk(2) <= pdata(6 downto 5);
                            cmd_store(to_integer(cmd_index)).mem_memchunk(3)(0) <= pdata(7);
                        when 6 =>
                            cmd_store(to_integer(cmd_index)).mem_memchunk(3)(1) <= pdata(0);
                            cmd_store(to_integer(cmd_index)).mem_memchunk(4) <= pdata(2 downto 1);
                            cmd_store(to_integer(cmd_index)).s1_in1a <= pdata(5 downto 3);
                            cmd_store(to_integer(cmd_index)).s1_in1b(1 downto 0) <= pdata(7 downto 6);
                        when 7 =>
                            cmd_store(to_integer(cmd_index)).s1_in1b(2) <= pdata(0);
                            cmd_store(to_integer(cmd_index)).s1_op1 <= pdata(3 downto 1);
                            cmd_store(to_integer(cmd_index)).s1_point1 <= pdata(6 downto 4);
                            cmd_store(to_integer(cmd_index)).s1_out1(0) <= pdata(7);
                        when 8 =>
                            cmd_store(to_integer(cmd_index)).s1_out1(2 downto 1) <= pdata(1 downto 0);
                            cmd_store(to_integer(cmd_index)).s1_in2a <= pdata(4 downto 2);
                            cmd_store(to_integer(cmd_index)).s1_in2b <= pdata(7 downto 5);
                        when 9 =>
                            cmd_store(to_integer(cmd_index)).s1_op2 <= pdata(2 downto 0);
                            cmd_store(to_integer(cmd_index)).s1_point2 <= pdata(5 downto 3);
                            cmd_store(to_integer(cmd_index)).s1_out2(1 downto 0) <= pdata(7 downto 6);
                        when 10 =>
                            cmd_store(to_integer(cmd_index)).s1_out2(2) <= pdata(0);
                            cmd_store(to_integer(cmd_index)).s2_in1a <= pdata(3 downto 1);
                            cmd_store(to_integer(cmd_index)).s2_in1b <= pdata(6 downto 4);
                            cmd_store(to_integer(cmd_index)).s2_op1(0) <= pdata(7);
                        when 11 =>
                            cmd_store(to_integer(cmd_index)).s2_op1(2 downto 1) <= pdata(1 downto 0);
                            cmd_store(to_integer(cmd_index)).s2_out1 <= pdata(4 downto 2);
                            cmd_store(to_integer(cmd_index)).s2_in2a <= pdata(7 downto 5);
                        when 12 =>
                            cmd_store(to_integer(cmd_index)).s2_in2b <= pdata(2 downto 0);
                            cmd_store(to_integer(cmd_index)).s2_op2 <= pdata(5 downto 3);
                            cmd_store(to_integer(cmd_index)).s2_out2(1 downto 0) <= pdata(7 downto 6);
                        when 13 =>
                            cmd_store(to_integer(cmd_index)).s2_out2(2) <= pdata(0);
                            cmd_store(to_integer(cmd_index)).s3_in1a <= pdata(3 downto 1);
                            cmd_store(to_integer(cmd_index)).s3_in1b <= pdata(6 downto 4);
                            cmd_store(to_integer(cmd_index)).s3_op1(0) <= pdata(7);
                        when 14 =>
                            cmd_store(to_integer(cmd_index)).s3_op1(2 downto 1) <= pdata(1 downto 0);
                            cmd_store(to_integer(cmd_index)).s3_out1 <= pdata(4 downto 2);
                            cmd_store(to_integer(cmd_index)).s3_in2a <= pdata(7 downto 5);
                        when 15 =>
                            cmd_store(to_integer(cmd_index)).s3_in2b <= pdata(2 downto 0);
                            cmd_store(to_integer(cmd_index)).s3_op2 <= pdata(5 downto 3);
                            cmd_store(to_integer(cmd_index)).s3_out2(1 downto 0) <= pdata(7 downto 6);
                        when 16 =>
                            cmd_store(to_integer(cmd_index)).s3_out2(2) <= pdata(0);
                            cmd_store(to_integer(cmd_index)).wb(4 downto 0) <= pdata(5 downto 1);
                            cmd_store(to_integer(cmd_index)).wb_memchunk(0) <= pdata(7 downto 6);
                        when 17 =>
                            cmd_store(to_integer(cmd_index)).wb_memchunk(1) <= pdata(1 downto 0);
                            cmd_store(to_integer(cmd_index)).wb_memchunk(2) <= pdata(3 downto 2);
                            cmd_store(to_integer(cmd_index)).wb_memchunk(3) <= pdata(5 downto 4);
                            cmd_store(to_integer(cmd_index)).wb_memchunk(4) <= pdata(7 downto 6);
                        when 18 =>
                            cmd_store(to_integer(cmd_index)).wb_bitrev(0) <= pdata(2 downto 0);
                            cmd_store(to_integer(cmd_index)).wb_bitrev(1) <= pdata(5 downto 3);
                            cmd_store(to_integer(cmd_index)).wb_bitrev(2)(1 downto 0) <= pdata(7 downto 6);
                        when 19 =>
                            cmd_store(to_integer(cmd_index)).wb_bitrev(2)(2) <= pdata(0);
                            cmd_store(to_integer(cmd_index)).wb_bitrev(3) <= pdata(3 downto 1);
                            cmd_store(to_integer(cmd_index)).wb_bitrev(4) <= pdata(6 downto 4);
                            cmd_store(to_integer(cmd_index)).wb_assign(0)(0) <= pdata(7);
                        when 20 =>
                            cmd_store(to_integer(cmd_index)).wb_assign(0)(2 downto 1) <= pdata(1 downto 0);
                            cmd_store(to_integer(cmd_index)).wb_assign(1) <= pdata(4 downto 2);
                            cmd_store(to_integer(cmd_index)).wb_assign(2) <= pdata(7 downto 5);
                        when others =>
                            cmd_store(to_integer(cmd_index)).wb_assign(3) <= pdata(2 downto 0);
                            cmd_store(to_integer(cmd_index)).wb_assign(4) <= pdata(5 downto 3);
                            fetch_state <= idle;
                    end case;
                when others =>
                    if which = 4 then
                        fetch_state <= store_arg; -- optimize fetch_imm case?
                    else
                        case cmd.arg_type(to_integer(which)) is
                            when "01" =>
                                fetch_state <= fetch_reg;
                            when "10" =>
                                fetch_state <= fetch_mem;
                            when "11" =>
                                fetch_state <= fetch_imm;
                            when others =>
                                fetch_state <= store_arg;
                        end case;
                    end if;
            end case;
            fetch_state_1 <= fetch_state;
        end if;
    end if;
end process state;

which_cnt: process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            which <= (others => '0');
            which_1 <= (others => '0');
            wr_cycle <= (others => '0');
        else
            if fetch_state = idle or fetch_state = store_arg or which = 4 then
                which <= (others => '0');
            else
                which <= which + 1;
            end if;
            if wr_cycle = 21 or fetch_state = idle then
                wr_cycle <= (others => '0');
            elsif fetch_state = store_cmd then
                wr_cycle <= wr_cycle + 1;
            end if;
            which_1 <= which;
        end if;
    end if;
end process which_cnt;

store: process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            arg <= (others => (others => '0'));
        else
            if fetch_state = fetch_imm then
                arg(to_integer(which)) <= pdata;
            elsif fetch_state_1 = fetch_reg then 
                arg(to_integer(which_1)) <= reg_data;
            elsif fetch_state_1 = fetch_mem then
                arg(to_integer(which_1)) <= mem_data;
            end if;
        end if;
    end if;
end process store;

mem_rd <= '1' when fetch_state = fetch_mem else
          '0';
reg_rd <= '1' when fetch_state = fetch_reg else
          '0';
pdata_rd <= '1' when fetch_state = fetch_mem or fetch_state = fetch_reg or fetch_state = fetch_imm or fetch_state = store_cmd else
            '0';
mem_addr(9 downto 8) <= cmd.arg_memchunk(to_integer(which));
mem_addr(7 downto 0) <= pdata;
reg_addr <= pdata;

finished <= '1' when fetch_state = idle and start = '1' and cmd_in.arg_type(to_integer(which)) = "00" else
            '1' when fetch_state_1 = store_arg else
            '0';
cmd_out <= cmd_in when fetch_state = idle and start = '1' and cmd_in.arg_type(to_integer(which)) = "00" else 
           cmd;
busy <= '1' when fetch_state = store_arg else -- expand to fetch_state_1?
        '0';

end Structural;
