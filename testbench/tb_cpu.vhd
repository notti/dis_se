library IEEE;
        use IEEE.STD_LOGIC_1164.ALL;
        use IEEE.NUMERIC_STD.ALL;
library std;
        use std.textio.all;

library work;
        use work.all;
        use work.procedures.all;

entity tb_cpu is
end tb_cpu;


architecture behav of tb_cpu is
    signal rst : std_logic := '1';
    signal clk : std_logic := '0';
    signal clk2x : std_logic := '0';
    signal ena : std_logic := '0';
    signal addra : t_data2 := (others => '0');
    signal doa : t_data2 := (others => '0');
    signal enb : std_logic := '0';
    signal addrb : t_data2 := (others => '0');
    signal dob : t_data2 := (others => '0');
    signal web : std_logic_vector(1 downto 0) := (others => '0');
    signal dib : t_data2 := (others => '0');
    signal bbusy : std_logic := '0';

    signal mem : t_data2_array(4095 downto 0) := (others => (others => '0'));
    signal serial : t_data_array(1023 downto 0) :=
        (0 => X"55",
         1 => X"AA",
         2 => X"00",
         3 => X"00",
         4 => X"1a",
         5 => X"00",
         6 => X"34",
         7 => X"00",
         8 => X"4B",
         9 => X"00",
         10 => X"5F",
         11 => X"00",
         others => X"00");

    procedure hex2slv(c : character; slv : out std_logic_vector(3 downto 0); good : out boolean) is
    begin
        good := true;
        case c is
            when 'A' to 'F' => slv := std_logic_vector(to_unsigned(character'pos(c) - character'pos('A') + 10, 4)); return;
            when 'a' to 'f' => slv := std_logic_vector(to_unsigned(character'pos(c) - character'pos('a') + 10, 4)); return;
            when '0' to '9' => slv := std_logic_vector(to_unsigned(character'pos(c) - character'pos('0'), 4)); return;
            when others => good := false; return;
        end case;
    end procedure;

    signal init : boolean := false;

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

    process(clk)
        file memfile : text;
        variable fname : string(1 to 63) := "/home/notti/uni/master/dis_vertiefung/se/project/src/fft_mp.mem";
        variable buf_in, buf_out : line;
        variable f_status : FILE_OPEN_STATUS;
        variable good: boolean := true;
        variable o: character;
        variable i: integer := 1;
        variable val: std_logic_vector(15 downto 0);
    begin
        if rising_edge(clk) then
            if rst = '1' and init = false then
                file_open(f_status, memfile, fname, read_mode);
                readline(memfile, buf_in);
                for j in 0 to 4 loop
                    read(buf_in, o, good);
                    assert good report "memfile error" severity failure;
                end loop;
                i := 0;
                loop
                    read(buf_in, o, good);
                    exit when not good;
                    assert o = ' ' report "memfile error: " & o severity failure;
                    for j in 3 downto 0 loop
                        read(buf_in, o, good);
                        assert good report "memfile error" severity failure;
                        hex2slv(o, val((j+1)*4-1 downto j*4), good);
                        assert good report "memfile error" severity failure;
                    end loop;
                    mem(i) <= val;
                    i := i + 1;
                end loop;
                assert false report "read " & integer'image(i) & " tokens" severity note;
                init <= true;
                i := 0;
            elsif rst = '0' then
                if ena = '1' then
                    doa <= mem(to_integer(unsigned(addra)));
                end if;
                if enb = '1' then
                    if addrb = X"FFFF" then
                        if web = "00" then
                            if i = 10 then
                                assert false report "stop" severity failure;
                            end if;
                            dob <= serial(i) & serial(i);
                            i := i + 1;
                        else
                            assert false report integer'image(to_integer(unsigned(dib(7 downto 0)))) severity note;
                        end if;
                    else
                        dob <= mem(to_integer(unsigned(addrb)));
                        if web(1) = '1' then
                            mem(to_integer(unsigned(addrb)))(15 downto 8) <= dib(15 downto 8);
                        end if;
                        if web(0) = '1' then
                            mem(to_integer(unsigned(addrb)))(7 downto 0) <= dib(7 downto 0);
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;
    
    process
    begin
        wait for 61 ns;
        rst <= '0';
        wait for 20 ns;
    end process;
    
    asoc: entity work.cpu
    port map(
        rst => rst,
        clk => clk,
        clk2x => clk2x,
        ena => ena,
        addra => addra,
        doa => doa,
        enb => enb,
        addrb => addrb,
        dob => dob,
        web => web,
        dib => dib,
        bbusy => bbusy
    );

end behav;
