library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

package procedures is

    subtype t_data is std_logic_vector(7 downto 0);
    subtype t_data2 is std_logic_vector(15 downto 0);
        
    type t_data_array is array(natural range <>) of t_data;
    type t_data2_array is array(natural range <>) of t_data;
    type t_2array is array(natural range <>) of std_logic_vector(1 downto 0);
    type t_3array is array(natural range <>) of std_logic_vector(2 downto 0);

    constant ARG_NONE : std_logic_vector(1 downto 0) := "00";
    constant ARG_REG  : std_logic_vector(1 downto 0) := "01";
    constant ARG_MEM  : std_logic_vector(1 downto 0) := "10";
    constant ARG_IMM  : std_logic_vector(1 downto 0) := "11";

    constant CALU_NOOP : std_logic_vector(2 downto 0) := "000";
    constant CALU_ADD  : std_logic_vector(2 downto 0) := "001";
    constant CALU_SUB  : std_logic_vector(2 downto 0) := "010";
    constant CALU_UMUL : std_logic_vector(2 downto 0) := "011";
    constant CALU_SMUL : std_logic_vector(2 downto 0) := "100";
    constant CALU_AND  : std_logic_vector(2 downto 0) := "101";
    constant CALU_OR   : std_logic_vector(2 downto 0) := "110";
    constant CALU_XOR  : std_logic_vector(2 downto 0) := "111";

    constant SALU_NOOP : std_logic_vector(2 downto 0) := "000";
    constant SALU_ADD  : std_logic_vector(2 downto 0) := "001";
    constant SALU_SUB  : std_logic_vector(2 downto 0) := "010";
    constant SALU_SAR  : std_logic_vector(2 downto 0) := "011";
    constant SALU_SLR  : std_logic_vector(2 downto 0) := "100";
    constant SALU_AND  : std_logic_vector(2 downto 0) := "101";
    constant SALU_OR   : std_logic_vector(2 downto 0) := "110";
    constant SALU_XOR  : std_logic_vector(2 downto 0) := "111";

    constant ALUIN_0   : std_logic_vector(2 downto 0) := "101";
    constant ALUIN_1   : std_logic_vector(2 downto 0) := "110";
    constant ALUIN_2   : std_logic_vector(2 downto 0) := "111";

    type t_vliw is
        record
            -- fetch_decode
            arg_type     : t_2array(4 downto 0);
            arg_memchunk : t_2array(4 downto 0);
            
            -- indirect_fetch
            arg_val      : std_logic_vector(4 downto 0);
            arg_assign   : t_3array(4 downto 0);
            mem_fetch    : std_logic_vector(4 downto 0);
            mem_memchunk : t_2array(4 downto 0);

            -- stage 1
            s1_in1a      : std_logic_vector(2 downto 0);
            s1_in1b      : std_logic_vector(2 downto 0);
            s1_op1       : std_logic_vector(2 downto 0);
            s1_point1    : std_logic_vector(2 downto 0);
            s1_out1      : std_logic_vector(2 downto 0);
            s1_in2a      : std_logic_vector(2 downto 0);
            s1_in2b      : std_logic_vector(2 downto 0);
            s1_op2       : std_logic_vector(2 downto 0);
            s1_point2    : std_logic_vector(2 downto 0);
            s1_out2      : std_logic_vector(2 downto 0);

            -- stage 2
            s2_in1a      : std_logic_vector(2 downto 0);
            s2_in1b      : std_logic_vector(2 downto 0);
            s2_op1       : std_logic_vector(2 downto 0);
            s2_out1      : std_logic_vector(2 downto 0);
            s2_in2a      : std_logic_vector(2 downto 0);
            s2_in2b      : std_logic_vector(2 downto 0);
            s2_op2       : std_logic_vector(2 downto 0);
            s2_out2      : std_logic_vector(2 downto 0);

            -- stage 3
            s3_in1a      : std_logic_vector(2 downto 0);
            s3_in1b      : std_logic_vector(2 downto 0);
            s3_op1       : std_logic_vector(2 downto 0);
            s3_out1      : std_logic_vector(2 downto 0);
            s3_in2a      : std_logic_vector(2 downto 0);
            s3_in2b      : std_logic_vector(2 downto 0);
            s3_op2       : std_logic_vector(2 downto 0);
            s3_out2      : std_logic_vector(2 downto 0);

            -- writeback
            wb           : std_logic_vector(4 downto 0);
            wb_memchunk  : t_2array(4 downto 0);
            wb_bitrev    : t_3array(4 downto 0);
            wb_assign    : t_3array(4 downto 0); -- do we need that?

            -- ctrl
            noop         : std_logic;
        end record;
    constant empty_vliw : t_vliw := (
        arg_type => (others => (others => '0')),
        arg_memchunk => (others => (others => '0')),
        arg_assign => (others => (others => '0')),
        arg_val => (others => '0'),
        mem_fetch => (others => '0'),
        mem_memchunk => (others => (others => '0')),
        s1_in1a => (others => '0'),
        s1_in1b => (others => '0'),
        s1_op1 => (others => '0'),
        s1_point1 => (others => '0'),
        s1_out1 => (others => '0'),
        s1_in2a => (others => '0'),
        s1_in2b => (others => '0'),
        s1_op2 => (others => '0'),
        s1_point2 => (others => '0'),
        s1_out2 => (others => '0'),
        s2_in1a => (others => '0'),
        s2_in1b => (others => '0'),
        s2_op1 => (others => '0'),
        s2_out1 => (others => '0'),
        s2_in2a => (others => '0'),
        s2_in2b => (others => '0'),
        s2_op2 => (others => '0'),
        s2_out2 => (others => '0'),
        s3_in1a => (others => '0'),
        s3_in1b => (others => '0'),
        s3_op1 => (others => '0'),
        s3_out1 => (others => '0'),
        s3_in2a => (others => '0'),
        s3_in2b => (others => '0'),
        s3_op2 => (others => '0'),
        s3_out2 => (others => '0'),
        wb => (others => '0'),
        wb_assign => (others => (others => '0')),
        wb_bitrev => (others => (others => '0')),
        wb_memchunk => (others => (others => '0')),
        noop => '1'
    );
    constant VLIW_HIGH : natural := 177;

    function index2val(signal val: in t_data_array(4 downto 0);
                       signal index: in std_logic_vector(2 downto 0)) return t_data;
    function slv2vliw(slv: in std_logic_vector(VLIW_HIGH downto 0)) return t_vliw;
    function vliw2slv(vliw: in t_vliw) return std_logic_vector;
    function bitrev(a: in t_data; b: in std_logic_vector(2 downto 0)) return t_data;

end package;

package body procedures is

    function index2val(signal val: in t_data_array(4 downto 0);
                       signal index: in std_logic_vector(2 downto 0)) return t_data is
        variable res : t_data;
    begin
        case to_integer(unsigned(index)) is
            when 0 to 4 => res := val(to_integer(unsigned(index)));
            when 6 => res := (0 => '1', others => '0');
            when 7 => res := (1 => '1', others => '0');
            when others => res := (others => '0');
        end case;
        return res;
    end function;

    function slv2vliw(slv: in std_logic_vector(VLIW_HIGH downto 0)) return t_vliw is
        variable ret : t_vliw;
    begin
        ret.arg_type(0)     := slv(1 downto 0);
        ret.arg_type(1)     := slv(3 downto 2);
        ret.arg_type(2)     := slv(5 downto 4);
        ret.arg_type(3)     := slv(7 downto 6);
        ret.arg_type(4)     := slv(9 downto 8);
        ret.arg_memchunk(0) := slv(11 downto 10);
        ret.arg_memchunk(1) := slv(13 downto 12);
        ret.arg_memchunk(2) := slv(15 downto 14);
        ret.arg_memchunk(3) := slv(17 downto 16);
        ret.arg_memchunk(4) := slv(19 downto 18);
        ret.arg_val         := slv(24 downto 20);
        ret.arg_assign(0)   := slv(27 downto 25);
        ret.arg_assign(1)   := slv(30 downto 28);
        ret.arg_assign(2)   := slv(33 downto 31);
        ret.arg_assign(3)   := slv(36 downto 34);
        ret.arg_assign(4)   := slv(39 downto 37);
        ret.mem_fetch       := slv(44 downto 40);
        ret.mem_memchunk(0) := slv(46 downto 45);
        ret.mem_memchunk(1) := slv(48 downto 47);
        ret.mem_memchunk(2) := slv(50 downto 49);
        ret.mem_memchunk(3) := slv(52 downto 51);
        ret.mem_memchunk(4) := slv(54 downto 53);
        ret.s1_in1a         := slv(57 downto 55);
        ret.s1_in1b         := slv(60 downto 58);
        ret.s1_op1          := slv(63 downto 61);
        ret.s1_point1       := slv(66 downto 64);
        ret.s1_out1         := slv(69 downto 67);
        ret.s1_in2a         := slv(72 downto 70);
        ret.s1_in2b         := slv(75 downto 73);
        ret.s1_op2          := slv(78 downto 76);
        ret.s1_point2       := slv(81 downto 79);
        ret.s1_out2         := slv(84 downto 82);
        ret.s2_in1a         := slv(87 downto 85);
        ret.s2_in1b         := slv(90 downto 88);
        ret.s2_op1          := slv(93 downto 91);
        ret.s2_out1         := slv(96 downto 94);
        ret.s2_in2a         := slv(99 downto 97);
        ret.s2_in2b         := slv(102 downto 100);
        ret.s2_op2          := slv(105 downto 103);
        ret.s2_out2         := slv(108 downto 106);
        ret.s3_in1a         := slv(111 downto 109);
        ret.s3_in1b         := slv(114 downto 112);
        ret.s3_op1          := slv(117 downto 115);
        ret.s3_out1         := slv(120 downto 118);
        ret.s3_in2a         := slv(123 downto 121);
        ret.s3_in2b         := slv(126 downto 124);
        ret.s3_op2          := slv(129 downto 127);
        ret.s3_out2         := slv(132 downto 130);
        ret.wb              := slv(137 downto 133);
        ret.wb_memchunk(0)  := slv(139 downto 138);
        ret.wb_memchunk(1)  := slv(141 downto 140);
        ret.wb_memchunk(2)  := slv(143 downto 142);
        ret.wb_memchunk(3)  := slv(145 downto 144);
        ret.wb_memchunk(4)  := slv(147 downto 146);
        ret.wb_bitrev(0)    := slv(150 downto 148);
        ret.wb_bitrev(1)    := slv(153 downto 151);
        ret.wb_bitrev(2)    := slv(156 downto 154);
        ret.wb_bitrev(3)    := slv(159 downto 157);
        ret.wb_bitrev(4)    := slv(162 downto 160);
        ret.wb_assign(0)    := slv(165 downto 163);
        ret.wb_assign(1)    := slv(168 downto 166);
        ret.wb_assign(2)    := slv(171 downto 169);
        ret.wb_assign(3)    := slv(174 downto 172);
        ret.wb_assign(4)    := slv(177 downto 175);
        ret.noop            := '0';
        return ret;
    end function;

    function vliw2slv(vliw: in t_vliw) return std_logic_vector is
        variable ret : std_logic_vector(VLIW_HIGH downto 0);
    begin
        ret(1 downto 0) := vliw.arg_type(0);
        ret(3 downto 2) := vliw.arg_type(1);
        ret(5 downto 4) := vliw.arg_type(2);
        ret(7 downto 6) := vliw.arg_type(3);
        ret(9 downto 8) := vliw.arg_type(4);
        ret(11 downto 10) := vliw.arg_memchunk(0);
        ret(13 downto 12) := vliw.arg_memchunk(1);
        ret(15 downto 14) := vliw.arg_memchunk(2);
        ret(17 downto 16) := vliw.arg_memchunk(3);
        ret(19 downto 18) := vliw.arg_memchunk(4);
        ret(24 downto 20) := vliw.arg_val;
        ret(27 downto 25) := vliw.arg_assign(0);
        ret(30 downto 28) := vliw.arg_assign(1);
        ret(33 downto 31) := vliw.arg_assign(2);
        ret(36 downto 34) := vliw.arg_assign(3);
        ret(39 downto 37) := vliw.arg_assign(4);
        ret(44 downto 40) := vliw.mem_fetch;
        ret(46 downto 45) := vliw.mem_memchunk(0);
        ret(48 downto 47) := vliw.mem_memchunk(1);
        ret(50 downto 49) := vliw.mem_memchunk(2);
        ret(52 downto 51) := vliw.mem_memchunk(3);
        ret(54 downto 53) := vliw.mem_memchunk(4);
        ret(57 downto 55) := vliw.s1_in1a;
        ret(60 downto 58) := vliw.s1_in1b;
        ret(63 downto 61) := vliw.s1_op1;
        ret(66 downto 64) := vliw.s1_point1;
        ret(69 downto 67) := vliw.s1_out1;
        ret(72 downto 70) := vliw.s1_in2a;
        ret(75 downto 73) := vliw.s1_in2b;
        ret(78 downto 76) := vliw.s1_op2;
        ret(81 downto 79) := vliw.s1_point2;
        ret(84 downto 82) := vliw.s1_out2;
        ret(87 downto 85) := vliw.s2_in1a;
        ret(90 downto 88) := vliw.s2_in1b;
        ret(93 downto 91) := vliw.s2_op1;
        ret(96 downto 94) := vliw.s2_out1;
        ret(99 downto 97) := vliw.s2_in2a;
        ret(102 downto 100) := vliw.s2_in2b;
        ret(105 downto 103) := vliw.s2_op2;
        ret(108 downto 106) := vliw.s2_out2;
        ret(111 downto 109) := vliw.s3_in1a;
        ret(114 downto 112) := vliw.s3_in1b;
        ret(117 downto 115) := vliw.s3_op1;
        ret(120 downto 118) := vliw.s3_out1;
        ret(123 downto 121) := vliw.s3_in2a;
        ret(126 downto 124) := vliw.s3_in2b;
        ret(129 downto 127) := vliw.s3_op2;
        ret(132 downto 130) := vliw.s3_out2;
        ret(137 downto 133) := vliw.wb;
        ret(139 downto 138) := vliw.wb_memchunk(0);
        ret(141 downto 140) := vliw.wb_memchunk(1);
        ret(143 downto 142) := vliw.wb_memchunk(2);
        ret(145 downto 144) := vliw.wb_memchunk(3);
        ret(147 downto 146) := vliw.wb_memchunk(4);
        ret(150 downto 148) := vliw.wb_bitrev(0);
        ret(153 downto 151) := vliw.wb_bitrev(1);
        ret(156 downto 154) := vliw.wb_bitrev(2);
        ret(159 downto 157) := vliw.wb_bitrev(3);
        ret(162 downto 160) := vliw.wb_bitrev(4);
        ret(165 downto 163) := vliw.wb_assign(0);
        ret(168 downto 166) := vliw.wb_assign(1);
        ret(171 downto 169) := vliw.wb_assign(2);
        ret(174 downto 172) := vliw.wb_assign(3);
        ret(177 downto 175) := vliw.wb_assign(4);
        return ret;
    end function;

    function bitrev(a: in t_data; b: in std_logic_vector(2 downto 0)) return t_data is
        variable ret : t_data;
    begin
        case b is
            when "000" => ret := a;
            when "001" => ret := (0 => a(1), 1 => a(0), others => '0');
            when "010" => ret := (0 => a(2), 1 => a(1), 2 => a(0), others => '0');
            when "011" => ret := (0 => a(3), 1 => a(2), 2 => a(1), 3 => a(0), others => '0');
            when "100" => ret := (0 => a(4), 1 => a(3), 2 => a(2), 3 => a(1), 4 => a(0), others => '0');
            when "101" => ret := (0 => a(5), 1 => a(4), 2 => a(3), 3 => a(2), 4 => a(1), 5 => a(0), others => '0');
            when "110" => ret := (0 => a(6), 1 => a(5), 2 => a(4), 3 => a(3), 4 => a(2), 5 => a(1), 6 => a(0), others => '0');
            when others => ret := (0 => a(7), 1 => a(6), 2 => a(5), 3 => a(4), 4 => a(3), 5 => a(2), 6 => a(1), 7 => a(0));
        end case;
        return ret;
    end function;

end procedures;

