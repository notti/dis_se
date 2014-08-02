library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.all;

use work.procedures.all;


entity mp_decode_fetch is
    port(
        rst               : in  std_logic;
        clk               : in  std_logic;
        pdata             : in  t_data;
        pdata_rd          : out std_logic;
        start             : in  std_logic;
        busy              : out std_logic;

        mem_addr          : out std_logic_vector(9 downto 0); --FIXME
        mem_rd            : out std_logic;                    --FIXME
        mem_data          : in  t_data;                       --FIXME
        reg_addr          : out t_data;
        reg_rd            : out std_logic;
        reg_data          : in  t_data;

        arg_out           : out t_data_array(4 downto 0);
        cmd_out           : out t_vliw
    );
end mp_decode_fetch;

architecture Structural of mp_decode_fetch is
    type fetch_type is (idle, fetch, store_arg, fetch_cmd, store_cmd);
    signal fetch_state : fetch_type;
    signal fetch_state_1 : fetch_type;

    signal cmd : t_vliw;
    type cmd_store_t is array(7 downto 0) of std_logic_vector(VLIW_HIGH downto 0);
    signal cmd_store : cmd_store_t;

    signal which : unsigned(2 downto 0);
    signal which_1 : unsigned(2 downto 0);
    signal which_n1 : unsigned(2 downto 0);

    signal cmd_index : unsigned(2 downto 0);

    signal wr_cycle : unsigned(4 downto 0);

    signal current_arg : std_logic_vector(1 downto 0);
    signal last_arg    : std_logic_vector(1 downto 0);
    signal next_arg    : std_logic_vector(1 downto 0);
    signal to_store : std_logic_vector(175 downto 0);
    signal to_store_final : std_logic_vector(VLIW_HIGH downto 0);

    signal store_addr : unsigned(2 downto 0);

begin

current_arg <= cmd.arg_type(to_integer(which));
last_arg <= cmd.arg_type(to_integer(which_1));
next_arg <= cmd.arg_type(to_integer(which_n1));
to_store_final(175 downto 0) <= to_store;
to_store_final(VLIW_HIGH downto 176) <= pdata(1 downto 0);
store_addr <= cmd_index when fetch_state = fetch_cmd and to_integer(wr_cycle) = 22 else
              unsigned(pdata(2 downto 0));

cmd_mem: process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            cmd <= empty_vliw;
        else
            if fetch_state = fetch_cmd and to_integer(wr_cycle) = 22 then
                cmd_store(to_integer(store_addr)) <= to_store_final;
            end if;
            if fetch_state = idle and start = '1' and pdata(3) = '0' then
                cmd <= slv2vliw(cmd_store(to_integer(store_addr)));
            end if;
        end if;
    end if;
end process;

state: process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            fetch_state <= idle;
            cmd_index <= (others => '0');
            to_store <= (others => '0');
        else
            case fetch_state is
                when idle =>
                    to_store <= (others => '0');
                    if start = '1' then
                        if pdata(3) = '1' then
                            fetch_state <= fetch_cmd;
                            cmd_index <= unsigned(pdata(2 downto 0));
                        else
                            fetch_state <= fetch;
                        end if;
                    end if;
                when fetch_cmd =>
                    case to_integer(wr_cycle) is
                        when 0 to 21 =>
                            to_store(to_integer(wr_cycle+1)*8-1 downto to_integer(wr_cycle)*8) <= pdata;
                        when others =>
                            fetch_state <= store_cmd;
                    end case;
                when fetch =>
                    if which = 4 then
                        fetch_state <= store_arg;
                    else
                        if which = 0 and current_arg = ARG_NONE then
                            fetch_state <= idle;
                        elsif next_arg = ARG_NONE then
                            fetch_state <= store_arg;
                        end if;
                    end if;
                when store_arg =>
                    fetch_state <= idle;
                when store_cmd =>
                    fetch_state <= idle;
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
            which_n1 <= (0 => '1', others => '0');
            wr_cycle <= (others => '0');
        else
            if fetch_state /= fetch or which = 4 then
                which <= (others => '0');
            else
                which <= which + 1;
            end if;
            if fetch_state /= fetch or which_n1 = 4 then
                which_n1 <= (0 => '1', others => '0');
            else
                which_n1 <= which_n1 + 1;
            end if;
            if wr_cycle = 22 or fetch_state /= fetch_cmd then
                wr_cycle <= (others => '0');
            else
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
            arg_out <= (others => (others => '0'));
        else
            if fetch_state = fetch and current_arg = ARG_IMM then
                arg_out(to_integer(which)) <= pdata;
            elsif fetch_state_1 = fetch then
                if last_arg = ARG_REG then
                    arg_out(to_integer(which_1)) <= reg_data;
                elsif last_arg = ARG_MEM then
                    arg_out(to_integer(which_1)) <= mem_data;
                end if;
            end if;
        end if;
    end if;
end process store;

mem_rd <= '1' when fetch_state = fetch and current_arg = ARG_MEM else
          '0';
reg_rd <= '1' when fetch_state = fetch and current_arg = ARG_REG else
          '0';
pdata_rd <= '1' when fetch_state = fetch or fetch_state = fetch_cmd else
            '0';
mem_addr(9 downto 8) <= cmd.arg_memchunk(to_integer(which));
mem_addr(7 downto 0) <= pdata;
reg_addr <= pdata;

cmd_out <= cmd when fetch_state_1 = store_arg or (current_arg = ARG_NONE and which = 0 and fetch_state = fetch) else 
           empty_vliw;
busy <= '1' when fetch_state = store_arg or fetch_state = store_cmd else
        '0';

end Structural;
