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
       signal argtype :  std_logic_vector(9 downto 0) := (others => '0');
       signal memchunk :  std_logic_vector(9 downto 0) := (others => '0');
       signal mem_addr :  std_logic_vector(9 downto 0) := (others => '0'); 
       signal mem_rd   :  std_logic := '0';
       signal mem_data :  t_data := (others => '0');
       signal reg_addr :  t_data := (others => '0');
       signal reg_rd   :  std_logic := '0';
       signal reg_data :  t_data := (others => '0');
       signal arg      :  t_data_array(4 downto 0) := (others => (others => '0'));
       signal finished :  std_logic := '0';

       signal args     : t_data_array(4 downto 0) := (others => (others => '0'));
       signal cmd      : t_data;


       procedure do_cmd(signal cmd     : in  t_data;
                        signal args    : in  t_data_array(4 downto 0);
                        signal argtype : in std_logic_vector(9 downto 0);
                        signal start   : out std_logic;
                        signal pdata   : out t_data) is
       begin
           start <= '1';
           wait for 20 ns;
           start <= '0';
           for i in 0 to 4 loop
               if argtype(i*2+1 downto i*2) /= "00" then
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

        argtype  <= "0000000000";
        memchunk <= "0000000000";
        args <= ( X"01", X"02", X"03", X"04", X"05");
        cmd <= X"AA";
        do_cmd(cmd, args, argtype, start, pdata);

        argtype  <= "0101010101";
        memchunk <= "0000000000";
        args <= ( X"01", X"02", X"03", X"04", X"05");
        cmd <= X"BB";
        do_cmd(cmd, args, argtype, start, pdata);

        argtype  <= "1010101010";
        memchunk <= "0110110001";
        args <= ( X"01", X"02", X"03", X"04", X"05");
        cmd <= X"BB";
        do_cmd(cmd, args, argtype, start, pdata);

        wait for 20 ns;

        argtype  <= "1111111111";
        memchunk <= "0000000000";
        args <= ( X"01", X"02", X"03", X"04", X"05");
        cmd <= X"BB";
        do_cmd(cmd, args, argtype, start, pdata);

        wait for 80 ns;

        argtype  <= "0101101011";
        memchunk <= "0000000110";
        args <= ( X"01", X"02", X"03", X"04", X"05");
        cmd <= X"BB";
        do_cmd(cmd, args, argtype, start, pdata);

        argtype  <= "0000001111";
        memchunk <= "0000000110";
        args <= ( X"01", X"02", X"03", X"04", X"05");
        cmd <= X"BB";
        do_cmd(cmd, args, argtype, start, pdata);

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
        argtype => argtype,
        memchunk => memchunk,
        mem_addr => mem_addr,
        mem_rd => mem_rd,
        mem_data => mem_data,
        reg_addr => reg_addr,
        reg_rd => reg_rd,
        reg_data => reg_data,
        arg => arg,
        finished => finished
    );

end behav;
