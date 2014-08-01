library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.all;

use work.procedures.all;


entity mp_indirect_fetch is
    port(
        rst     : in  std_logic;
        clk     : in  std_logic;
        start   : in  std_logic;

        cmd_in  : in t_vliw;
        arg_in  : in t_data_array(4 downto 0);

        mem_addr : out std_logic_vector(9 downto 0); 
        mem_rd   : out std_logic;
        mem_data : in  t_data;

        arg_out  : out t_data_array(4 downto 0);
        val_out  : out t_data_array(4 downto 0);

        cmd_out  : out t_vliw;
        busy     : out std_logic;
        finished : out std_logic
    );
end mp_indirect_fetch;

architecture Structural of mp_indirect_fetch is
    type fetch_type is (idle, fetch_mem, store_arg);
    signal fetch_state : fetch_type;
    signal fetch_state_1 : fetch_type;

    signal cmd : t_vliw;
    signal val : t_data_array(4 downto 0);
    signal arg : t_data_array(4 downto 0);
    signal arg_r : t_data_array(4 downto 0);
    signal arg_in_r : t_data_array(4 downto 0);

    signal which : unsigned(2 downto 0) := (others => '0');
    signal which_1 : unsigned(2 downto 0) := (others => '0');
begin

arg_mux: for i in 4 downto 0 generate
   arg(i) <= arg_in(to_integer(unsigned(cmd_in.arg_assign(i))));
end generate arg_mux;

state: process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            fetch_state <= idle;
            fetch_state_1 <= idle;
            cmd <= empty_vliw;
            arg_r <= (others => (others => '0'));
            arg_in_r <= (others => (others => '0'));
        else
            case fetch_state is
                when idle =>
                    if start = '1' then
                        cmd <= cmd_in;
                        if cmd_in.last_val = '1' or cmd_in.mem_fetch(to_integer(which)) = '0' then
                            fetch_state <= idle;
                        else
                            fetch_state <= fetch_mem;
                        end if;
                    end if;
                when fetch_mem =>
                    if which = 4 then
                        fetch_state <= store_arg;
                    else
                        if cmd_in.mem_fetch(to_integer(which)) = '1' then
                            fetch_state <= fetch_mem;
                        else
                            fetch_state <= store_arg;
                        end if;
                    end if;
                when store_arg =>
                    fetch_state <= idle;
            end case;
            fetch_state_1 <= fetch_state;
            arg_r <= arg;
            arg_in_r <= arg_in;
        end if;
    end if;
end process state;

which_cnt: process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            which <= (others => '0');
            which_1 <= (others => '0');
        else
            if (fetch_state = idle and (start = '0' or cmd_in.mem_fetch(to_integer(which)) = '0' or cmd_in.last_val = '1')) or fetch_state = store_arg or which = 4 then
                which <= (others => '0');
            else
                which <= which + 1;
            end if;
            which_1 <= which;
        end if;
    end if;
end process which_cnt;

store: process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            val <= (others => (others => '0'));
        else
            if fetch_state = idle and start = '1' and cmd_in.last_val = '0' then
                val <= arg;
            elsif fetch_state = fetch_mem then
                val(to_integer(which_1)) <= mem_data;
            end if;
        end if;
    end if;
end process store;

mem_rd <= '1' when fetch_state = idle and start = '1' and cmd_in.mem_fetch(to_integer(which)) = '1' else
          '1' when fetch_state = fetch_mem else
          '0';
mem_addr(9 downto 8) <= cmd.mem_memchunk(to_integer(which));
mem_addr(7 downto 0) <= arg(to_integer(which)) when fetch_state = idle and start = '1' else
                        arg_r(to_integer(which));

finished <= '1' when fetch_state = idle and start = '1' and cmd_in.mem_fetch(to_integer(which)) = '0' else
            '1' when fetch_state_1 = store_arg else
            '0';
cmd_out <= cmd_in when fetch_state = idle and start = '1' and cmd_in.mem_fetch(to_integer(which)) = '0' else 
           cmd when fetch_state_1 = store_arg else
           empty_vliw;
busy <= '1' when fetch_state = store_arg else -- expand to fetch_state_1?
        '0';
arg_out <= arg_in when fetch_state = idle and start = '1' else
           arg_in_r;
val_out <= arg_in when fetch_state = idle and start = '1' and cmd_in.mem_fetch(to_integer(which)) = '0' and cmd_in.last_val = '0' else
           val;

end Structural;
