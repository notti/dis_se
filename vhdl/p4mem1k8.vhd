library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.all;

use work.procedures.all;

Library UNISIM;
use UNISIM.vcomponents.all;

entity p4mem1k8 is
    port(
        clk     : in  std_logic;
        clk2x   : in  std_logic;

        dia     : in  t_data;
        addra   : in  std_logic_vector(9 downto 0);
        ena     : in  std_logic;
        wea     : in  std_logic;
        doa     : out t_data;

        dib     : in  t_data;
        addrb   : in  std_logic_vector(9 downto 0);
        enb     : in  std_logic;
        web     : in  std_logic;
        dob     : out t_data;

        dic     : in  t_data;
        addrc   : in  std_logic_vector(9 downto 0);
        enc     : in  std_logic;
        wec     : in  std_logic;
        doc     : out t_data;

        did     : in  t_data;
        addrd   : in  std_logic_vector(9 downto 0);
        en_d    : in  std_logic;
        wed     : in  std_logic;
        dod     : out t_data
    );
end p4mem1k8;

architecture Structural of p4mem1k8 is
    signal int_dia     : t_data;
    signal int_addra   : std_logic_vector(10 downto 0);
    signal int_ena     : std_logic;
    signal int_wea     : std_logic;
    signal int_doa     : t_data;

    signal int_dib     : t_data;
    signal int_addrb   : std_logic_vector(10 downto 0);
    signal int_enb     : std_logic;
    signal int_web     : std_logic;
    signal int_dob     : t_data;

    signal enb1 : std_logic;
    signal end1 : std_logic;
begin

    RAMB16_S9_S9_inst : RAMB16_S9_S9
    generic map (
        WRITE_MODE_A => "WRITE_FIRST",
        WRITE_MODE_B => "WRITE_FIRST",
        SIM_COLLISION_CHECK => "ALL")
    port map (
        DOA => int_doa,
        DOB => int_dob,
        DOPA => open,
        DOPB => open,
        ADDRA => int_addra,
        ADDRB => int_addrb,
        CLKA => clk2x,
        CLKB => clk2x,
        DIA => int_dia,
        DIB => int_dib,
        DIPA => "1",
        DIPB => "1",
        ENA => int_ena,
        ENB => int_enb,
        SSRA => '0',
        SSRB => '0',
        WEA => int_wea,
        WEB => int_web
    );

    int_addra(10) <= '1';
    int_addrb(10) <= '1';

    int_dia <= dia when clk = '1' else
               dib;
    int_addra(9 downto 0) <= addra when clk = '1' else
                 addrb;
    int_ena <= ena when clk = '1' else
               enb;
    int_wea <= wea when clk = '1' else
               web;

    int_dib <= dic when clk = '1' else
               did;
    int_addrb(9 downto 0) <= addrc when clk = '1' else
                 addrd;
    int_enb <= enc when clk = '1' else
               en_d;
    int_web <= wec when clk = '1' else
               wed;

    outputs: process(clk)
    begin
        if rising_edge(clk) then
            if ena = '1' then
                doa <= int_doa;
            end if;
            if enc = '1' then
                doc <= int_dob;
            end if;
        end if;
        if falling_edge(clk) then
            if enb1 = '1' then
                dob <= int_doa;
            end if;
            if end1 = '1' then
                dod <= int_dob;
            end if;
            enb1 <= enb;
            end1 <= en_d;
        end if;
    end process;

end Structural;
