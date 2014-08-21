library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.all;

use work.procedures.all;

Library UNISIM;
use UNISIM.vcomponents.all;

entity clkgen is
    port(
        rsti     : in  std_logic;
        clki     : in  std_logic;

        rsto     : out std_logic;
        clko     : out std_logic;
        clk2xo   : out std_logic
    );
end clkgen;

architecture Structural of clkgen is
    signal locked : std_logic;
    signal clk_i : std_logic;
    signal clk_ubuf : std_logic;
    signal clk2x_ubuf : std_logic;
begin

    clk2x_buffer: BUFG
    port map(
        I => clk2x_ubuf,
        O => clk2xo
    );

    clk_buffer: BUFG
    port map(
        I => clk_ubuf,
        O => clk_i
    );

    DCM_SP_inst : DCM_SP
    generic map (
        CLKIN_PERIOD => 20.0,
        CLK_FEEDBACK => "1X",
        DFS_FREQUENCY_MODE => "LOW",
        DUTY_CYCLE_CORRECTION => FALSE,
        DLL_FREQUENCY_MODE => "LOW")
    port map (
        CLK0 => clk_ubuf,
        CLK180 => open,
        CLK270 => open,
        CLK2X => clk2x_ubuf,
        CLK2X180 => open,
        CLK90 => open,
        CLKDV => open,
        CLKFX => open,
        CLKFX180 => open,
        LOCKED => locked,
        PSDONE => open,
        STATUS => open,
        CLKFB => clk_i,
        CLKIN => clki,
        PSCLK => '0',
        PSEN => '0',
        PSINCDEC => '0',
        RST => '0',
        DSSEN => '0'
    );

    rsto <= rsti or not locked;
    clko <= clk_i;

end Structural;
