library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.all;

use work.procedures.all;


entity r3w1mem is
    port(
        clk     : in  std_logic;

        addra   : in  std_logic_vector;
        ena     : in  std_logic;
        doa     : out std_logic_vector;
        addrb   : in  std_logic_vector;
        enb     : in  std_logic;
        dob     : out std_logic_vector;
        addrc   : in  std_logic_vector;
        enc     : in  std_logic;
        doc     : out std_logic_vector;
        addrd   : in  std_logic_vector;
        wed     : in  std_logic;
        did     : in  std_logic_vector
    );
end r3w1mem;

architecture Structural of r3w1mem is
    constant addr_max : natural := 2**addra'length-1;
    type mem_t is array(addr_max downto 0) of std_logic_vector(doa'range);
    signal mem : mem_t; -- := (others => (others => '0'));
begin

    assert addra'length = addrb'length report "addra and addrb ranges must match!" severity failure;
    assert addrb'length = addrc'length report "addrb and addrc ranges must match!" severity failure;
    assert addrc'length = addrd'length report "addrc and addrd ranges must match!" severity failure;
    assert doa'length = dob'length report "doa and dob ranges must match!" severity failure;
    assert dob'length = doc'length report "dob and doc ranges must match!" severity failure;
    assert doc'length = did'length report "doc and dod ranges must match!" severity failure;

    process(clk)
    begin
        if rising_edge(clk) then
            if ena = '1' then
                doa <= mem(to_integer(unsigned(addra)));
            end if;
            if enb = '1' then
                dob <= mem(to_integer(unsigned(addrb)));
            end if;
            if enc = '1' then
                doc <= mem(to_integer(unsigned(addrc)));
            end if;
            if wed = '1' then
                mem(to_integer(unsigned(addrd))) <= did;
            end if;
        end if;
    end process;

end Structural;
