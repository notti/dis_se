library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.all;

use work.procedures.all;

Library UNISIM;
use UNISIM.vcomponents.all;

entity r6w2mem1k8 is
    port(
        clk     : in  std_logic;
        clk2x   : in  std_logic;

        addra   : in  std_logic_vector(9 downto 0);
        ena     : in  std_logic;
        doa     : out t_data;

        addrb   : in  std_logic_vector(9 downto 0);
        enb     : in  std_logic;
        dob     : out t_data;

        addrc   : in  std_logic_vector(9 downto 0);
        enc     : in  std_logic;
        doc     : out t_data;

        addrd   : in  std_logic_vector(9 downto 0);
        en_d    : in  std_logic;
        dod     : out t_data;

        addre   : in  std_logic_vector(9 downto 0);
        ene     : in  std_logic;
        doe     : out t_data;

        addrf   : in  std_logic_vector(9 downto 0);
        enf     : in  std_logic;
        dof     : out t_data;

        dig     : in  t_data;
        addrg   : in  std_logic_vector(9 downto 0);
        weg     : in  std_logic;

        dih     : in  t_data;
        addrh   : in  std_logic_vector(9 downto 0);
        weh     : in  std_logic
    );
end r6w2mem1k8;

architecture Structural of r6w2mem1k8 is
begin

    p4mem1k8_0: entity work.p4mem1k8
    port map(
        clk => clk,
        clk2x => clk2x,

        dia => (others => '0'),
        addra => addra,
        ena => ena,
        wea => '0',
        doa => doa,

        dib => dig,
        addrb => addrg,
        enb => weg,
        web => weg,
        dob => open,

        dic => (others => '0'),
        addrc => addrb,
        enc => enb,
        wec => '0',
        doc => dob,

        did => dih,
        addrd => addrh,
        en_d => weh,
        wed => weh,
        dod => open
    );

    p4mem1k8_1: entity work.p4mem1k8
    port map(
        clk => clk,
        clk2x => clk2x,

        dia => (others => '0'),
        addra => addrc,
        ena => enc,
        wea => '0',
        doa => doc,

        dib => dig,
        addrb => addrg,
        enb => weg,
        web => weg,
        dob => open,

        dic => (others => '0'),
        addrc => addrd,
        enc => en_d,
        wec => '0',
        doc => dod,

        did => dih,
        addrd => addrh,
        en_d => weh,
        wed => weh,
        dod => open
    );

    p4mem1k8_2: entity work.p4mem1k8
    port map(
        clk => clk,
        clk2x => clk2x,

        dia => (others => '0'),
        addra => addre,
        ena => ene,
        wea => '0',
        doa => doe,

        dib => dig,
        addrb => addrg,
        enb => weg,
        web => weg,
        dob => open,

        dic => (others => '0'),
        addrc => addrf,
        enc => enf,
        wec => '0',
        doc => dof,

        did => dih,
        addrd => addrh,
        en_d => weh,
        wed => weh,
        dod => open
    );

end Structural;
