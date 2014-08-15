library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.all;

use work.procedures.all;


entity serial is
    port(
        rst     : in  std_logic;
        clk     : in  std_logic;

        rx      : in std_logic;
        tx      : out std_logic;

        ena     : in std_logic;
        wea     : in std_logic;
        dia     : in std_logic_vector(7 downto 0);
        doa     : out std_logic_vector(7 downto 0);
        busy    : out std_logic
    );
end serial;

architecture Structural of serial is
    signal en_out : std_logic;
    signal en_in : std_logic;
    signal tx_d : std_logic_vector(7 downto 0);
    signal tx_start : std_logic;
    signal tx_busy : std_logic;
    signal rx_valid : std_logic;
    signal rx_d : std_logic_vector(7 downto 0);
    signal in_busy : std_logic;
    signal out_busy : std_logic;
    signal tx_read : std_logic;
    signal tx_empty : std_logic;
    type out_state_t is (IDLE, READ, WRITE);
    signal out_state : out_state_t;
begin

en_out <= ena and wea;
en_in <= ena and not wea;
busy <= in_busy when en_in = '1' else
        out_busy when en_out = '1' else
        '0';

fifo_in: entity work.fifo
port map(
        rst => rst,
        clk => clk,

        dia => rx_d,
        ena => rx_valid,
        full => open,

        dob => doa,
        enb => en_in,
        empty => in_busy
);

fifo_out: entity work.fifo
port map(
        rst => rst,
        clk => clk,

        dia => dia,
        ena => en_out,
        full => out_busy,

        dob => tx_d,
        enb => tx_read,
        empty => tx_empty
);

process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            out_state <= IDLE;
            tx_read <= '0';
            tx_start <= '0';
        else
            case out_state is
                when IDLE =>
                    tx_start <= '0';
                    if tx_empty = '0' then
                        out_state <= READ;
                        tx_read <= '1';
                    end if;
                when READ =>
                    tx_read <= '0';
                    out_state <= WRITE;
                when WRITE =>
                    if tx_busy = '0' then
                        tx_start <= '1';
                        out_state <= IDLE;
                    end if;
            end case;
        end if;
    end if;
end process;

rs232_i: entity work.rs232
port map(
    rst => rst,
    clk => clk,

    rx => rx,
    tx => tx,

    tx_start => tx_start,
    tx_d => tx_d,
    tx_busy => tx_busy,

    rx_valid => rx_valid,
    rx_d => rx_d
);

end Structural;
