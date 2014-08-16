library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.all;

use work.procedures.all;


entity rs232 is
    generic(
        BAUD_RATE : integer := 115200
    );
    port(
        rst     : in  std_logic;
        clk     : in  std_logic;

        rx      : in  std_logic;
        tx      : out std_logic;

        tx_start: in  std_logic;
        tx_d    : in  std_logic_vector(7 downto 0);
        tx_busy : out std_logic;

        rx_valid: out std_logic;
        rx_d    : out std_logic_vector(7 downto 0)
    );
end rs232;

architecture Structural of rs232 is
    constant cnt_max : integer := 50000000/BAUD_RATE/16 - 1;
    signal cnt : integer;
    signal clk16 : std_logic;

    signal tx_reg : std_logic_vector(9 downto 0);
    signal rx_reg : std_logic_vector(7 downto 0);
    signal tx_cnt : unsigned(3 downto 0);
    signal tx_bit : unsigned(3 downto 0);
    type tx_t is (TX_IDLE, TX_SYNC, TX_WRITE);
    signal tx_state : tx_t;
    signal rx_cnt : unsigned(3 downto 0);
    signal rx_bit : unsigned(2 downto 0);
    type rx_t is (RX_IDLE, RX_START, RX_READ, RX_CHECK);
    signal rx_state : rx_t;
begin

clk16 <= '1' when cnt = cnt_max else
         '0';

prescale: process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' or clk16 = '1' then
            cnt <= 0;
        else
            cnt <= cnt + 1;
        end if;
    end if;
end process prescale;

transmitter: process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            tx_state <= TX_IDLE;
        else
            case tx_state is
                when TX_IDLE =>
                    if tx_start = '1' then
                        tx_reg <= "1" & tx_d & "0";
                        tx_state <= TX_SYNC;
                        tx_cnt <= (others => '0');
                        tx_bit <= (others => '0');
                    end if;
                when TX_SYNC =>
                    if clk16 = '1' then
                        tx_state <= TX_WRITE;
                    end if;
                when TX_WRITE =>
                    if clk16 = '1' then
                        if tx_cnt = 15 then
                            tx_cnt <= (others => '0');
                            if tx_bit = 9 then
                                tx_state <= TX_IDLE;
                            else
                                tx_reg <= "0" & tx_reg(9 downto 1);
                                tx_bit <= tx_bit + 1;
                            end if;
                        else
                            tx_cnt <= tx_cnt + 1;
                        end if;
                    end if;
            end case;
        end if;
    end if;
end process transmitter;

tx <= tx_reg(0) when tx_state = TX_WRITE else
      '1';
tx_busy <= '0' when tx_state = TX_IDLE else
           '1';


receiver: process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            rx_state <= RX_IDLE;
            rx_valid <= '0';
        else
            case rx_state is
                when RX_IDLE => 
                    rx_valid <= '0';
                    if rx = '0' then
                        rx_state <= RX_START;
                        rx_cnt <= (others => '0');
                    end if;
                when RX_START =>
                    if clk16 = '1' then
                        if rx = '1' then
                            rx_state <= RX_IDLE;
                        else
                            if rx_cnt = 7 then
                                rx_cnt <= (others => '0');
                                rx_bit <= (others => '0');
                                rx_state <= RX_READ;
                            else
                                rx_cnt <= rx_cnt + 1;
                            end if;
                        end if;
                    end if;
                when RX_READ =>
                    if clk16 = '1' then
                        if rx_cnt = 15 then
                            rx_cnt <= (others => '0');
                            if rx_bit = 7 then
                                rx_cnt <= (others => '0');
                                rx_reg <= rx & rx_reg(7 downto 1);
                                rx_state <= RX_CHECK;
                            else
                                rx_bit <= rx_bit + 1;
                                rx_reg <= rx & rx_reg(7 downto 1);
                            end if;
                        else
                            rx_cnt <= rx_cnt + 1;
                        end if;
                    end if;
                when RX_CHECK =>
                    if clk16 = '1' then
                        if rx_cnt = 15 then
                            rx_cnt <= (others => '0');
                            rx_state <= RX_IDLE;
                            if rx = '1' then
                                rx_d <= rx_reg;
                                rx_valid <= '1';
                            end if;
                        else
                            rx_cnt <= rx_cnt + 1;
                        end if;
                    end if;
            end case;
        end if;
    end if;
end process receiver;

end Structural;
