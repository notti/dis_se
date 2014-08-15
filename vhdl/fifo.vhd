library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.all;

use work.procedures.all;


entity fifo is
    port(
        rst     : in  std_logic;
        clk     : in  std_logic;

        dia     : in  std_logic_vector(7 downto 0);
        ena     : in  std_logic;
        full    : out std_logic;

        dob     : out std_logic_vector(7 downto 0);
        enb     : in std_logic;
        empty   : out std_logic
    );
end fifo;

architecture Structural of fifo is
    signal addra : unsigned(10 downto 0);
    signal addrb : unsigned(10 downto 0);

    type mem_t is array(2047 downto 0) of std_logic_vector(7 downto 0);
    signal mem : mem_t;

    signal empty_i : std_logic;
    signal full_i : std_logic;
begin

process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            addra <= (others => '0');
            addrb <= (others => '0');
        else
            if ena = '1' and full_i = '0' then
                mem(to_integer(addra)) <= dia;
                addra <= addra + 1;
            end if;
            if enb = '1' and empty_i = '0' then
                dob <= mem(to_integer(addrb));
                addrb <= addrb + 1;
            end if;
        end if;
    end if;
end process;

empty_i <= '1' when addra = addrb else
           '0';
full_i <= '1' when addra = addrb - 1 else
          '0';
empty <= empty_i;
full <= full_i;

end Structural;
