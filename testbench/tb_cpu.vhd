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
         8 => X"4b",
         9 => X"00",
         10 => X"5f",
         11 => X"00",
         12 => X"6e",
         13 => X"00",
         14 => X"79",
         15 => X"00",
         16 => X"7f",
         17 => X"00",
         18 => X"7f",
         19 => X"00",
         20 => X"79",
         21 => X"00",
         22 => X"6e",
         23 => X"00",
         24 => X"5f",
         25 => X"00",
         26 => X"4b",
         27 => X"00",
         28 => X"34",
         29 => X"00",
         30 => X"1a",
         31 => X"00",
         32 => X"00",
         33 => X"00",
         34 => X"e6",
         35 => X"00",
         36 => X"cc",
         37 => X"00",
         38 => X"b5",
         39 => X"00",
         40 => X"a1",
         41 => X"00",
         42 => X"92",
         43 => X"00",
         44 => X"87",
         45 => X"00",
         46 => X"81",
         47 => X"00",
         48 => X"81",
         49 => X"00",
         50 => X"87",
         51 => X"00",
         52 => X"92",
         53 => X"00",
         54 => X"a1",
         55 => X"00",
         56 => X"b5",
         57 => X"00",
         58 => X"cc",
         59 => X"00",
         60 => X"e6",
         61 => X"00",
         62 => X"00",
         63 => X"00",
         64 => X"1a",
         65 => X"00",
         66 => X"34",
         67 => X"00",
         68 => X"4b",
         69 => X"00",
         70 => X"5f",
         71 => X"00",
         72 => X"6e",
         73 => X"00",
         74 => X"79",
         75 => X"00",
         76 => X"7f",
         77 => X"00",
         78 => X"7f",
         79 => X"00",
         80 => X"79",
         81 => X"00",
         82 => X"6e",
         83 => X"00",
         84 => X"5f",
         85 => X"00",
         86 => X"4b",
         87 => X"00",
         88 => X"34",
         89 => X"00",
         90 => X"1a",
         91 => X"00",
         92 => X"00",
         93 => X"00",
         94 => X"e6",
         95 => X"00",
         96 => X"cc",
         97 => X"00",
         98 => X"b5",
         99 => X"00",
         100 => X"a1",
         101 => X"00",
         102 => X"92",
         103 => X"00",
         104 => X"87",
         105 => X"00",
         106 => X"81",
         107 => X"00",
         108 => X"81",
         109 => X"00",
         110 => X"87",
         111 => X"00",
         112 => X"92",
         113 => X"00",
         114 => X"a1",
         115 => X"00",
         116 => X"b5",
         117 => X"00",
         118 => X"cc",
         119 => X"00",
         120 => X"e6",
         121 => X"00",
         122 => X"00",
         123 => X"00",
         124 => X"1a",
         125 => X"00",
         126 => X"34",
         127 => X"00",
         128 => X"4b",
         129 => X"00",
         130 => X"5f",
         131 => X"00",
         132 => X"6e",
         133 => X"00",
         134 => X"79",
         135 => X"00",
         136 => X"7f",
         137 => X"00",
         138 => X"7f",
         139 => X"00",
         140 => X"79",
         141 => X"00",
         142 => X"6e",
         143 => X"00",
         144 => X"5f",
         145 => X"00",
         146 => X"4b",
         147 => X"00",
         148 => X"34",
         149 => X"00",
         150 => X"1a",
         151 => X"00",
         152 => X"00",
         153 => X"00",
         154 => X"e6",
         155 => X"00",
         156 => X"cc",
         157 => X"00",
         158 => X"b5",
         159 => X"00",
         160 => X"a1",
         161 => X"00",
         162 => X"92",
         163 => X"00",
         164 => X"87",
         165 => X"00",
         166 => X"81",
         167 => X"00",
         168 => X"81",
         169 => X"00",
         170 => X"87",
         171 => X"00",
         172 => X"92",
         173 => X"00",
         174 => X"a1",
         175 => X"00",
         176 => X"b5",
         177 => X"00",
         178 => X"cc",
         179 => X"00",
         180 => X"e6",
         181 => X"00",
         182 => X"00",
         183 => X"00",
         184 => X"1a",
         185 => X"00",
         186 => X"34",
         187 => X"00",
         188 => X"4b",
         189 => X"00",
         190 => X"5f",
         191 => X"00",
         192 => X"6e",
         193 => X"00",
         194 => X"79",
         195 => X"00",
         196 => X"7f",
         197 => X"00",
         198 => X"7f",
         199 => X"00",
         200 => X"79",
         201 => X"00",
         202 => X"6e",
         203 => X"00",
         204 => X"5f",
         205 => X"00",
         206 => X"4b",
         207 => X"00",
         208 => X"34",
         209 => X"00",
         210 => X"1a",
         211 => X"00",
         212 => X"00",
         213 => X"00",
         214 => X"e6",
         215 => X"00",
         216 => X"cc",
         217 => X"00",
         218 => X"b5",
         219 => X"00",
         220 => X"a1",
         221 => X"00",
         222 => X"92",
         223 => X"00",
         224 => X"87",
         225 => X"00",
         226 => X"81",
         227 => X"00",
         228 => X"81",
         229 => X"00",
         230 => X"87",
         231 => X"00",
         232 => X"92",
         233 => X"00",
         234 => X"a1",
         235 => X"00",
         236 => X"b5",
         237 => X"00",
         238 => X"cc",
         239 => X"00",
         240 => X"e6",
         241 => X"00",
         242 => X"00",
         243 => X"00",
         244 => X"1a",
         245 => X"00",
         246 => X"34",
         247 => X"00",
         248 => X"4b",
         249 => X"00",
         250 => X"5f",
         251 => X"00",
         252 => X"6e",
         253 => X"00",
         254 => X"79",
         255 => X"00",
         256 => X"7f",
         257 => X"00",
         258 => X"7f",
         259 => X"00",
         260 => X"79",
         261 => X"00",
         262 => X"6e",
         263 => X"00",
         264 => X"5f",
         265 => X"00",
         266 => X"4b",
         267 => X"00",
         268 => X"34",
         269 => X"00",
         270 => X"1a",
         271 => X"00",
         272 => X"00",
         273 => X"00",
         274 => X"e6",
         275 => X"00",
         276 => X"cc",
         277 => X"00",
         278 => X"b5",
         279 => X"00",
         280 => X"a1",
         281 => X"00",
         282 => X"92",
         283 => X"00",
         284 => X"87",
         285 => X"00",
         286 => X"81",
         287 => X"00",
         288 => X"81",
         289 => X"00",
         290 => X"87",
         291 => X"00",
         292 => X"92",
         293 => X"00",
         294 => X"a1",
         295 => X"00",
         296 => X"b5",
         297 => X"00",
         298 => X"cc",
         299 => X"00",
         300 => X"e6",
         301 => X"00",
         302 => X"00",
         303 => X"00",
         304 => X"1a",
         305 => X"00",
         306 => X"34",
         307 => X"00",
         308 => X"4b",
         309 => X"00",
         310 => X"5f",
         311 => X"00",
         312 => X"6e",
         313 => X"00",
         314 => X"79",
         315 => X"00",
         316 => X"7f",
         317 => X"00",
         318 => X"7f",
         319 => X"00",
         320 => X"79",
         321 => X"00",
         322 => X"6e",
         323 => X"00",
         324 => X"5f",
         325 => X"00",
         326 => X"4b",
         327 => X"00",
         328 => X"34",
         329 => X"00",
         330 => X"1a",
         331 => X"00",
         332 => X"00",
         333 => X"00",
         334 => X"e6",
         335 => X"00",
         336 => X"cc",
         337 => X"00",
         338 => X"b5",
         339 => X"00",
         340 => X"a1",
         341 => X"00",
         342 => X"92",
         343 => X"00",
         344 => X"87",
         345 => X"00",
         346 => X"81",
         347 => X"00",
         348 => X"81",
         349 => X"00",
         350 => X"87",
         351 => X"00",
         352 => X"92",
         353 => X"00",
         354 => X"a1",
         355 => X"00",
         356 => X"b5",
         357 => X"00",
         358 => X"cc",
         359 => X"00",
         360 => X"e6",
         361 => X"00",
         362 => X"00",
         363 => X"00",
         364 => X"1a",
         365 => X"00",
         366 => X"34",
         367 => X"00",
         368 => X"4b",
         369 => X"00",
         370 => X"5f",
         371 => X"00",
         372 => X"6e",
         373 => X"00",
         374 => X"79",
         375 => X"00",
         376 => X"7f",
         377 => X"00",
         378 => X"7f",
         379 => X"00",
         380 => X"79",
         381 => X"00",
         382 => X"6e",
         383 => X"00",
         384 => X"5f",
         385 => X"00",
         386 => X"4b",
         387 => X"00",
         388 => X"34",
         389 => X"00",
         390 => X"1a",
         391 => X"00",
         392 => X"00",
         393 => X"00",
         394 => X"e6",
         395 => X"00",
         396 => X"cc",
         397 => X"00",
         398 => X"b5",
         399 => X"00",
         400 => X"a1",
         401 => X"00",
         402 => X"92",
         403 => X"00",
         404 => X"87",
         405 => X"00",
         406 => X"81",
         407 => X"00",
         408 => X"81",
         409 => X"00",
         410 => X"87",
         411 => X"00",
         412 => X"92",
         413 => X"00",
         414 => X"a1",
         415 => X"00",
         416 => X"b5",
         417 => X"00",
         418 => X"cc",
         419 => X"00",
         420 => X"e6",
         421 => X"00",
         422 => X"00",
         423 => X"00",
         424 => X"1a",
         425 => X"00",
         426 => X"34",
         427 => X"00",
         428 => X"4b",
         429 => X"00",
         430 => X"5f",
         431 => X"00",
         432 => X"6e",
         433 => X"00",
         434 => X"79",
         435 => X"00",
         436 => X"7f",
         437 => X"00",
         438 => X"7f",
         439 => X"00",
         440 => X"79",
         441 => X"00",
         442 => X"6e",
         443 => X"00",
         444 => X"5f",
         445 => X"00",
         446 => X"4b",
         447 => X"00",
         448 => X"34",
         449 => X"00",
         450 => X"1a",
         451 => X"00",
         452 => X"00",
         453 => X"00",
         454 => X"e6",
         455 => X"00",
         456 => X"cc",
         457 => X"00",
         458 => X"b5",
         459 => X"00",
         460 => X"a1",
         461 => X"00",
         462 => X"92",
         463 => X"00",
         464 => X"87",
         465 => X"00",
         466 => X"81",
         467 => X"00",
         468 => X"81",
         469 => X"00",
         470 => X"87",
         471 => X"00",
         472 => X"92",
         473 => X"00",
         474 => X"a1",
         475 => X"00",
         476 => X"b5",
         477 => X"00",
         478 => X"cc",
         479 => X"00",
         480 => X"e6",
         481 => X"00",
         482 => X"00",
         483 => X"00",
         484 => X"1a",
         485 => X"00",
         486 => X"34",
         487 => X"00",
         488 => X"4b",
         489 => X"00",
         490 => X"5f",
         491 => X"00",
         492 => X"6e",
         493 => X"00",
         494 => X"79",
         495 => X"00",
         496 => X"7f",
         497 => X"00",
         498 => X"7f",
         499 => X"00",
         500 => X"79",
         501 => X"00",
         502 => X"6e",
         503 => X"00",
         504 => X"5f",
         505 => X"00",
         506 => X"4b",
         507 => X"00",
         508 => X"34",
         509 => X"00",
         510 => X"1a",
         511 => X"00",
         512 => X"00",
         513 => X"00",
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
        variable r: boolean := true;
        variable ok:boolean := false;
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
                            if i = 514 then
                                assert false report "stop" severity failure;
                            end if;
                            dob <= serial(i) & serial(i);
                            i := i + 1;
                        else
                            if web(0) = '1' then
                                ser_out := to_integer(signed(dib(7 downto 0)));
                            else
                                ser_out := to_integer(signed(dib(15 downto 8)));
                            end if;
                            if not ok then
                                if ser_out = 49 then
                                    ok := true;
                                else
                                    assert false report "no ok received!" severity failure;
                                end if;
                            else
                                if r then
                                    write(buf_out, ser_out);
                                    write(buf_out, ',');
                                    write(buf_out, ' ');
                                    r := false;
                                else
                                    write(buf_out, ser_out);
                                    writeline(output, buf_out);
                                    r := true;
                                end if;
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
