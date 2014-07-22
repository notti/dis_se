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

        argtype : in  std_logic_vector(9 downto 0);
        memchunk : in std_logic_vector(9 downto 0);


        -- sync ram 0 clk
        mem_addr : out std_logic_vector(9 downto 0); 
        mem_rd   : out std_logic;
        mem_data : in  t_data;
        reg_addr : out t_data;
        reg_rd   : out std_logic;
        reg_data : in  t_data;

        arg      : out t_data_array(4 downto 0);

        finished : out std_logic
    );
end mp_decode_fetch;

architecture Structural of mp_decode_fetch is
    type fetch_type is (idle, fetch_mem, fetch_reg, fetch_imm, store_arg);
    signal fetch_state : fetch_type;
    signal fetch_state_1 : fetch_type;
    type type_arr is array(natural range <>) of std_logic_vector(1 downto 0);
    signal argtype_arr : type_arr(4 downto 0);
    signal memchunk_arr : type_arr(4 downto 0);
    signal which : unsigned(2 downto 0);
    signal which_1 : unsigned(2 downto 0);
begin
-- argtype
--   00 no arg/last value
--   01 reg
--   10 mem
--   11 imm

convert_argtype: for i in 4 downto 0 generate
begin
    argtype_arr(i) <= argtype(i*2+1 downto i*2);
    memchunk_arr(i) <= memchunk(i*2+1 downto i*2);
end generate convert_argtype;

state: process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            fetch_state <= idle;
            fetch_state_1 <= idle;
        else
            case fetch_state is
                when idle =>
                    if start = '1' then
                        case argtype_arr(to_integer(which)) is
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
                when store_arg =>
                    fetch_state <= idle;
                when others =>
                    if which = 4 then
                        fetch_state <= store_arg; -- optimize fetch_imm case?
                    else
                        case argtype_arr(to_integer(which)) is
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
        else
            if fetch_state = idle or fetch_state = store_arg or which = 4 then
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
pdata_rd <= '1' when fetch_state = fetch_mem or fetch_state = fetch_reg or fetch_state = fetch_imm else
            '0';
mem_addr(9 downto 8) <= memchunk_arr(to_integer(which));
mem_addr(7 downto 0) <= pdata;
reg_addr <= pdata;

finished <= '1' when fetch_state = idle and start = '1' and argtype_arr(to_integer(which)) = "00" else
            '1' when fetch_state_1 = store_arg else
            '0';
busy <= '1' when fetch_state = store_arg else -- expand to fetch_state_1?
        '0';

end Structural;
