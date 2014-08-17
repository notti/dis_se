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
        pdata             : in  t_data2;
        pdata_rd          : out std_logic;
        start             : in  std_logic;
        busy              : out std_logic;

        mem_addra         : out std_logic_vector(9 downto 0);
        mem_ena           : out std_logic;
        mem_doa           : in  t_data;
        mem_addrb         : out std_logic_vector(9 downto 0);
        mem_enb           : out std_logic;
        mem_dob           : in  t_data;

        reg_addra         : out t_data;
        reg_ena           : out std_logic;
        reg_doa           : in  t_data;
        reg_addrb         : out t_data;
        reg_enb           : out std_logic;
        reg_dob           : in  t_data;

        arg_out           : out t_data_array(5 downto 0);
        cmd_out           : out t_vliw
    );
end mp_decode_fetch;

architecture Structural of mp_decode_fetch is
    type fetch_type is (idle, fetcha, fetchb, fetchc, store_arg, fetch_cmd, store_cmd);
    signal fetch_state : fetch_type;
    signal fetch_state_1 : fetch_type;

    signal cmd : t_vliw;
    type cmd_store_t is array(7 downto 0) of std_logic_vector(VLIW_HIGH downto 0);
    signal cmd_store : cmd_store_t;

    signal cmd_index : unsigned(2 downto 0);

    signal wr_cycle : unsigned(4 downto 0);

    signal to_store : std_logic_vector((VLIW_HIGH/16)*16-1 downto 0);
    signal to_store_final : std_logic_vector(VLIW_HIGH downto 0);

    signal store_addr : unsigned(2 downto 0);

    signal to_fetch : t_2array(1 downto 0);
    signal to_fetch_1 : t_2array(1 downto 0);
    signal memchunk : t_2array(1 downto 0);

begin

to_store_final((VLIW_HIGH/16)*16-1 downto 0) <= to_store;
to_store_final(VLIW_HIGH downto (VLIW_HIGH/16)*16) <= pdata(VLIW_HIGH mod 16 downto 0);
store_addr <= cmd_index when fetch_state = fetch_cmd and to_integer(wr_cycle) = VLIW_HIGH/16 else
              unsigned(pdata(2 downto 0));

state: process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            fetch_state <= idle;
            cmd_index <= (others => '0');
            to_store <= (others => '0');
            to_fetch <= (others => ARG_NONE);
            to_fetch_1 <= (others => ARG_NONE);
            cmd <= empty_vliw;
        else
            case fetch_state is
                when idle =>
                    to_store <= (others => '0');
                    if start = '1' then
                        if pdata(3) = '1' then
                            fetch_state <= fetch_cmd;
                            cmd_index <= unsigned(pdata(2 downto 0));
                        else
                            cmd <= slv2vliw(cmd_store(to_integer(store_addr)));
                            to_fetch(0) <= cmd_store(to_integer(store_addr))(1 downto 0);
                            to_fetch(1) <= cmd_store(to_integer(store_addr))(3 downto 2);
                            memchunk(0) <= cmd_store(to_integer(store_addr))(11 downto 10);
                            memchunk(1) <= cmd_store(to_integer(store_addr))(13 downto 12);
                            if cmd_store(to_integer(store_addr))(1 downto 0) = ARG_NONE then
                                fetch_state <= store_arg;
                            else
                                fetch_state <= fetcha;
                            end if;
                        end if;
                    end if;
                when fetch_cmd =>
                    for i in 0 to VLIW_HIGH/16-1 loop
                        if to_integer(wr_cycle) = i then
                            to_store((i+1)*16-1 downto i*16) <= pdata;
                        end if;
                    end loop;
                    if to_integer(wr_cycle) = VLIW_HIGH/16 then
                        cmd_store(to_integer(store_addr)) <= to_store_final;
                        fetch_state <= store_cmd;
                    end if;
                when fetcha =>
                    memchunk <= cmd.arg_memchunk(3 downto 2);
                    if cmd.arg_type(2) = ARG_NONE then
                        to_fetch <= (others => ARG_NONE);
                        fetch_state <= store_arg;
                    else
                        to_fetch <= cmd.arg_type(3 downto 2);
                        fetch_state <= fetchb;
                    end if;
                when fetchb =>
                    memchunk <= cmd.arg_memchunk(5 downto 4);
                    if cmd.arg_type(4) = ARG_NONE then
                        to_fetch <= (others => ARG_NONE);
                        fetch_state <= store_arg;
                    else
                        to_fetch <= cmd.arg_type(5 downto 4);
                        fetch_state <= fetchc;
                    end if;
                when fetchc =>
                    to_fetch <= (others => ARG_NONE);
                    fetch_state <= store_arg;
                when store_arg =>
                    fetch_state <= idle;
                when store_cmd =>
                    fetch_state <= idle;
            end case;
            fetch_state_1 <= fetch_state;
            to_fetch_1 <= to_fetch;
        end if;
    end if;
end process state;

wr_cnt: process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            wr_cycle <= (others => '0');
        else
            if wr_cycle = VLIW_HIGH/16 or fetch_state /= fetch_cmd then
                wr_cycle <= (others => '0');
            else
                wr_cycle <= wr_cycle + 1;
            end if;
        end if;
    end if;
end process wr_cnt;

store: process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            arg_out <= (others => (others => '0'));
        else
            if to_fetch(0) = ARG_IMM then
                if fetch_state = fetcha then
                    arg_out(0) <= pdata(7 downto 0);
                elsif fetch_state = fetchb then
                    arg_out(2) <= pdata(7 downto 0);
                elsif fetch_state = fetchc then
                    arg_out(4) <= pdata(7 downto 0);
                end if;
            elsif to_fetch_1(0) = ARG_REG then
                if fetch_state_1 = fetcha then
                    arg_out(0) <= reg_doa;
                elsif fetch_state_1 = fetchb then
                    arg_out(2) <= reg_doa;
                elsif fetch_state_1 = fetchc then
                    arg_out(4) <= reg_doa;
                end if;
            elsif to_fetch_1(0) = ARG_MEM then
                if fetch_state_1 = fetcha then
                    arg_out(0) <= mem_doa;
                elsif fetch_state_1 = fetchb then
                    arg_out(2) <= mem_doa;
                elsif fetch_state_1 = fetchc then
                    arg_out(4) <= mem_doa;
                end if;
            end if;
            if to_fetch(1) = ARG_IMM then
                if fetch_state = fetcha then
                    arg_out(1) <= pdata(15 downto 8);
                elsif fetch_state = fetchb then
                    arg_out(3) <= pdata(15 downto 8);
                elsif fetch_state = fetchc then
                    arg_out(5) <= pdata(15 downto 8);
                end if;
            elsif to_fetch_1(1) = ARG_REG then
                if fetch_state_1 = fetcha then
                    arg_out(1) <= reg_dob;
                elsif fetch_state_1 = fetchb then
                    arg_out(3) <= reg_dob;
                elsif fetch_state_1 = fetchc then
                    arg_out(5) <= reg_dob;
                end if;
            elsif to_fetch_1(1) = ARG_MEM then
                if fetch_state_1 = fetcha then
                    arg_out(1) <= mem_dob;
                elsif fetch_state_1 = fetchb then
                    arg_out(3) <= mem_dob;
                elsif fetch_state_1 = fetchc then
                    arg_out(5) <= mem_dob;
                end if;
            end if;
        end if;
    end if;
end process store;

mem_ena <= '1' when to_fetch(0) = ARG_MEM else
           '0';
mem_enb <= '1' when to_fetch(1) = ARG_MEM else
           '0';
reg_ena <= '1' when to_fetch(0) = ARG_REG else
           '0';
reg_enb <= '1' when to_fetch(1) = ARG_REG else
           '0';
pdata_rd <= '1' when fetch_state = fetcha or fetch_state = fetchb or fetch_state = fetchc or fetch_state = fetch_cmd else
            '0';
mem_addra(9 downto 8) <= memchunk(0);
mem_addrb(9 downto 8) <= memchunk(1);
mem_addra(7 downto 0) <= pdata(7 downto 0);
mem_addrb(7 downto 0) <= pdata(15 downto 8);
reg_addra <= pdata(7 downto 0);
reg_addrb <= pdata(15 downto 8);

cmd_out <= cmd when fetch_state_1 = store_arg or (to_fetch(0) = ARG_NONE and fetch_state = fetcha) else 
           empty_vliw;
busy <= '1' when fetch_state = store_arg or fetch_state = store_cmd else
        '0';

end Structural;
