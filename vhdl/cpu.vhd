library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.all;

use work.procedures.all;


entity cpu is
    port(
        rst     : in  std_logic;
        clk     : in  std_logic;
        clk2x   : in  std_logic;

        ena     : out std_logic;
        addra   : out t_data2;
        doa     : in  t_data2;
        enb     : out std_logic;
        addrb   : out t_data2;
        dob     : in t_data2;
        web     : out std_logic_vector(1 downto 0);
        dib     : out t_data2;
        bbusy   : in std_logic
    );
end cpu;

architecture Structural of cpu is
    signal PC : unsigned(t_data2'range);
    signal PC_1 : unsigned(t_data2'range);
    type t_cmd is (CMD_NOOP, CMD_ADD, CMD_ADDC, CMD_SUB, CMD_SUBB, CMD_AND, CMD_OR,
        CMD_XOR, CMD_SHL, CMD_SHR, CMD_SAR, CMD_MOV, CMD_MOVM, CMD_CMP, CMD_JMP);
    type t_cmp is (CMP_NONE, CMP_Z, CMP_NZ, CMP_LE, CMP_LT, CMP_GE, CMP_GT, CMP_ULE, CMP_ULT,
        CMP_UGE, CMP_UGT);
    type t_ctrl is
        record
            cmd  : t_cmd;
            l    : std_logic;
            h    : std_logic;
            mov  : std_logic_vector(1 downto 0);
            cmp  : t_cmp;
            A    : std_logic_vector(3 downto 0);
            A_d  : t_data2;
            B    : std_logic_vector(3 downto 0);
            B_d  : t_data2;
            arg  : t_data2;
            C    : std_logic_vector(3 downto 0);
        end record;
    constant ctrl_noop : t_ctrl := (
        cmd => CMD_NOOP,
        l => '0',
        h => '0',
        mov => (others => '0'),
        cmp => CMP_NONE,
        A => (others => '0'),
        A_d => (others => '0'),
        B => (others => '0'),
        B_d => (others => '0'),
        arg => (others => '0'),
        C => (others => '0'));
    signal decoded_cmd : t_ctrl;
    attribute INIT : t_ctrl;
    attribute INIT of decoded_cmd : signal is ctrl_noop;
    signal reg : t_data2_array(15 downto 0);
    signal reg_A_d : t_data2;
    signal reg_B_d : t_data2;
    signal reg_C_d : t_data2;
    signal reg_C : std_logic_vector(3 downto 0);
    signal wb_C : std_logic_vector(1 downto 0);
    type wb_which_t is (WB_REG, WB_MEM, WB_MPMEM);
    signal wb_which : wb_which_t;
    signal A_d : unsigned(15 downto 0);
    signal B_d : unsigned(15 downto 0);
    signal C_flag : std_logic;
    signal V_flag : std_logic;
    signal Z_flag : std_logic;
    signal S_flag : std_logic;
    signal do_jmp : std_logic;
    type t_fetch is (FETCH_CMD, FETCH_A, FETCH_B, FETCH_BOTH, FETCH_ARG);
    signal fetch_state : t_fetch;
    signal C_result : std_logic_vector(t_data2'range);
    signal di1 : std_logic_vector(7 downto 0);
    signal di0 : std_logic_vector(7 downto 0);
    signal pdata_rd : std_logic;
    signal mp_busy : std_logic;
    signal mp_start : std_logic;
    signal reg_doaw : t_data2;
    signal reg_dobw : t_data2;
    signal reg_doa  : t_data;
    signal reg_dob  : t_data;
    signal reg_ena  : std_logic;
    signal reg_enb  : std_logic;
    signal reg_addra : t_data;
    signal reg_addrb : t_data;
    signal reg_hla  : std_logic;
    signal reg_hlb  : std_logic;
    signal mpmem_addra : std_logic_vector(9 downto 0);
    signal mpmem_ena : std_logic;
    signal mpmem_doa : t_data;
    signal mpmem_addrb : std_logic_vector(9 downto 0);
    signal mpmem_enb : std_logic;
    signal mpmem_dob : t_data;
    signal rst_1 : std_logic;
    signal bbusy_1 : std_logic;
begin

process(clk)
begin
    if rising_edge(clk) then
        rst_1 <= rst;
        bbusy_1 <= bbusy;
    end if;
end process;

mem_fetch: process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            PC <= (others => '0');
            PC_1 <= (others => '0');
        elsif bbusy = '0' then
            if do_jmp = '1' then
                PC <= B_d + 1;
            elsif fetch_state /= FETCH_CMD or doa(15 downto 4) /= "000000001100" or mp_busy = '0' then
                PC <= PC + 1;
                PC_1 <= PC;
            end if;
        elsif bbusy = '1' then
            PC <= PC_1;
        end if;
    end if;
end process mem_fetch;

ena <= '1';

addra <= std_logic_vector(PC) when do_jmp = '0' else
         std_logic_vector(B_d);


-- "simple" xilinx style ram with byte wide write enable...
register_file_di: process(wb_C, reg_C_d)
begin
    if wb_C(1) = '1' then
        di1 <= reg_C_d(15 downto 8);
    else
        di1 <= reg(to_integer(unsigned(reg_C)))(15 downto 8);
    end if;
    if wb_C(0) = '1' then
        di0 <= reg_C_d(7 downto 0);
    else
        di0 <= reg(to_integer(unsigned(reg_C)))(7 downto 0);
    end if;
end process register_file_di;

register_file: process(clk)
begin
    if rising_edge(clk) then
        if wb_C(1) = '1' or wb_C(0) = '1' then
            reg(to_integer(unsigned(reg_C))) <= di1 & di0;
        end if;
        if fetch_state = FETCH_CMD then
            reg_A_d <= reg(to_integer(unsigned(doa(7 downto 4))));
            reg_B_d <= reg(to_integer(unsigned(doa(3 downto 0))));
        end if;
        if reg_ena = '1' then
            reg_doaw <= reg(to_integer(unsigned(reg_addra(3 downto 0))));
            reg_hla <= reg_addra(4);
        end if;
        if reg_enb = '1' then
            reg_dobw <= reg(to_integer(unsigned(reg_addrb(3 downto 0))));
            reg_hlb <= reg_addrb(4);
        end if;
    end if;
end process register_file;

reg_doa <= reg_doaw(15 downto 8) when reg_hla = '1' else
           reg_doaw(7 downto 0);
reg_dob <= reg_dobw(15 downto 8) when reg_hlb = '1' else
           reg_dobw(7 downto 0);


decode_fetch: process(clk)
    variable hold_cmd : t_ctrl;
begin
    if rising_edge(clk) then
        if rst = '1' or rst_1 = '1' or do_jmp = '1' or pdata_rd = '1' or (bbusy = '0' and bbusy_1 = '1') then
            decoded_cmd <= ctrl_noop;
            hold_cmd := ctrl_noop;
            fetch_state <= FETCH_CMD;
        elsif bbusy = '0' then
            case fetch_state is
                when FETCH_CMD =>
                    hold_cmd := ctrl_noop;
                    hold_cmd.A := doa(7 downto 4);
                    hold_cmd.B := doa(3 downto 0);
                    hold_cmd.C := doa(11 downto 8);
                    hold_cmd.l := doa(8); hold_cmd.h := doa(9);
                    hold_cmd.mov := doa(11 downto 10);
                    case doa(15 downto 12) is
                        when "0001" => hold_cmd.cmd := CMD_ADD;
                        when "0010" => hold_cmd.cmd := CMD_ADDC;
                        when "0011" => hold_cmd.cmd := CMD_SUB;
                        when "0100" => hold_cmd.cmd := CMD_SUBB;
                        when "0101" => hold_cmd.cmd := CMD_AND;
                        when "0110" => hold_cmd.cmd := CMD_OR;
                        when "0111" => hold_cmd.cmd := CMD_XOR;
                        when "1000" => hold_cmd.cmd := CMD_SHL;
                        when "1001" => hold_cmd.cmd := CMD_SHR;
                        when "1010" => hold_cmd.cmd := CMD_SAR;
                        when "1100" => 
                            if doa(11 downto 10) = "00" then
                                hold_cmd.cmd := CMD_MOV;
                            else
                                hold_cmd.cmd := CMD_MOVM;
                            end if;
                        when others =>
                    end case;
                    if doa(15 downto 8) = "00000001" then
                        hold_cmd.cmd := CMD_CMP;
                    end if;
                    if doa(15 downto 8) = "00000000" then
                        case doa(7 downto 4) is
                            when "0001" => hold_cmd.cmd := CMD_JMP;
                            when "0010" => hold_cmd.cmd := CMD_JMP; hold_cmd.cmp := CMP_Z;
                            when "0011" => hold_cmd.cmd := CMD_JMP; hold_cmd.cmp := CMP_NZ;
                            when "0100" => hold_cmd.cmd := CMD_JMP; hold_cmd.cmp := CMP_LE;
                            when "0101" => hold_cmd.cmd := CMD_JMP; hold_cmd.cmp := CMP_LT;
                            when "0110" => hold_cmd.cmd := CMD_JMP; hold_cmd.cmp := CMP_GE;
                            when "0111" => hold_cmd.cmd := CMD_JMP; hold_cmd.cmp := CMP_GT;
                            when "1000" => hold_cmd.cmd := CMD_JMP; hold_cmd.cmp := CMP_ULE;
                            when "1001" => hold_cmd.cmd := CMD_JMP; hold_cmd.cmp := CMP_ULT;
                            when "1010" => hold_cmd.cmd := CMD_JMP; hold_cmd.cmp := CMP_UGE;
                            when "1011" => hold_cmd.cmd := CMD_JMP; hold_cmd.cmp := CMP_UGT;
                            when others =>
                        end case;
                    end if;
                    decoded_cmd <= ctrl_noop;
                    if doa(7 downto 0) = "11111111" and hold_cmd.cmd /= CMD_MOV and hold_cmd.cmd /= CMD_MOV then
                        fetch_state <= FETCH_BOTH;
                    elsif doa(7 downto 4) = "1111" and hold_cmd.cmd /= CMD_MOV and hold_cmd.cmd /= CMD_MOV then
                        fetch_state <= FETCH_A;
                    elsif doa(3 downto 0) = "1111" then
                        fetch_state <= FETCH_B;
                    elsif hold_cmd.cmd = CMD_MOVM then
                        fetch_state <= FETCH_ARG;
                    else
                        decoded_cmd <= hold_cmd;
                    end if;
                when FETCH_BOTH =>
                    hold_cmd.A_d := doa;
                    fetch_state <= FETCH_B;
                when FETCH_A =>
                    hold_cmd.A_d := doa;
                    decoded_cmd <= hold_cmd;
                    fetch_state <= FETCH_CMD;
                when FETCH_B =>
                    if hold_cmd.cmd = CMD_MOVM then
                        hold_cmd.B_d := doa;
                        fetch_state <= FETCH_ARG;
                    else
                        hold_cmd.B_d := doa;
                        decoded_cmd <= hold_cmd;
                        fetch_state <= FETCH_CMD;
                    end if;
                when FETCH_ARG =>
                    hold_cmd.arg := doa;
                    decoded_cmd <= hold_cmd;
                    fetch_state <= FETCH_CMD;
            end case;
        end if;
    end if;
end process decode_fetch;

mp_start <= '1' when fetch_state = FETCH_CMD and doa(15 downto 4) = "000000001100" and mp_busy = '0' and do_jmp = '0' else
            '0';

mpmem_addra <= decoded_cmd.arg(1 downto 0) & std_logic_vector(B_d(7 downto 1)) & "0";
mpmem_addrb <= decoded_cmd.arg(1 downto 0) & std_logic_vector(B_d(7 downto 1)) & "1";
mpmem_ena <= decoded_cmd.l when decoded_cmd.mov = "11" and decoded_cmd.cmd = CMD_MOVM else
             '0';
mpmem_enb <= decoded_cmd.h when decoded_cmd.mov = "11" and decoded_cmd.cmd = CMD_MOVM else
             '0';

mp_i: entity work.mp
port map
(
        rst => rst,
        clk => clk,
        clk2x => clk2x,
        pdata => doa,
        pdata_rd => pdata_rd,
        start => mp_start,
        busy => mp_busy,

        mem_addra => mpmem_addra,
        mem_ena => mpmem_ena,
        mem_doa => mpmem_doa,
        mem_addrb => mpmem_addrb,
        mem_enb => mpmem_enb,
        mem_dob => mpmem_dob,

        reg_addra => reg_addra,
        reg_ena => reg_ena,
        reg_doa => reg_doa,
        reg_addrb => reg_addrb,
        reg_enb => reg_enb,
        reg_dob => reg_dob
);

A_d <= unsigned(decoded_cmd.A_d) when decoded_cmd.A = "1111" else
       (0 => '1', others => '0') when decoded_cmd.A = "1110" and (decoded_cmd.cmd = CMD_SHL or decoded_cmd.cmd = CMD_SHR or decoded_cmd.cmd = CMD_SAR) else
       (others => '0') when decoded_cmd.A = "1110" else
       unsigned(reg_C_d) when decoded_cmd.A = reg_C else
       unsigned(reg_A_d);
B_d <= unsigned(decoded_cmd.B_d) when decoded_cmd.B = "1111" else
       (0 => '1', others => '0') when decoded_cmd.B = "1110" and (decoded_cmd.cmd = CMD_SHL or decoded_cmd.cmd = CMD_SHR or decoded_cmd.cmd = CMD_SAR) else
       (others => '0') when decoded_cmd.B = "1110" else
       unsigned(reg_C_d) when decoded_cmd.A = reg_C else
       unsigned(reg_B_d);

execute: process(clk)
    variable C_d : unsigned(16 downto 0);
begin
    if rising_edge(clk) then
        wb_which <= WB_REG;
        wb_C <= "00";
        reg_C <= decoded_cmd.C;
        C_d := (others => '0');
        if do_jmp = '0' then
            case decoded_cmd.cmd is
                when CMD_ADD | CMD_ADDC | CMD_SUB | CMD_CMP | CMD_SUBB =>
                    if decoded_cmd.cmd /= CMD_CMP then
                        wb_C <= "11";
                    end if;
                    if decoded_cmd.cmd = CMD_ADD then
                        C_d := to_unsigned(to_integer(A_d) + to_integer(B_d), 17);
                    elsif decoded_cmd.cmd = CMD_ADDC then
                        C_d := to_unsigned(to_integer(A_d) + to_integer(B_d) + to_integer(unsigned'("" & C_flag)), 17);
                    elsif decoded_cmd.cmd = CMD_SUB or decoded_cmd.cmd = CMD_CMP then
                        C_d := to_unsigned(to_integer(A_d) - to_integer(B_d), 17);
                    else
                        C_d := to_unsigned(to_integer(A_d) - to_integer(B_d) - to_integer(unsigned'("" & C_flag)), 17);
                    end if;
                when CMD_AND  => C_d := "0" & (A_d and B_d);       wb_C <= "11";
                when CMD_OR   => C_d := "0" & (A_d or B_d);        wb_C <= "11";
                when CMD_XOR  => C_d := "0" & (A_d xor B_d);       wb_C <= "11";
                when CMD_SHL  => 
                    if B_d(15 downto 4) /= "000000000000" then
                        C_d := (others => '0');
                    else
                        C_d := "0" & shift_left(A_d, to_integer(B_d(3 downto 0)));
                    end if;
                    wb_C <= "11";
                when CMD_SHR  =>
                    if B_d(15 downto 4) /= "000000000000" then
                        C_d := (others => '0');
                    else
                        C_d := "0" & shift_right(A_d, to_integer(B_d(3 downto 0)));
                    end if;
                    wb_C <= "11";
                when CMD_SAR  =>
                    if B_d(15 downto 4) /= "000000000000" then
                        C_d := (others => '0');
                    else
                        C_d := "0" & unsigned(std_logic_vector(shift_right(signed(std_logic_vector(A_d)), to_integer(B_d(3 downto 0)))));
                    end if;
                    wb_C <= "11";
                when CMD_MOV  =>
                    C_d := "0" & B_d;
                    reg_C <= decoded_cmd.A;
                    wb_C <= "11";
                when CMD_MOVM => 
                    reg_C <= decoded_cmd.A;
                    if decoded_cmd.mov(1) = '1' then
                        wb_C <= decoded_cmd.h & decoded_cmd.l;
                        if decoded_cmd.mov(0) = '0' then
                            wb_which <= WB_MEM;
                        else
                            wb_which <= WB_MPMEM;
                        end if;
                    end if;
                when others =>
            end case;
            case decoded_cmd.cmd is
                when CMD_ADD | CMD_ADDC | CMD_SUB | CMD_SUBB | CMD_CMP =>
                    S_flag <= C_d(15);
                    C_flag <= C_d(16);
                    if C_d(15 downto 0) = "0000000000000000" then
                        Z_flag <= '1';
                    else
                        Z_flag <= '0';
                    end if;
                    V_flag <= C_d(15) xor C_d(16) xor A_d(15) xor B_d(15);
                when CMD_AND | CMD_OR | CMD_XOR | CMD_SHL | CMD_SHR | CMD_SAR =>
                    if C_d(15 downto 0) = "0000000000000000" then
                        Z_flag <= '1';
                    else
                        Z_flag <= '0';
                    end if;
                when others =>
            end case;
        end if;
        C_result <= std_logic_vector(C_d(15 downto 0));
    end if;
end process execute;

do_jmp <= '0' when decoded_cmd.cmd /= CMD_JMP else
          '1' when decoded_cmd.cmp = CMP_NONE or
                   (decoded_cmd.cmp = CMP_Z and Z_flag = '1') or
                   (decoded_cmd.cmp = CMP_NZ and Z_flag = '0') or
                   (decoded_cmd.cmp = CMP_LE and (Z_flag = '1' or S_flag /= V_flag)) or
                   (decoded_cmd.cmp = CMP_LT and S_flag /= V_flag) or
                   (decoded_cmd.cmp = CMP_GE and S_flag = V_flag) or
                   (decoded_cmd.cmp = CMP_GT and (Z_flag = '0' and S_flag = V_flag)) or
                   (decoded_cmd.cmp = CMP_ULE and (C_flag = '1' or Z_flag = '1')) or
                   (decoded_cmd.cmp = CMP_ULT and C_flag = '1') or
                   (decoded_cmd.cmp = CMP_UGE and C_flag = '0') or
                   (decoded_cmd.cmp = CMP_UGT and (C_flag = '0' and Z_flag = '0')) else
          '0';

web(0) <= decoded_cmd.l when decoded_cmd.mov = "01" and decoded_cmd.cmd = CMD_MOVM else
          '0';
web(1) <= decoded_cmd.h when decoded_cmd.mov = "01" and decoded_cmd.cmd = CMD_MOVM else
          '0';
enb <= '1' when (decoded_cmd.mov = "01" or decoded_cmd.mov = "10") and decoded_cmd.cmd = CMD_MOVM else
       '0';
addrb <= std_logic_vector(unsigned(decoded_cmd.arg) + A_d) when decoded_cmd.mov = "01" else -- write
         std_logic_vector(unsigned(decoded_cmd.arg) + B_d); --read
dib <= std_logic_vector(B_d);

reg_C_d <= dob when wb_which = WB_MEM else
           mpmem_dob & mpmem_doa when wb_which = WB_MPMEM else
           C_result;

end Structural;
