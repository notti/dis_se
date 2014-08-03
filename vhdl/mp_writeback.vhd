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
        mem_addr : out std_logic_vector(9 downto 0)
    );
end mp_writeback;

architecture Structural of mp_writeback is
    type write_type is (idle, write_mem);
    signal write_state : write_type;

    signal cmd : t_vliw;
    signal cmd_r : t_vliw;
    signal val : t_data_array(4 downto 0);
    signal arg : t_data_array(4 downto 0);
    signal arg_r : t_data_array(4 downto 0);
    signal addr : t_data;

    signal which : unsigned(2 downto 0) := (others => '0');
begin

arg_mux: for i in 4 downto 0 generate
   arg(i) <= arg_in(to_integer(unsigned(cmd_in.wb_assign(i))));
end generate arg_mux;

cmd <= cmd_in when write_state = idle else
       cmd_r;

state: process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            write_state <= idle;
            cmd_r <= empty_vliw;
            arg_r <= (others => (others => '0'));
        else
            case write_state is
                when idle =>
                    cmd_r <= cmd_in;
                    arg_r <= arg;
                    val <= val_in;
                    if cmd.wb(1) = '1' then
                        write_state <= write_mem;
                    end if;
                when write_mem =>
                    if which = 4 then
                        write_state <= idle;
                    end if;
                    for i in 0 to 3 loop
                        if which = i and cmd.wb(i+1) = '0' then
                            write_state <= idle;
                        end if;
                    end loop;
            end case;
        end if;
    end if;
end process state;

which_cnt: process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            which <= (others => '0');
        else
            which <= which + 1;
            for i in 0 to 3 loop
                if which = i and cmd.wb(i+1) = '0' then
                    which <= (others => '0');
                end if;
            end loop;
            if which = 4 then
                which <= (others => '0');
            end if;
        end if;
    end if;
end process which_cnt;

mem_wr <= '1' when write_state = idle and cmd.wb(0) = '1' else
          '1' when write_state = write_mem else
          '0';
mem_addr(9 downto 8) <= cmd.wb_memchunk(to_integer(which));
mem_addr(7 downto 0) <= addr when cmd.wb_bitrev(to_integer(which)) = "000" else
                        (0 => addr(1), 1 => addr(0), others => '0') when cmd.wb_bitrev(to_integer(which)) = "001" else
                        (0 => addr(2), 1 => addr(1), 2 => addr(0), others => '0') when cmd.wb_bitrev(to_integer(which)) = "010" else
                        (0 => addr(3), 1 => addr(2), 2 => addr(1), 3 => addr(0), others => '0') when cmd.wb_bitrev(to_integer(which)) = "011" else
                        (0 => addr(4), 1 => addr(3), 2 => addr(2), 3 => addr(1), 4 => addr(0), others => '0') when cmd.wb_bitrev(to_integer(which)) = "100" else
                        (0 => addr(5), 1 => addr(4), 2 => addr(3), 3 => addr(2), 4 => addr(1), 5 => addr(0), others => '0') when cmd.wb_bitrev(to_integer(which)) = "101" else
                        (0 => addr(6), 1 => addr(5), 2 => addr(4), 3 => addr(3), 4 => addr(2), 5 => addr(1), 6 => addr(0), others => '0') when cmd.wb_bitrev(to_integer(which)) = "110" else
                        (0 => addr(7), 1 => addr(6), 2 => addr(5), 3 => addr(4), 4 => addr(3), 5 => addr(2), 6 => addr(1), 7 => addr(0));

addr <= arg(to_integer(which)) when write_state = idle else
        arg_r(to_integer(which));
mem_data <= val_in(to_integer(which)) when write_state = idle else
            val(to_integer(which));

end Structural;
