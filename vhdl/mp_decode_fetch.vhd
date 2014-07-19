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
        start   : in  std_logic;

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
    type fetch_type is (idle, fetch_mem, fetch_reg, fetch_imm);
    signal fetch_state : fetch_type;
    type type_arr is array(natural range <>) of std_logic_vector(1 downto 0);
    signal argtype_arr : type_arr(4 downto 0);
    signal memchunk_arr : type_arr(4 downto 0);
    signal which : natural;
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

fetch_arg: process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            fetch_state <= idle;
            which <= 0;
            arg <= (others => (others => '0'));
            finished <= '0';
        else
            finished <= '0';
            if which = 4 then -- which is 31 bit?!?
                which <= 0;
                fetch_state <= idle;
            elsif (fetch_state = idle and start = '1') or fetch_state /= idle then
                case argtype_arr(which) is
                    when "01" =>
                        fetch_state <= fetch_reg;
                        which <= which + 1;
                    when "10" =>
                        fetch_state <= fetch_mem;
                        which <= which + 1;
                    when "11" =>
                        fetch_state <= fetch_imm;
                        which <= which + 1;
                    when others =>
                        fetch_state <= idle;
                        which <= 0;
                        finished <= '1';
                end case;
            end if;
            case fetch_state is
                when fetch_reg => arg(which) <= reg_data;
                when fetch_mem => arg(which) <= mem_data;
                when fetch_imm => arg(which) <= pdata;
                when idle =>
            end case;
        end if;
    end if;
end process fetch_arg;

mem_rd <= '1' when fetch_state = fetch_mem else
          '0';
reg_rd <= '1' when fetch_state = fetch_reg else
          '0';
mem_addr(9 downto 8) <= memchunk_arr(which);
mem_addr(7 downto 0) <= pdata;
reg_addr <= pdata;

end Structural;
