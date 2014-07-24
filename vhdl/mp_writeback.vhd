library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.all;

use work.procedures.all;


entity mp_writeback is
    port(
        rst     : in  std_logic;
        clk     : in  std_logic;

        cmd_in  : in  t_vliw;
        arg_in  : in  t_data_array(4 downto 0);
        val_in  : in  t_data_array(4 downto 0);

        mem_wr  : out std_logic;
        mem_data : out t_data;
        mem_addr : out t_data;
    );
end mp_writeback;

architecture Structural of mp_writeback is
begin


end Structural;
