library IEEE;
        use IEEE.STD_LOGIC_1164.ALL;
        use IEEE.NUMERIC_STD.ALL;
library std;
        use std.textio.all;

library work;
        use work.all;
        use work.procedures.all;

entity tb_shift is
end tb_shift;


architecture behav of tb_shift is
    signal a : t_data := (others => '0');
    signal b : t_data := (others => '0');
    signal logic : t_data := (others => '0');
    signal arith : t_data := (others => '0');

begin
    
    process
        variable l : line;
    begin
        wait for 20 ns;
        a <= X"00";
        for i in 0 to 10 loop
            b <= std_logic_vector(to_unsigned(i, t_data'length));
            wait for 20 ns;
        end loop;

        a <= X"AA";
        for i in 0 to 10 loop
            b <= std_logic_vector(to_unsigned(i, t_data'length));
            wait for 20 ns;
        end loop;

        a <= X"55";
        for i in 0 to 10 loop
            b <= std_logic_vector(to_unsigned(i, t_data'length));
            wait for 20 ns;
        end loop;

        a <= X"FF";
        for i in 0 to 10 loop
            b <= std_logic_vector(to_unsigned(i, t_data'length));
            wait for 20 ns;
        end loop;

        a <= X"7F";
        for i in 0 to 10 loop
            b <= std_logic_vector(to_unsigned(i, t_data'length));
            wait for 20 ns;
        end loop;
        assert false report "stop" severity failure;
    end process;
    
    ashift: entity work.shift_ra
    port map(
        a => a,
        b => b,
        c => arith
    );

    lshift: entity work.shift_rl
    port map(
        a => a,
        b => b,
        c => logic 
    );

end behav;
