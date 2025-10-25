-- uart_top.vhd
-- Топ-модуль UART, об'єднує baud_gen, tx та rx

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_top is
    port(
        clk       : in  std_logic;
        reset_n   : in  std_logic;
        tx_start  : in  std_logic;
        tx_data   : in  std_logic_vector(7 downto 0);
        rxd_in    : in  std_logic;
        txd_out   : out std_logic;
        rx_data   : out std_logic_vector(7 downto 0);
        rx_ready  : out std_logic
    );
end uart_top;

architecture Structural of uart_top is
    signal baud_tick : std_logic;
    signal tx_busy   : std_logic;
begin
    -- Генератор баудової частоти
    baud_gen_inst : entity work.uart_baud_gen
        generic map (CLOCK_FREQ => 50000000, BAUD_RATE => 9600)
        port map(clk => clk, reset_n => reset_n, baud_tick => baud_tick);

    -- UART передавач
    tx_inst : entity work.uart_tx
        port map(
            clk       => clk,
            reset_n   => reset_n,
            tx_start  => tx_start,
            tx_data   => tx_data,
            baud_tick => baud_tick,
            txd_out   => txd_out,
            tx_busy   => tx_busy
        );

    -- UART приймач
    rx_inst : entity work.uart_rx
        port map(
            clk       => clk,
            reset_n   => reset_n,
            rxd_in    => rxd_in,
            baud_tick => baud_tick,
            rx_data   => rx_data,
            rx_ready  => rx_ready
        );
end Structural;
