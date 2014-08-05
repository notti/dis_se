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
        clk2x   : in  std_logic;
        pdata   : in  t_data2;
        pdata_rd : out std_logic;
        start   : in  std_logic;
        busy    : out std_logic;

        mem_addra : in std_logic_vector(9 downto 0);
        mem_ena   : in std_logic;
        mem_doa : out t_data;
        mem_addrb : in std_logic_vector(9 downto 0);
        mem_enb   : in std_logic;
        mem_dob : out t_data;

        reg_addra : out t_data;
        reg_ena   : out std_logic;
        reg_doa   : in  t_data;
        reg_addrb : out t_data;
        reg_enb   : out std_logic;
        reg_dob   : in  t_data
    );
end mp;

architecture Structural of mp is
    signal mem_addrc : std_logic_vector(9 downto 0);
    signal mem_enc   : std_logic;
    signal mem_doc   : t_data;
    signal mem_addrd : std_logic_vector(9 downto 0);
    signal mem_end   : std_logic;
    signal mem_dod   : t_data;
    signal mem_addre : std_logic_vector(9 downto 0);
    signal mem_ene   : std_logic;
    signal mem_doe   : t_data;
    signal mem_addrf : std_logic_vector(9 downto 0);
    signal mem_enf   : std_logic;
    signal mem_dof   : t_data;
    signal mem_addrg : std_logic_vector(9 downto 0);
    signal mem_weg   : std_logic;
    signal mem_dig   : t_data;
    signal mem_addrh : std_logic_vector(9 downto 0);
    signal mem_weh   : std_logic;
    signal mem_dih   : t_data;

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

    mp_mem: entity work.r6w2mem1k8
    port map(
        clk => clk,
        clk2x => clk2x,
        addra => mem_addra,
        ena => mem_ena,
        doa => mem_doa,
        addrb => mem_addrb,
        enb => mem_enb,
        dob => mem_dob,
        addrc => mem_addrc,
        enc => mem_enc,
        doc => mem_doc,
        addrd => mem_addrd,
        en_d => mem_end,
        dod => mem_dod,
        addre => mem_addre,
        ene => mem_ene,
        doe => mem_doe,
        addrf => mem_addrf,
        enf => mem_enf,
        dof => mem_dof,
        dig => mem_dig,
        addrg => mem_addrg,
        weg => mem_weg,
        dih => mem_dih,
        addrh => mem_addrh,
        weh => mem_weh
    );

    s0: entity work.mp_decode_fetch
    port map(
        rst => rst,
        clk => clk,
        pdata => pdata,
        pdata_rd => pdata_rd,
        start => start,
        busy => busy,

        mem_addra => mem_addrc,
        mem_ena => mem_enc,
        mem_doa => mem_doc,
        mem_addrb => mem_addrd,
        mem_enb => mem_end,
        mem_dob => mem_dod,
        reg_addra => reg_addra,
        reg_ena => reg_ena,
        reg_doa => reg_doa,
        reg_addrb => reg_addrb,
        reg_enb => reg_enb,
        reg_dob => reg_dob,

        arg_out => df_arg,
        cmd_out => df_cmd
    );

    s1: entity work.mp_indirect_fetch
    port map(
        rst => rst,
        clk => clk,

        cmd_in => df_cmd,
        arg_in => df_arg,

        mem_addr => mem_addre,
        mem_rd => mem_ene,
        mem_data => mem_doe,

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

    s5: entity work.mp_writeback
    port map(
        rst => rst,
        clk => clk,

        cmd_in => s3_cmd,
        arg_in => s3_arg,
        val_in => s3_val,

        mem_wr => mem_weg,
        mem_data => mem_dig,
        mem_addr => mem_addrg
    );

end Structural;
