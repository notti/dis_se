library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.all;

use work.procedures.all;

entity mpt is
    port(
        rst     : in  std_logic;
        clk     : in  std_logic;
        pdata   : in  t_data2;
        pdata_rd : out std_logic;
        start   : in  std_logic;
        busy    : out std_logic;

        mem_addra : in std_logic_vector(9 downto 0);
        mem_ena   : in std_logic;
        mem_doa : out t_data;
        mem_addrb : in std_logic_vector(9 downto 0);
        mem_enb   : in std_logic;
        mem_dob : out t_data;

        reg_addra : out t_data;
        reg_ena   : out std_logic;
        reg_doa   : in  t_data;
        reg_addrb : out t_data;
        reg_enb   : out std_logic;
        reg_dob   : in  t_data
    );
end mpt;

architecture Structural of mpt is
    signal rst_i : std_logic;
    signal clk2x_i : std_logic;
    signal clk_i : std_logic;
begin

    clkgen_i: entity work.clkgen
    port map(
        rsti => rst,
        clki => clk,
        rsto => rst_i,
        clko => clk_i,
        clk2xo => clk2x_i
    );

    mp_i: entity work.mp
    port map(
        rst => rst_i,
        clk => clk_i,
        clk2x => clk2x_i,
        pdata => pdata,
        pdata_rd => pdata_rd,
        start => start,
        busy => busy,

        mem_addra => mem_addra,
        mem_ena => mem_ena,
        mem_doa => mem_doa,
        mem_addrb => mem_addrb,
        mem_enb => mem_enb,
        mem_dob => mem_dob,

        reg_addra => reg_addra,
        reg_ena => reg_ena,
        reg_doa => reg_doa,
        reg_addrb => reg_addrb,
        reg_enb => reg_enb,
        reg_dob => reg_dob
    );
end Structural;
