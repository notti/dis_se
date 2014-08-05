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
    signal addr_r : t_data_array(4 downto 0);
    signal addr : t_data_array(4 downto 0);

    signal which : unsigned(2 downto 0) := (others => '0');
begin

arg_mux: for i in 4 downto 0 generate
   arg(i) <= arg_in(to_integer(unsigned(cmd_in.wb_assign(i))));
   addr(i) <= arg(i) when cmd_in.wb_bitrev(i) = "000" else
              (0 => arg(i)(1), 1 => arg(i)(0), others => '0') when cmd_in.wb_bitrev(i) = "001" else
              (0 => arg(i)(2), 1 => arg(i)(1), 2 => arg(i)(0), others => '0') when cmd_in.wb_bitrev(i) = "010" else
              (0 => arg(i)(3), 1 => arg(i)(2), 2 => arg(i)(1), 3 => arg(i)(0), others => '0') when cmd_in.wb_bitrev(i) = "011" else
              (0 => arg(i)(4), 1 => arg(i)(3), 2 => arg(i)(2), 3 => arg(i)(1), 4 => arg(i)(0), others => '0') when cmd_in.wb_bitrev(i) = "100" else
              (0 => arg(i)(5), 1 => arg(i)(4), 2 => arg(i)(3), 3 => arg(i)(2), 4 => arg(i)(1), 5 => arg(i)(0), others => '0') when cmd_in.wb_bitrev(i) = "101" else
              (0 => arg(i)(6), 1 => arg(i)(5), 2 => arg(i)(4), 3 => arg(i)(3), 4 => arg(i)(2), 5 => arg(i)(1), 6 => arg(i)(0), others => '0') when cmd_in.wb_bitrev(i) = "110" else
              (0 => arg(i)(7), 1 => arg(i)(6), 2 => arg(i)(5), 3 => arg(i)(4), 4 => arg(i)(3), 5 => arg(i)(2), 6 => arg(i)(1), 7 => arg(i)(0));
end generate arg_mux;

state: process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            write_state <= idle;
            cmd <= empty_vliw;
        else
            case write_state is
                when idle =>
                    cmd <= cmd_in;
                    addr_r <= addr;
                    val <= val_in;
                    if cmd_in.wb(0) = '1' then
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
            if write_state = idle or which = 4 then
                which <= (others => '0');
            elsif write_state = write_mem then
                which <= which + 1;
            end if;
        end if;
    end if;
end process which_cnt;

mem_wr <= '1' when write_state = write_mem else
          '0';
mem_addr(9 downto 8) <= cmd.wb_memchunk(to_integer(which));
mem_addr(7 downto 0) <= addr_r(to_integer(which));
mem_data <= val(to_integer(which));

end Structural;
