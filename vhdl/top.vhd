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

        pc      : out std_logic_vector(7 downto 0);

        rx      : in  std_logic;
        tx      : out std_logic
    );
end top;

architecture Structural of top is
    signal rst_i : std_logic;
    signal clk2x_i : std_logic;
    signal clk_i : std_logic;
    signal pc_i : std_logic_vector(7 downto 0);
    signal rst_1 : std_logic;
    signal rst_2 : std_logic;
    signal rst_deb : std_logic;
    signal cnt : unsigned(19 downto 0);
begin

    process(clk)
    begin
        if rising_edge(clk_i) then
            pc <= pc_i;
        end if;
    end process;

    deb: process(clk)
    begin
        if rising_edge(clk_i) then
            rst_1 <= rst;
            rst_2 <= rst_1;
            if rst_1 /= rst_2 then
                cnt <= (others => '0');
            elsif cnt(19) = '1' then
                rst_deb <= rst_2;
            else
                cnt <= cnt + 1;
            end if;
        end if;
    end process;

    clkgen_i: entity work.clkgen
    port map(
        rsti => rst_deb,
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
        pc => pc_i,
        rx => rx,
        tx => tx
    );
end Structural;
