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

    constant ALUIN_0   : std_logic_vector(2 downto 0) := "110";
    constant ALUIN_1   : std_logic_vector(2 downto 0) := "111";

    type t_vliw is
        record
            -- fetch_decode
            arg_type     : t_2array(5 downto 0);
            arg_memchunk : t_2array(5 downto 0);
            
            -- indirect_fetch
            arg_val      : std_logic_vector(5 downto 0);
            arg_assign   : t_3array(5 downto 0);
            mem_fetch    : std_logic_vector(5 downto 0);
            mem_memchunk : t_2array(5 downto 0);

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
            wb           : std_logic_vector(5 downto 0);
            wb_memchunk  : t_2array(5 downto 0);
            wb_bitrev    : t_3array(5 downto 0);
            wb_assign    : t_3array(5 downto 0);

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
    constant VLIW_HIGH : natural := 197;

    function index2val(signal val: in t_data_array(5 downto 0);
                       signal index: in std_logic_vector(2 downto 0)) return t_data;
    function slv2vliw(slv: in std_logic_vector(VLIW_HIGH downto 0)) return t_vliw;
    function vliw2slv(vliw: in t_vliw) return std_logic_vector;
    function bitrev(a: in t_data; b: in std_logic_vector(2 downto 0)) return t_data;

end package;

package body procedures is

    function index2val(signal val: in t_data_array(5 downto 0);
                       signal index: in std_logic_vector(2 downto 0)) return t_data is
        variable res : t_data;
    begin
        case to_integer(unsigned(index)) is
            when 0 to 5 => res := val(to_integer(unsigned(index)));
            when 7 => res := (0 => '1', others => '0');
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
        ret.arg_type(5)     := slv(11 downto 10);
        ret.arg_memchunk(0) := slv(13 downto 12);
        ret.arg_memchunk(1) := slv(15 downto 14);
        ret.arg_memchunk(2) := slv(17 downto 16);
        ret.arg_memchunk(3) := slv(19 downto 18);
        ret.arg_memchunk(4) := slv(21 downto 20);
        ret.arg_memchunk(5) := slv(23 downto 22);
        ret.arg_val         := slv(29 downto 24);
        ret.arg_assign(0)   := slv(32 downto 30);
        ret.arg_assign(1)   := slv(35 downto 33);
        ret.arg_assign(2)   := slv(38 downto 36);
        ret.arg_assign(3)   := slv(41 downto 39);
        ret.arg_assign(4)   := slv(44 downto 42);
        ret.arg_assign(5)   := slv(47 downto 45);
        ret.mem_fetch       := slv(53 downto 48);
        ret.mem_memchunk(0) := slv(55 downto 54);
        ret.mem_memchunk(1) := slv(57 downto 56);
        ret.mem_memchunk(2) := slv(59 downto 58);
        ret.mem_memchunk(3) := slv(61 downto 60);
        ret.mem_memchunk(4) := slv(63 downto 62);
        ret.mem_memchunk(5) := slv(65 downto 64);
        ret.s1_in1a         := slv(68 downto 66);
        ret.s1_in1b         := slv(71 downto 69);
        ret.s1_op1          := slv(74 downto 72);
        ret.s1_point1       := slv(77 downto 75);
        ret.s1_out1         := slv(80 downto 78);
        ret.s1_in2a         := slv(83 downto 81);
        ret.s1_in2b         := slv(86 downto 84);
        ret.s1_op2          := slv(89 downto 87);
        ret.s1_point2       := slv(92 downto 90);
        ret.s1_out2         := slv(95 downto 93);
        ret.s2_in1a         := slv(98 downto 96);
        ret.s2_in1b         := slv(101 downto 99);
        ret.s2_op1          := slv(104 downto 102);
        ret.s2_out1         := slv(107 downto 105);
        ret.s2_in2a         := slv(110 downto 108);
        ret.s2_in2b         := slv(113 downto 111);
        ret.s2_op2          := slv(116 downto 114);
        ret.s2_out2         := slv(119 downto 117);
        ret.s3_in1a         := slv(122 downto 120);
        ret.s3_in1b         := slv(125 downto 123);
        ret.s3_op1          := slv(128 downto 126);
        ret.s3_out1         := slv(131 downto 129);
        ret.s3_in2a         := slv(134 downto 132);
        ret.s3_in2b         := slv(137 downto 135);
        ret.s3_op2          := slv(140 downto 138);
        ret.s3_out2         := slv(143 downto 141);
        ret.wb              := slv(149 downto 144);
        ret.wb_memchunk(0)  := slv(151 downto 150);
        ret.wb_memchunk(1)  := slv(153 downto 152);
        ret.wb_memchunk(2)  := slv(155 downto 154);
        ret.wb_memchunk(3)  := slv(157 downto 156);
        ret.wb_memchunk(4)  := slv(159 downto 158);
        ret.wb_memchunk(5)  := slv(161 downto 160);
        ret.wb_bitrev(0)    := slv(164 downto 162);
        ret.wb_bitrev(1)    := slv(167 downto 165);
        ret.wb_bitrev(2)    := slv(170 downto 168);
        ret.wb_bitrev(3)    := slv(173 downto 171);
        ret.wb_bitrev(4)    := slv(176 downto 174);
        ret.wb_bitrev(5)    := slv(179 downto 177);
        ret.wb_assign(0)    := slv(182 downto 180);
        ret.wb_assign(1)    := slv(185 downto 183);
        ret.wb_assign(2)    := slv(188 downto 186);
        ret.wb_assign(3)    := slv(191 downto 189);
        ret.wb_assign(4)    := slv(194 downto 192);
        ret.wb_assign(5)    := slv(197 downto 195);
        ret.noop            := '0';
        return ret;
    end function;

    function vliw2slv(vliw: in t_vliw) return std_logic_vector is
        variable ret : std_logic_vector(VLIW_HIGH downto 0);
    begin
        ret(1 downto 0)     := vliw.arg_type(0);
        ret(3 downto 2)     := vliw.arg_type(1);
        ret(5 downto 4)     := vliw.arg_type(2);
        ret(7 downto 6)     := vliw.arg_type(3);
        ret(9 downto 8)     := vliw.arg_type(4);
        ret(11 downto 10)   := vliw.arg_type(5);
        ret(13 downto 12)   := vliw.arg_memchunk(0);
        ret(15 downto 14)   := vliw.arg_memchunk(1);
        ret(17 downto 16)   := vliw.arg_memchunk(2);
        ret(19 downto 18)   := vliw.arg_memchunk(3);
        ret(21 downto 20)   := vliw.arg_memchunk(4);
        ret(23 downto 22)   := vliw.arg_memchunk(5);
        ret(29 downto 24)   := vliw.arg_val;
        ret(32 downto 30)   := vliw.arg_assign(0);
        ret(35 downto 33)   := vliw.arg_assign(1);
        ret(38 downto 36)   := vliw.arg_assign(2);
        ret(41 downto 39)   := vliw.arg_assign(3);
        ret(44 downto 42)   := vliw.arg_assign(4);
        ret(47 downto 45)   := vliw.arg_assign(5);
        ret(53 downto 48)   := vliw.mem_fetch;
        ret(55 downto 54)   := vliw.mem_memchunk(0);
        ret(57 downto 56)   := vliw.mem_memchunk(1);
        ret(59 downto 58)   := vliw.mem_memchunk(2);
        ret(61 downto 60)   := vliw.mem_memchunk(3);
        ret(63 downto 62)   := vliw.mem_memchunk(4);
        ret(65 downto 64)   := vliw.mem_memchunk(5);
        ret(68 downto 66)   := vliw.s1_in1a;
        ret(71 downto 69)   := vliw.s1_in1b;
        ret(74 downto 72)   := vliw.s1_op1;
        ret(77 downto 75)   := vliw.s1_point1;
        ret(80 downto 78)   := vliw.s1_out1;
        ret(83 downto 81)   := vliw.s1_in2a;
        ret(86 downto 84)   := vliw.s1_in2b;
        ret(89 downto 87)   := vliw.s1_op2;
        ret(92 downto 90)   := vliw.s1_point2;
        ret(95 downto 93)   := vliw.s1_out2;
        ret(98 downto 96)   := vliw.s2_in1a;
        ret(101 downto 99)  := vliw.s2_in1b;
        ret(104 downto 102) := vliw.s2_op1;
        ret(107 downto 105) := vliw.s2_out1;
        ret(110 downto 108) := vliw.s2_in2a;
        ret(113 downto 111) := vliw.s2_in2b;
        ret(116 downto 114) := vliw.s2_op2;
        ret(119 downto 117) := vliw.s2_out2;
        ret(122 downto 120) := vliw.s3_in1a;
        ret(125 downto 123) := vliw.s3_in1b;
        ret(128 downto 126) := vliw.s3_op1;
        ret(131 downto 129) := vliw.s3_out1;
        ret(134 downto 132) := vliw.s3_in2a;
        ret(137 downto 135) := vliw.s3_in2b;
        ret(140 downto 138) := vliw.s3_op2;
        ret(143 downto 141) := vliw.s3_out2;
        ret(149 downto 144) := vliw.wb;
        ret(151 downto 150) := vliw.wb_memchunk(0);
        ret(153 downto 152) := vliw.wb_memchunk(1);
        ret(155 downto 154) := vliw.wb_memchunk(2);
        ret(157 downto 156) := vliw.wb_memchunk(3);
        ret(159 downto 158) := vliw.wb_memchunk(4);
        ret(161 downto 160) := vliw.wb_memchunk(5);
        ret(164 downto 162) := vliw.wb_bitrev(0);
        ret(167 downto 165) := vliw.wb_bitrev(1);
        ret(170 downto 168) := vliw.wb_bitrev(2);
        ret(173 downto 171) := vliw.wb_bitrev(3);
        ret(176 downto 174) := vliw.wb_bitrev(4);
        ret(179 downto 177) := vliw.wb_bitrev(5);
        ret(182 downto 180) := vliw.wb_assign(0);
        ret(185 downto 183) := vliw.wb_assign(1);
        ret(188 downto 186) := vliw.wb_assign(2);
        ret(191 downto 189) := vliw.wb_assign(3);
        ret(194 downto 192) := vliw.wb_assign(4);
        ret(197 downto 195) := vliw.wb_assign(5);
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

