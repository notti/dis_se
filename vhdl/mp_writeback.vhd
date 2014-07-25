library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.all;

use work.procedures.all;


entity mp_writeback is
    port(
        rst     : in  std_logic;
        clk     : in  std_logic;

        cmd_in  : in  t_vliw;
        arg_in  : in  t_data_array(4 downto 0);
        val_in  : in  t_data_array(4 downto 0);

        mem_wr  : out std_logic;
        mem_data : out t_data;
        mem_addr : out std_logic_vector(9 downto 0);
        busy    : out std_logic
    );
end mp_writeback;

architecture Structural of mp_writeback is
    type fetch_type is (idle, write_mem);
    signal fetch_state : fetch_type;

    signal cmd : t_vliw;
    signal cmd_r : t_vliw;
    signal val : t_data_array(4 downto 0);
    signal arg : t_data_array(4 downto 0);
    signal arg_r : t_data_array(4 downto 0);

    signal which : unsigned(2 downto 0) := (others => '0');
begin

arg_mux: for i in 4 downto 0 generate
   arg(i) <= arg_in(to_integer(unsigned(cmd_in.wb_assign(i))));
end generate arg_mux;

cmd <= cmd_in when fetch_state = idle else
       cmd_r;

state: process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            fetch_state <= idle;
            cmd_r <= empty_vliw;
            arg_r <= (others => (others => '0'));
        else
            case fetch_state is
                when idle =>
                    cmd_r <= cmd_in;
                    if cmd.wb(to_integer(which)) = '0' then
                        fetch_state <= idle;
                    else
                        fetch_state <= write_mem;
                    end if;
                when write_mem =>
                    if which = 4 then
                        fetch_state <= idle;
                    else
                        if cmd.wb(to_integer(which)) = '1' then
                            fetch_state <= write_mem;
                        else
                            fetch_state <= idle;
                        end if;
                    end if;
            end case;
            arg_r <= arg;
            val <= val_in;
        end if;
    end if;
end process state;

which_cnt: process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            which <= (others => '0');
        else
            if cmd.wb(to_integer(which)) = '0' or which = 4 then
                which <= (others => '0');
            else
                which <= which + 1;
            end if;
        end if;
    end if;
end process which_cnt;

mem_wr <= '1' when fetch_state = idle and cmd.wb(to_integer(which)) = '1' else
          '1' when fetch_state = write_mem else
          '0';
mem_addr(9 downto 8) <= cmd.wb_memchunk(to_integer(which));
mem_addr(7 downto 0) <= arg(to_integer(which)) when fetch_state = idle else
                        arg_r(to_integer(which));
mem_data <=  val_in(to_integer(which)) when fetch_state = idle else
             val(to_integer(which));

busy <= '1' when fetch_state = write_mem else
        '0';

end Structural;
