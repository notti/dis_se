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

    function index2val(signal val: in t_data_array(4 downto 0);
                       signal index: in std_logic_vector(2 downto 0)) return t_data;

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

end procedures;

