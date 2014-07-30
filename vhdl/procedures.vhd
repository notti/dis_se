library IEEE;
use IEEE.std_logic_1164.all;

package procedures is

    subtype t_data is std_logic_vector(7 downto 0);
        
    type t_data_array is array(natural range <>) of t_data;
    type t_2array is array(natural range <>) of std_logic_vector(1 downto 0);
    type t_3array is array(natural range <>) of std_logic_vector(2 downto 0);

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
            wb_assign    : t_3array(4 downto 0);
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


end package;

package body procedures is

end procedures;

