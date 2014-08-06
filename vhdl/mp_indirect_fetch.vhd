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
        arg_in  : in t_data_array(5 downto 0);

        mem_addra: out std_logic_vector(9 downto 0); 
        mem_ena  : out std_logic;
        mem_doa  : in  t_data;
        mem_addrb: out std_logic_vector(9 downto 0); 
        mem_enb  : out std_logic;
        mem_dob  : in  t_data;

        arg_out  : out t_data_array(5 downto 0);
        val_out  : out t_data_array(5 downto 0);

        cmd_out  : out t_vliw
    );
end mp_indirect_fetch;

architecture Structural of mp_indirect_fetch is
    type fetch_type is (idle, fetcha, fetchb, fetchc, store_arg);
    signal fetch_state : fetch_type;
    signal fetch_state_1 : fetch_type;

    signal cmd : t_vliw;
    signal val : t_data_array(5 downto 0);
    signal arg : t_data_array(5 downto 0);
    signal arg_r : t_data_array(5 downto 0);

    signal addr : t_data_array(1 downto 0);

    signal to_fetch : std_logic_vector(1 downto 0);
    signal to_fetch_1 : std_logic_vector(1 downto 0);
    signal memchunk : t_2array(1 downto 0);
begin

arg_mux: for i in 4 downto 0 generate
   arg(i) <= index2val(arg_in, cmd_in.arg_assign(i));
end generate arg_mux;

state: process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            fetch_state <= idle;
            fetch_state_1 <= idle;
            cmd <= empty_vliw;
            to_fetch <= (others => '0');
        else
            case fetch_state is
                when idle =>
					cmd <= cmd_in;
					arg_r <= arg;
					arg_out <= arg_in;
                    addr <= arg(1 downto 0);
                    memchunk <= cmd_in.mem_memchunk(1 downto 0);
					if cmd_in.mem_fetch(0) = '0' then
						fetch_state <= idle;
					else
						fetch_state <= fetcha;
                        to_fetch <= cmd_in.mem_fetch(1 downto 0);
					end if;
                when fetcha =>
                    addr <= arg_r(3 downto 2);
                    memchunk <= cmd.mem_memchunk(3 downto 2);
                    if cmd.mem_fetch(2) = '0' then
                        to_fetch <= (others => '0');
                        fetch_state <= store_arg;
                    else
                        to_fetch <= cmd.mem_fetch(3 downto 2);
                        fetch_state <= fetchb;
                    end if;
                when fetchb => 
                    addr <= arg_r(5 downto 4);
                    memchunk <= cmd.mem_memchunk(5 downto 4);
                    if cmd.mem_fetch(4) = '0' then
                        to_fetch <= (others => '0');
                        fetch_state <= store_arg;
                    else
                        to_fetch <= cmd.mem_fetch(5 downto 4);
                        fetch_state <= fetchc;
                    end if;
                when fetchc =>
                    fetch_state <= store_arg;
                    to_fetch <= (others => '0');
                when store_arg =>
                    fetch_state <= idle;
            end case;
            fetch_state_1 <= fetch_state;
            to_fetch_1 <= to_fetch;
        end if;
    end if;
end process state;

store: process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            val <= (others => (others => '0'));
        else
            if fetch_state = idle then
                for i in 0 to 5 loop
                    if cmd_in.arg_val(i) = '1' then
                        val(i) <= arg(i);
                    end if;
                end loop;
            elsif fetch_state_1 = fetcha then
                if to_fetch_1(0) = '1' then
                    val(0) <= mem_doa;
                end if;
                if to_fetch_1(1) = '1' then
                    val(1) <= mem_dob;
                end if;
            elsif fetch_state_1 = fetchb then
                if to_fetch_1(0) = '1' then
                    val(2) <= mem_doa;
                end if;
                if to_fetch_1(1) = '1' then
                    val(3) <= mem_dob;
                end if;
            elsif fetch_state_1 = fetchc then
                if to_fetch_1(0) = '1' then
                    val(4) <= mem_doa;
                end if;
                if to_fetch_1(1) = '1' then
                    val(5) <= mem_dob;
                end if;
            end if;
        end if;
    end if;
end process store;

mem_ena <= to_fetch(0);
mem_enb <= to_fetch(1);
mem_addra(9 downto 8) <= memchunk(0);
mem_addra(7 downto 0) <= addr(0);
mem_addrb(9 downto 8) <= memchunk(1);
mem_addrb(7 downto 0) <= addr(1);

cmd_out <= cmd when fetch_state = idle else
           empty_vliw;
val_out <= val;

end Structural;
