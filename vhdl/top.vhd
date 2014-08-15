library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.all;

use work.procedures.all;

entity top is
    port(
        rst     : in  std_logic;
        clk     : in  std_logic;

        rx      : in  std_logic;
        tx      : out std_logic
    );
end top;

architecture Structural of top is
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

    soc_i: entity work.soc
    port map(
        rst => rst_i,
        clk => clk_i,
        clk2x => clk2x_i,
        rx => rx,
        tx => tx
    );
end Structural;
