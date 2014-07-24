library IEEE;
        use IEEE.STD_LOGIC_1164.ALL;
        use IEEE.NUMERIC_STD.ALL;
library std;
        use std.textio.all;

library work;
        use work.all;
        use work.procedures.all;

entity tb_mp_indirect_fetch is
end tb_mp_indirect_fetch;


architecture behav of tb_mp_indirect_fetch is
       signal rst     :  std_logic := '1';
       signal clk     :  std_logic := '0';
       signal start   :  std_logic := '0';
       signal cmd_in   :  t_vliw := empty_vliw;
       signal arg_in   :  t_data_array(4 downto 0) := (others => (others => '0'));
       signal mem_addr :  std_logic_vector(9 downto 0) := (others => '0'); 
       signal mem_rd   :  std_logic := '0';
       signal mem_data :  t_data := (others => '0');
       signal arg_out  :  t_data_array(4 downto 0) := (others => (others => '0'));
       signal val_out  :  t_data_array(4 downto 0) := (others => (others => '0'));
       signal cmd_out  :  t_vliw := empty_vliw;
       signal busy    :  std_logic := '0';
       signal finished :  std_logic := '0';

begin
    
    clock: process
    begin
        clk <= '0', '1' after 10 ns;
        wait for 20 ns;
    end process clock;

    process(clk)
        variable i : unsigned(7 downto 0) := (others => '0');
    begin
        if rising_edge(clk) then
            if rst = '1' then
                i := (others => '0');
            else
                i := i + 1;
                mem_data <= std_logic_vector(i);
            end if;
        end if;
    end process;

    process
        variable l : line;
    begin
        wait for 10 ns;
        wait for 40 ns;
        rst <= '0';

        cmd_in.last_val <= '0';
        cmd_in.arg_assign <= (0 => "000", 1 => "001", 2 => "010", 3 => "011", 4 => "100");
        cmd_in.mem_fetch <= (others => '0');
        cmd_in.mem_memchunk <= (others => "00");
        arg_in <= ( X"01", X"02", X"03", X"04", X"05");
        start <= '1';
        wait for 20 ns;
        start <= '0';
        wait for 40 ns;
        arg_in <= ( X"02", X"03", X"04", X"05", X"06");
        start <= '1';
        wait for 20 ns;
        arg_in <= ( X"03", X"04", X"05", X"06", X"07");
        wait for 20 ns;
        start <= '0';
        wait for 80 ns;

        cmd_in.last_val <= '0';
        cmd_in.arg_assign <= (0 => "000", 1 => "001", 2 => "010", 3 => "011", 4 => "100");
        cmd_in.mem_fetch <= (others => '1');
        cmd_in.mem_memchunk <= (0 => "00", 1 => "01", 2 => "10", 3 => "11", 4 => "00");
        arg_in <= ( X"01", X"02", X"03", X"04", X"05");
        start <= '1';
        wait for 20 ns;
        start <= '0';
        wait for 160 ns;

        cmd_in.last_val <= '1';
        cmd_in.arg_assign <= (0 => "000", 1 => "001", 2 => "010", 3 => "011", 4 => "100");
        cmd_in.mem_fetch <= (others => '0');
        cmd_in.mem_memchunk <= (others => "00");
        arg_in <= ( X"01", X"02", X"03", X"04", X"05");
        start <= '1';
        wait for 20 ns;
        start <= '0';
        wait for 160 ns;

        cmd_in.last_val <= '0';
        cmd_in.arg_assign <= (3 => "000", 0 => "001", 2 => "010", 1 => "011", 4 => "100");
        cmd_in.mem_fetch <= (0 => '1', 1 => '1', others => '0');
        cmd_in.mem_memchunk <= (0 => "00", 1 => "01", others => "00");
        arg_in <= ( X"01", X"02", X"03", X"04", X"05");
        start <= '1';
        wait for 20 ns;
        start <= '0';
        wait for 160 ns;

        assert false report "stop" severity failure;
    end process;
    
    mp_indirect_fetch_i: entity work.mp_indirect_fetch
    port map(
        rst => rst,
        clk => clk,
        start => start,
        cmd_in => cmd_in,
        arg_in => arg_in,
        mem_addr => mem_addr,
        mem_rd => mem_rd,
        mem_data => mem_data,
        arg_out => arg_out,
        val_out => val_out,
        cmd_out => cmd_out,
        busy => busy,
        finished => finished
    );

end behav;
