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

        cmd_in  : in t_vliw;
        arg_in  : in t_data_array(4 downto 0);

        mem_addr : out std_logic_vector(9 downto 0); 
        mem_rd   : out std_logic;
        mem_data : in  t_data;

        arg_out  : out t_data_array(4 downto 0);
        val_out  : out t_data_array(4 downto 0);

        cmd_out  : out t_vliw
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

    signal which : unsigned(2 downto 0) := (others => '0');
    signal which_1 : unsigned(2 downto 0) := (others => '0');
    signal which_n1 : unsigned(2 downto 0) := (others => '0');
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
        else
            case fetch_state is
                when idle =>
					cmd <= cmd_in;
					arg_r <= arg;
					arg_out <= arg_in;
					if cmd_in.mem_fetch(to_integer(which)) = '0' then
						fetch_state <= idle;
					else
						fetch_state <= fetch_mem;
					end if;
                when fetch_mem =>
                    if which = 4 then
                        fetch_state <= store_arg;
                    else
                        if cmd.mem_fetch(to_integer(which_n1)) = '1' then
                            fetch_state <= fetch_mem;
                        else
                            fetch_state <= store_arg;
                        end if;
                    end if;
                when store_arg =>
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
        else
            if fetch_state /= fetch_mem or which = 4 then
                which <= (others => '0');
            else
                which <= which + 1;
            end if;
            if fetch_state /= fetch_mem or which_n1 = 4 then
                which_n1 <= (0 => '1', others => '0');
            else
                which_n1 <= which_n1 + 1;
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
            if fetch_state = idle then
                for i in 0 to 4 loop
                    if cmd_in.arg_val(i) = '1' then
                        val(i) <= arg(i);
                    end if;
                end loop;
            elsif fetch_state_1 = fetch_mem then
                val(to_integer(which_1)) <= mem_data;
            end if;
        end if;
    end if;
end process store;

mem_rd <= '1' when fetch_state = fetch_mem else
          '0';
mem_addr(9 downto 8) <= cmd.mem_memchunk(to_integer(which));
mem_addr(7 downto 0) <= arg_r(to_integer(which));

cmd_out <= cmd when fetch_state = idle else
           empty_vliw;
val_out <= val;

end Structural;
