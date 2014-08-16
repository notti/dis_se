library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.all;

use work.procedures.all;

entity progmem is
    port(
        clk     : in  std_logic;

        addra   : in  std_logic_vector(11 downto 0);
        ena     : in  std_logic;
        doa     : out t_data2;

        dib     : in  t_data2;
        addrb   : in  std_logic_vector(11 downto 0);
        enb     : in  std_logic;
        web     : in  std_logic_vector(1 downto 0);
        dob     : out t_data2
    );
end progmem;

architecture Structural of progmem is
    signal mem : t_data2_array(4095 downto 0) := (
        0 => X"CB0E",
        1 => X"FFFF",
        2 => X"C7E0",
        3 => X"FFFF",
        4 => X"001F",
        5 => X"0000",
        others => X"0000");
    signal di0 : t_data;
    signal di1 : t_data;
begin

-- "simple" xilinx style ram with byte wide write enable...
process(web, dib)
begin
    if web(1) = '1' then
        di1 <= dib(15 downto 8);
    else
        di1 <= mem(to_integer(unsigned(addrb)))(15 downto 8);
    end if;
    if web(0) = '1' then
        di0 <= dib(7 downto 0);
    else
        di0 <= mem(to_integer(unsigned(addrb)))(7 downto 0);
    end if;
end process;

process(clk)
begin
    if rising_edge(clk) then
        if ena = '1' then
            doa <= mem(to_integer(unsigned(addra)));
        end if;
        if enb = '1' then
            mem(to_integer(unsigned(addrb))) <= di1 & di0;
            dob <= mem(to_integer(unsigned(addrb)));
        end if;
    end if;
end process;

end Structural;
