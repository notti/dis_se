library IEEE;
        use IEEE.STD_LOGIC_1164.ALL;
        use IEEE.NUMERIC_STD.ALL;
library std;
        use std.textio.all;

library work;
        use work.all;
        use work.procedures.all;

entity tb_mp_writeback is
end tb_mp_writeback;


architecture behav of tb_mp_writeback is
       signal rst     :  std_logic := '1';
       signal clk     :  std_logic := '0';
       signal cmd_in   :  t_vliw := empty_vliw;
       signal arg_in   :  t_data_array(4 downto 0) := (others => (others => '0'));
       signal val_in   :  t_data_array(4 downto 0) := (others => (others => '0'));
       signal mem_wr   :  std_logic := '0';
       signal mem_data :  t_data := (others => '0');
       signal mem_addr :  std_logic_vector(9 downto 0) := (others => '0'); 
       signal busy    :  std_logic := '0';
begin
    
    clock: process
    begin
        clk <= '0', '1' after 10 ns;
        wait for 20 ns;
    end process clock;

    process
        variable l : line;
    begin
        wait for 10 ns;
        wait for 40 ns;
        rst <= '0';
        wait for 80 ns;

        cmd_in.wb <= (0 => '1', others => '0');
        cmd_in.wb_assign <= (0 => "000", 1 => "001", 2 => "010", 3 => "011", 4 => "100");
        cmd_in.wb_memchunk <= (others => "00");
        arg_in <= (0=> X"01", 1=> X"02",2 => X"03", 3 => X"04", 4 => X"05");
        val_in <= (0=> X"11", 1=> X"12",2 => X"13", 3 => X"14", 4 => X"15");
        wait for 20 ns;
        cmd_in.wb_assign <= (0 => "001", 1 => "001", 2 => "010", 3 => "011", 4 => "100");
        wait for 20 ns;
        cmd_in.wb_assign <= (0 => "010", 1 => "001", 2 => "010", 3 => "011", 4 => "100");
        wait for 20 ns;
        cmd_in.wb_assign <= (0 => "011", 1 => "001", 2 => "010", 3 => "011", 4 => "100");
        wait for 20 ns;
        cmd_in.wb_assign <= (0 => "100", 1 => "001", 2 => "010", 3 => "011", 4 => "100");
        wait for 20 ns;
        cmd_in.wb <= (others => '0');
        wait for 40 ns;

        cmd_in.wb <= (0 => '1', 1 => '1', others => '0');
        cmd_in.wb_assign <= (0 => "000", 1 => "001", 2 => "010", 3 => "011", 4 => "100");
        wait for 20 ns;
        cmd_in.wb <= (others => '0');
        wait for 20 ns;
        cmd_in.wb <= (0 => '1', 1 => '1', others => '0');
        cmd_in.wb_assign <= (0 => "001", 1 => "001", 2 => "010", 3 => "011", 4 => "100");
        wait for 20 ns;
        cmd_in.wb <= (others => '0');
        wait for 20 ns;
        cmd_in.wb <= (0 => '1', 1 => '1', others => '0');
        cmd_in.wb_assign <= (0 => "010", 1 => "001", 2 => "010", 3 => "011", 4 => "100");
        wait for 20 ns;
        cmd_in.wb <= (others => '0');
        wait for 20 ns;
        cmd_in.wb <= (0 => '1', 1 => '1', others => '0');
        cmd_in.wb_assign <= (0 => "011", 1 => "001", 2 => "010", 3 => "011", 4 => "100");
        wait for 20 ns;
        cmd_in.wb <= (others => '0');
        wait for 20 ns;
        cmd_in.wb <= (0 => '1', 1 => '1', others => '0');
        cmd_in.wb_assign <= (0 => "100", 1 => "001", 2 => "010", 3 => "011", 4 => "100");
        wait for 20 ns;
        cmd_in.wb <= (others => '0');
        wait for 40 ns;

        cmd_in.wb <= (others => '1');
        cmd_in.wb_assign <= (0 => "000", 1 => "001", 2 => "010", 3 => "011", 4 => "100");
        wait for 20 ns;
        cmd_in.wb <= (others => '0');
        wait for 120 ns;
        cmd_in.wb <= (others => '1');
        cmd_in.wb_assign <= (0 => "001", 1 => "001", 2 => "010", 3 => "011", 4 => "100");
        wait for 20 ns;
        cmd_in.wb <= (others => '0');
        wait for 120 ns;
        cmd_in.wb <= (others => '1');
        cmd_in.wb_assign <= (0 => "010", 1 => "001", 2 => "010", 3 => "011", 4 => "100");
        wait for 20 ns;
        cmd_in.wb <= (others => '0');
        wait for 120 ns;
        cmd_in.wb <= (others => '1');
        cmd_in.wb_assign <= (0 => "011", 1 => "001", 2 => "010", 3 => "011", 4 => "100");
        wait for 20 ns;
        cmd_in.wb <= (others => '0');
        wait for 120 ns;
        cmd_in.wb <= (others => '1');
        cmd_in.wb_assign <= (0 => "100", 1 => "001", 2 => "010", 3 => "011", 4 => "100");
        wait for 20 ns;
        cmd_in.wb <= (others => '0');
        wait for 140 ns;

        cmd_in.wb <= (others => '1');
        cmd_in.wb_assign <= (0 => "000", 1 => "001", 2 => "010", 3 => "011", 4 => "100");
        wait for 20 ns;
        cmd_in.wb <= (others => '0');
        wait for 80 ns;
        cmd_in.wb <= (others => '1');
        cmd_in.wb_assign <= (0 => "001", 1 => "001", 2 => "010", 3 => "011", 4 => "100");
        wait for 20 ns;
        cmd_in.wb <= (others => '0');
        wait for 80 ns;
        cmd_in.wb <= (others => '1');
        cmd_in.wb_assign <= (0 => "010", 1 => "001", 2 => "010", 3 => "011", 4 => "100");
        wait for 20 ns;
        cmd_in.wb <= (others => '0');
        wait for 80 ns;
        cmd_in.wb <= (others => '1');
        cmd_in.wb_assign <= (0 => "011", 1 => "001", 2 => "010", 3 => "011", 4 => "100");
        wait for 20 ns;
        cmd_in.wb <= (others => '0');
        wait for 80 ns;
        cmd_in.wb <= (others => '1');
        cmd_in.wb_assign <= (0 => "100", 1 => "001", 2 => "010", 3 => "011", 4 => "100");
        wait for 20 ns;
        cmd_in.wb <= (others => '0');
        wait for 140 ns;
        wait for 160 ns;
        assert false report "stop" severity failure;
    end process;
    
    mp_writeback_i: entity work.mp_writeback
    port map(
        rst => rst,
        clk => clk,
        cmd_in => cmd_in,
        arg_in => arg_in,
        val_in => val_in,
        mem_wr => mem_wr,
        mem_data => mem_data,
        mem_addr => mem_addr,
        busy => busy
    );

end behav;
