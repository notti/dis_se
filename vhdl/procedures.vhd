library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

package procedures is

    subtype t_data is std_logic_vector(7 downto 0);
        
    type t_data_array is array(natural range <>) of t_data;
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
            last_val     : std_logic;
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
        end record;
    constant empty_vliw : t_vliw := (
        arg_type => (others => (others => '0')),
        arg_memchunk => (others => (others => '0')),
        arg_assign => (others => (others => '0')),
        last_val => '0',
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
        wb_memchunk => (others => (others => '0'))
    );
    constant VLIW_HIGH : natural := 173;

    function index2val(signal val: in t_data_array(4 downto 0);
                       signal index: in std_logic_vector(2 downto 0)) return t_data;
    function slv2vliw(slv: in std_logic_vector(VLIW_HIGH downto 0)) return t_vliw;

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
        ret.last_val        := slv(20);
        ret.arg_assign(0)   := slv(23 downto 21);
        ret.arg_assign(1)   := slv(26 downto 24);
        ret.arg_assign(2)   := slv(29 downto 27);
        ret.arg_assign(3)   := slv(32 downto 30);
        ret.arg_assign(4)   := slv(35 downto 33);
        ret.mem_fetch       := slv(40 downto 36);
        ret.mem_memchunk(0) := slv(42 downto 41);
        ret.mem_memchunk(1) := slv(44 downto 43);
        ret.mem_memchunk(2) := slv(46 downto 45);
        ret.mem_memchunk(3) := slv(48 downto 47);
        ret.mem_memchunk(4) := slv(50 downto 49);
        ret.s1_in1a         := slv(53 downto 51);
        ret.s1_in1b         := slv(56 downto 54);
        ret.s1_op1          := slv(59 downto 57);
        ret.s1_point1       := slv(62 downto 60);
        ret.s1_out1         := slv(65 downto 63);
        ret.s1_in2a         := slv(68 downto 66);
        ret.s1_in2b         := slv(71 downto 69);
        ret.s1_op2          := slv(74 downto 72);
        ret.s1_point2       := slv(77 downto 75);
        ret.s1_out2         := slv(80 downto 78);
        ret.s2_in1a         := slv(83 downto 81);
        ret.s2_in1b         := slv(86 downto 84);
        ret.s2_op1          := slv(89 downto 87);
        ret.s2_out1         := slv(92 downto 90);
        ret.s2_in2a         := slv(95 downto 93);
        ret.s2_in2b         := slv(98 downto 96);
        ret.s2_op2          := slv(101 downto 99);
        ret.s2_out2         := slv(104 downto 102);
        ret.s3_in1a         := slv(107 downto 105);
        ret.s3_in1b         := slv(110 downto 108);
        ret.s3_op1          := slv(113 downto 111);
        ret.s3_out1         := slv(116 downto 114);
        ret.s3_in2a         := slv(119 downto 117);
        ret.s3_in2b         := slv(122 downto 120);
        ret.s3_op2          := slv(125 downto 123);
        ret.s3_out2         := slv(128 downto 126);
        ret.wb              := slv(133 downto 129);
        ret.wb_memchunk(0)  := slv(135 downto 134);
        ret.wb_memchunk(1)  := slv(137 downto 136);
        ret.wb_memchunk(2)  := slv(139 downto 138);
        ret.wb_memchunk(3)  := slv(141 downto 140);
        ret.wb_memchunk(4)  := slv(143 downto 142);
        ret.wb_bitrev(0)    := slv(146 downto 144);
        ret.wb_bitrev(1)    := slv(149 downto 147);
        ret.wb_bitrev(2)    := slv(152 downto 150);
        ret.wb_bitrev(3)    := slv(155 downto 153);
        ret.wb_bitrev(4)    := slv(158 downto 156);
        ret.wb_assign(0)    := slv(161 downto 159);
        ret.wb_assign(1)    := slv(164 downto 162);
        ret.wb_assign(2)    := slv(167 downto 165);
        ret.wb_assign(3)    := slv(170 downto 168);
        ret.wb_assign(4)    := slv(173 downto 171);
        return ret;
    end function;

end procedures;

