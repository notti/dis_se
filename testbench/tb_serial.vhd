library IEEE;
        use IEEE.STD_LOGIC_1164.ALL;
        use IEEE.NUMERIC_STD.ALL;
library std;
        use std.textio.all;

library work;
        use work.all;
        use work.procedures.all;

entity tb_serial is
end tb_serial;


architecture behav of tb_serial is
    signal rst : std_logic := '1';
    signal clk : std_logic := '0';
    signal rx  : std_logic := '1';
    signal tx  : std_logic := '1';
    signal ena : std_logic := '0';
    signal wea : std_logic := '0';
    signal dia : std_logic_vector(7 downto 0) := (others => '0');
    signal doa : std_logic_vector(7 downto 0) := (others => '0');
    signal busy : std_logic := '0';

begin

    process
    begin
        clk <= '1';
        wait for 10 ns;
        clk <= '0';
        wait for 10 ns;
    end process;
    
    process
        variable l : line;
    begin
        wait for 61 ns;
        rst <= '0';
        wait for 20 ns;
        ena <= '1';
        wea <= '1';
        dia <= X"A1";
        wait for 20 ns;
        dia <= X"A2";
        wait for 20 ns;
        dia <= X"A3";
        wait for 20 ns;
        wea <= '0';
        wait for 300 us;

        assert false report "stop" severity failure;
    end process;
    
    aserial: entity work.serial
    port map(
        rst => rst,
        clk => clk,
        rx => rx,
        tx => tx,
        ena => ena,
        wea => wea,
        dia => dia,
        doa => doa,
        busy => busy
    );

    rx <= tx;

end behav;
