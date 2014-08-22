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
        arg_in  : in  t_data_array(5 downto 0);
        val_in  : in  t_data_array(5 downto 0);

        mem_wea  : out std_logic;
        mem_dia  : out t_data;
        mem_addra : out std_logic_vector(9 downto 0);
        mem_web  : out std_logic;
        mem_dib  : out t_data;
        mem_addrb : out std_logic_vector(9 downto 0)
    );
end mp_writeback;

architecture Structural of mp_writeback is
    type write_type is (idle, writea, writeb, writec);
    signal write_state : write_type;

    signal cmd : t_vliw;
    signal cmd_r : t_vliw;
    signal val : t_data_array(5 downto 0);
    signal val_r : t_data_array(5 downto 0);
    signal w_val : t_data_array(1 downto 0);
    signal arg : t_data_array(5 downto 0);
    signal arg_r : t_data_array(5 downto 0);
    signal addr : t_data_array(1 downto 0);
    signal wb : std_logic_vector(1 downto 0);
    signal memchunk : t_2array(1 downto 0);
begin

arg_mux: for i in 5 downto 0 generate
    arg(i) <= bitrev(index2val(arg_in, cmd_in.wb_assign(i)(2 downto 0)), cmd_in.wb_bitrev(i)) when cmd_in.wb_assign(i)(3) = '0' else
              bitrev(index2val(val_in, cmd_in.wb_assign(i)(2 downto 0)), cmd_in.wb_bitrev(i));
end generate arg_mux;

val_mux: for i in 5 downto 0 generate
    val(i) <= index2val(val_in, cmd_in.wb_val(i));
end generate val_mux;

state: process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            write_state <= idle;
            cmd <= empty_vliw;
            wb <= (others => '0');
        else
            case write_state is
                when idle =>
                    cmd <= cmd_in;
                    arg_r <= arg;
                    val_r <= val;
                    addr <= arg(1 downto 0);
                    w_val <= val(1 downto 0);
                    if cmd_in.wb(0) = '1' then
                        wb <= cmd_in.wb(1 downto 0);
                        write_state <= writea;
                        memchunk <= cmd_in.wb_memchunk(1 downto 0);
                    end if;
                when writea =>
                    addr <= arg_r(3 downto 2);
                    memchunk <= cmd.wb_memchunk(3 downto 2);
                    w_val <= val_r(3 downto 2);
                    if cmd.wb(2) = '1' then
                        wb <= cmd.wb(3 downto 2);
                        write_state <= writeb;
                    else
                        wb <= (others => '0');
                        write_state <= idle;
                    end if;
                when writeb =>
                    addr <= arg_r(5 downto 4);
                    memchunk <= cmd.wb_memchunk(5 downto 4);
                    w_val <= val_r(5 downto 4);
                    if cmd.wb(2) = '1' then
                        wb <= cmd.wb(5 downto 4);
                        write_state <= writec;
                    else
                        wb <= (others => '0');
                        write_state <= idle;
                    end if;
                when writec =>
                    write_state <= idle;
                    wb <= (others => '0');
            end case;
        end if;
    end if;
end process state;

mem_wea <= wb(0);
mem_web <= wb(1);
mem_addra(9 downto 8) <= memchunk(0);
mem_addra(7 downto 0) <= addr(0);
mem_addrb(9 downto 8) <= memchunk(1);
mem_addrb(7 downto 0) <= addr(1);
mem_dia <= w_val(0);
mem_dib <= w_val(1);

end Structural;
