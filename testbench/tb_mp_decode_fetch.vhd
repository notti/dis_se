library IEEE;
        use IEEE.STD_LOGIC_1164.ALL;
        use IEEE.NUMERIC_STD.ALL;
library std;
        use std.textio.all;

library work;
        use work.all;
        use work.procedures.all;

entity tb_mp_decode_fetch is
end tb_mp_decode_fetch;


architecture behav of tb_mp_decode_fetch is
       signal rst     :  std_logic := '1';
       signal clk     :  std_logic := '0';
       signal pdata   :  t_data := (others => '0');
       signal pdata_rd : std_logic := '0';
       signal start   :  std_logic := '0';
       signal busy    :  std_logic := '0';
       signal mem_addr :  std_logic_vector(9 downto 0) := (others => '0'); 
       signal mem_rd   :  std_logic := '0';
       signal cmd_in   :  t_vliw := empty_vliw;
       signal mem_data :  t_data := (others => '0');
       signal reg_addr :  t_data := (others => '0');
       signal reg_rd   :  std_logic := '0';
       signal reg_data :  t_data := (others => '0');
       signal arg      :  t_data_array(4 downto 0) := (others => (others => '0'));
       signal cmd_out  :  t_vliw := empty_vliw;
       signal finished :  std_logic := '0';

       signal args     : t_data_array(4 downto 0) := (others => (others => '0'));
       signal cmd      : t_data;


       procedure do_cmd(signal cmd     : in  t_data;
                        signal args    : in  t_data_array(4 downto 0);
                        signal cmd_in  : in  t_vliw;
                        signal start   : out std_logic;
                        signal pdata   : out t_data) is
            variable x : std_logic_vector(1 downto 0);
       begin
           start <= '1';
           wait for 20 ns;
           start <= '0';
           for i in 0 to 4 loop
               if cmd_in.arg_type(i) /= "00" then
                   pdata <= args(i);
                   wait for 20 ns;
               end if;
           end loop;
       end procedure;

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
                reg_data <= std_logic_vector(i + 128);
            end if;
        end if;
    end process;

    process
        variable l : line;
    begin
        wait for 10 ns;
        wait for 40 ns;
        rst <= '0';

        cmd_in.arg_type <= (others => "00");
        cmd_in.arg_memchunk <= (others => "00");
        args <= ( X"01", X"02", X"03", X"04", X"05");
        cmd <= X"AA";
        do_cmd(cmd, args, cmd_in, start, pdata);

        cmd_in.arg_type <= (others => "01");
        cmd_in.arg_memchunk <= (others => "00");
        args <= ( X"01", X"02", X"03", X"04", X"05");
        cmd <= X"BB";
        do_cmd(cmd, args, cmd_in, start, pdata);

        wait for 20 ns;

        cmd_in.arg_type <= (others => "10");
        cmd_in.arg_memchunk <= (0 => "01", 1 => "00", 2 => "11", 3 => "10", 4 => "01");
        args <= ( X"01", X"02", X"03", X"04", X"05");
        cmd <= X"BB";
        do_cmd(cmd, args, cmd_in, start, pdata);

        wait for 20 ns;

        cmd_in.arg_type <= (others => "11");
        cmd_in.arg_memchunk <= (others => "00");
        args <= ( X"01", X"02", X"03", X"04", X"05");
        cmd <= X"BB";
        do_cmd(cmd, args, cmd_in, start, pdata);

        wait for 80 ns;

        cmd_in.arg_type <= (0 => "11", 1 => "10", 2 => "10", 3 => "01", 4 => "01");
        cmd_in.arg_memchunk <= (0 => "10", 1 => "01", others => "00");
        args <= ( X"01", X"02", X"03", X"04", X"05");
        cmd <= X"BB";
        do_cmd(cmd, args, cmd_in, start, pdata);

        wait for 20 ns;

        cmd_in.arg_type <= (0 => "11", 1 => "11", others => "00");
        cmd_in.arg_memchunk <= (0 => "10", 1 => "01", others => "00");
        args <= ( X"01", X"02", X"03", X"04", X"05");
        cmd <= X"BB";
        do_cmd(cmd, args, cmd_in, start, pdata);

        wait for 60 ns;
        assert false report "stop" severity failure;
    end process;
    
    mp_decode_fetch_i: entity work.mp_decode_fetch
    port map(
        rst => rst,
        clk => clk,
        pdata => pdata,
        pdata_rd => pdata_rd,
        start => start,
        busy => busy,
        cmd_in => cmd_in,
        mem_addr => mem_addr,
        mem_rd => mem_rd,
        mem_data => mem_data,
        reg_addr => reg_addr,
        reg_rd => reg_rd,
        reg_data => reg_data,
        arg => arg,
        cmd_out => cmd_out,
        finished => finished
    );

end behav;
