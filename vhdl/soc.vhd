library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.all;

use work.procedures.all;

entity soc is
    port(
        rst     : in  std_logic;
        clk     : in  std_logic;
        clk2x   : in  std_logic;

        pc      : out std_logic_vector(7 downto 0);

        rx      : in  std_logic;
        tx      : out std_logic
    );
end soc;

architecture Structural of soc is
    signal mem_enb : std_logic;
    signal mem_enb_1 : std_logic;
    signal mem_dob : t_data2;
    signal serial_ena : std_logic;
    signal serial_ena_1 : std_logic;
    signal serial_wea : std_logic;
    signal serial_doa : std_logic_vector(7 downto 0);
    signal serial_dib : std_logic_vector(7 downto 0);
    signal serial_busy : std_logic;
    signal ena : std_logic;
    signal addra : t_data2;
    signal doa : t_data2;
    signal enb : std_logic;
    signal addrb : t_data2;
    signal dob : t_data2;
    signal web : std_logic_vector(1 downto 0);
    signal dib : t_data2;
    signal bbusy : std_logic;
begin

pc <= addra(7 downto 0);

mem_enb <= enb when addrb(15 downto 12) = "0000" else
           '0';

mem_i: entity work.progmem
port map(
    clk => clk,

    addra => addra(11 downto 0),
    ena => ena,
    doa => doa,

    dib => dib,
    addrb => addrb(11 downto 0),
    enb => mem_enb,
    web => web,
    dob => mem_dob
);

serial_ena <= enb when addrb(15 downto 0) = X"FFFF" else
              '0';
serial_dib <= dib(7 downto 0) when web(0) = '1' else
              dib(15 downto 8);
serial_wea <= web(1) or web(0);
bbusy <= serial_busy when serial_ena = '1' else
         '0';

serial_i: entity work.serial
port map(
    rst => rst,
    clk => clk,

    rx => rx,
    tx => tx,

    ena => serial_ena,
    wea => serial_wea,
    dia => serial_dib,
    doa => serial_doa,
    busy => serial_busy
);

process(clk)
begin
    if rising_edge(clk) then
        mem_enb_1 <= mem_enb;
        serial_ena_1 <= serial_ena;
    end if;
end process;

dob <= mem_dob when mem_enb_1 = '1' else
       serial_doa & serial_doa when serial_ena_1 = '1' else
       (others => '0');

cpu_i: entity work.cpu
port map(
    rst => rst,
    clk => clk,
    clk2x => clk2x,

    ena => ena,
    addra => addra,
    doa => doa,
    enb => enb,
    addrb => addrb,
    dob => dob,
    web => web,
    dib => dib,
    bbusy => bbusy
);

end Structural;
