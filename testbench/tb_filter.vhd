library IEEE;
        use IEEE.STD_LOGIC_1164.ALL;
        use IEEE.NUMERIC_STD.ALL;
library std;
        use std.textio.all;

library work;
        use work.all;
        use work.procedures.all;

entity tb_filter is
end tb_filter;


architecture behav of tb_filter is
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
        (32 => X"3F",
         33 => X"3F",
         34 => X"3F",
         35 => X"3F",
         36 => X"3F",
         37 => X"3F",
         38 => X"3F",
         39 => X"3F",
         40 => X"3F",
         41 => X"3F",
         42 => X"3F",
         43 => X"3F",
         44 => X"3F",
         45 => X"3F",
         46 => X"3F",
         47 => X"3F",
         48 => X"3F",
         49 => X"3F",
         50 => X"3F",
         51 => X"3F",
         52 => X"3F",
         53 => X"3F",
         54 => X"3F",
         55 => X"3F",
         56 => X"3F",
         57 => X"3F",
         58 => X"3F",
         59 => X"3F",
         60 => X"3F",
         61 => X"3F",
         62 => X"3F",
         63 => X"3F",
         64 => X"3F",
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
        variable fname : string(1 to 63) := "/home/notti/uni/master/dis_vertiefung/se/project/src/filter.mem";
        variable buf_in, buf_out : line;
        variable f_status : FILE_OPEN_STATUS;
        variable good: boolean := true;
        variable o: character;
        variable i: integer := 1;
        variable val: std_logic_vector(15 downto 0);
        variable ser_out : integer;
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
                    for j in 0 to 3 loop
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
                            if i = 64 then
                                assert false report "stop" severity failure;
                            end if;
                            dob <= serial(i) & serial(i);
                            i := i + 1;
                        else
                            if web(0) = '1' then
                                ser_out := to_integer(signed(dib(7 downto 0)));
                                write(buf_out, ser_out);
                                writeline(output, buf_out);
                            end if;
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
