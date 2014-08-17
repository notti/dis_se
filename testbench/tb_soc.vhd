library IEEE;
        use IEEE.STD_LOGIC_1164.ALL;
        use IEEE.NUMERIC_STD.ALL;
library std;
        use std.textio.all;

library work;
        use work.all;
        use work.procedures.all;

entity tb_soc is
end tb_soc;


architecture behav of tb_soc is
    signal rst : std_logic := '1';
    signal clk : std_logic := '0';
    signal clk2x : std_logic := '0';
    signal rx  : std_logic := '1';
    signal tx  : std_logic := '1';

    procedure write(x : std_logic_vector(7 downto 0); signal rx : out std_logic) is
    begin
        rx <= '0';
        wait for 8681 ns;
        for i in 0 to 7 loop
            rx <= x(i);
            wait for 8681 ns;
        end loop;
        rx <= '1';
        wait for 8681 ns;
    end procedure;

begin

    process
    begin
        clk <= '1';
        clk2x <= '1';
        wait for 5 ns;
        clk2x <= '0';
        wait for 5 ns;
        clk <= '0';
        clk2x <= '1';
        wait for 5 ns;
        clk2x <= '0';
        wait for 5 ns;
    end process;
    
    process
        variable l : line;
    begin
        wait for 61 ns;
        rst <= '0';
        wait for 100 ns;
        write(X"AA", rx);
        write(X"00", rx);
        write(X"55", rx);
        write(X"01", rx);
        wait for 100 us;

        assert false report "stop" severity failure;
    end process;
    
    asoc: entity work.soc
    port map(
        rst => rst,
        clk => clk,
        clk2x => clk2x,
        rx => rx,
        tx => tx
    );

end behav;
