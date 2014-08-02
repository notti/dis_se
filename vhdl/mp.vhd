library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.all;

use work.procedures.all;


entity mp is
    port(
        rst     : in  std_logic;
        clk     : in  std_logic;
        pdata   : in  t_data;
        pdata_rd : out std_logic;
        start   : in  std_logic;
        busy    : out std_logic;

        mem_addr : in std_logic_vector(9 downto 0);
        mem_en   : in std_logic;
        mem_data : out t_data;

        reg_addr : out t_data;
        reg_rd   : out std_logic;
        reg_data : in  t_data
    );
end mp;

architecture Structural of mp is
    signal mem_addra : std_logic_vector(9 downto 0);
    signal mem_ena   : std_logic;
    signal mem_doa   : t_data;
    signal mem_addrb : std_logic_vector(9 downto 0);
    signal mem_enb   : std_logic;
    signal mem_dob   : t_data;
    signal mem_addrd : std_logic_vector(9 downto 0);
    signal mem_wed   : std_logic;
    signal mem_did   : t_data;

    signal df_arg    : t_data_array(4 downto 0);
    signal df_cmd    : t_vliw;

    signal if_arg    : t_data_array(4 downto 0);
    signal if_val    : t_data_array(4 downto 0);
    signal if_cmd    : t_vliw;

    signal s1_arg    : t_data_array(4 downto 0);
    signal s1_val    : t_data_array(4 downto 0);
    signal s1_cmd    : t_vliw;

    signal s2_arg    : t_data_array(4 downto 0);
    signal s2_val    : t_data_array(4 downto 0);
    signal s2_cmd    : t_vliw;

    signal s3_arg    : t_data_array(4 downto 0);
    signal s3_val    : t_data_array(4 downto 0);
    signal s3_cmd    : t_vliw;
begin

    mp_mem: entity work.r3w1mem
    port map(
        clk => clk,

        addra => mem_addra,
        ena => mem_ena,
        doa => mem_doa,
        addrb => mem_addrb,
        enb => mem_enb,
        dob => mem_dob,
        addrc => mem_addr,
        enc => mem_en,
        doc => mem_data,
        addrd => mem_addrd,
        wed => mem_wed,
        did => mem_did
    );

    s0: entity work.mp_decode_fetch
    port map(
        rst => rst,
        clk => clk,
        pdata => pdata,
        pdata_rd => pdata_rd,
        start => start,
        busy => busy,

        mem_addr => mem_addra,
        mem_rd => mem_ena,
        mem_data => mem_doa,
        reg_addr => reg_addr,
        reg_rd => reg_rd,
        reg_data => reg_data,

        arg_out => df_arg,
        cmd_out => df_cmd
    );

    s1: entity work.mp_indirect_fetch
    port map(
        rst => rst,
        clk => clk,

        cmd_in => df_cmd,
        arg_in => df_arg,

        mem_addr => mem_addrb,
        mem_rd => mem_enb,
        mem_data => mem_dob,

        arg_out => if_arg,
        val_out => if_val,
        cmd_out => if_cmd
    );

    s2: entity work.mp_stage1
    port map(
        rst => rst,
        clk => clk,

        cmd_in => if_cmd,
        arg_in => if_arg,
        val_in => if_val,

        arg_out => s1_arg,
        val_out => s1_val,
        cmd_out => s1_cmd
    );

    s3: entity work.mp_stage2
    port map(
        rst => rst,
        clk => clk,

        cmd_in => s1_cmd,
        arg_in => s1_arg,
        val_in => s1_val,

        arg_out => s2_arg,
        val_out => s2_val,
        cmd_out => s2_cmd
    );

    s4: entity work.mp_stage3
    port map(
        rst => rst,
        clk => clk,

        cmd_in => s2_cmd,
        arg_in => s2_arg,
        val_in => s2_val,

        arg_out => s3_arg,
        val_out => s3_val,
        cmd_out => s3_cmd
    );

    s5: entity work.mp_writeback -- fifo?
    port map(
        rst => rst,
        clk => clk,

        cmd_in => s3_cmd,
        arg_in => s3_arg,
        val_in => s3_val,

        mem_wr => mem_wed,
        mem_data => mem_did,
        mem_addr => mem_addrd
    );

end Structural;
