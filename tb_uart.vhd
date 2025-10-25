-- tb_uart.vhd
-- Тестбенч для UART: перевірка loopback TX → RX
-- Симулює передачу одного байта та перевірку прийому

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_uart is
-- Тестбенч не має портів
end tb_uart;

architecture Behavioral of tb_uart is

    -- Сигнали для підключення uart_top
    signal clk       : std_logic := '0';
    signal reset_n   : std_logic := '0';
    signal tx_start  : std_logic := '0';
    signal tx_data   : std_logic_vector(7 downto 0) := (others => '0');
    signal rxd_in    : std_logic := '1';
    signal txd_out   : std_logic;
    signal rx_data   : std_logic_vector(7 downto 0);
    signal rx_ready  : std_logic;

    -- Параметри симуляції
    constant CLOCK_PERIOD : time := 20 ns; -- 50 MHz

begin
    -- Інстанція топ-модуля UART
    uart_top_inst : entity work.uart_top
        port map(
            clk       => clk,
            reset_n   => reset_n,
            tx_start  => tx_start,
            tx_data   => tx_data,
            rxd_in    => txd_out, -- loopback: TX підключається до RX
            txd_out   => txd_out,
            rx_data   => rx_data,
            rx_ready  => rx_ready
        );

    -- Генератор тактового сигналу
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for CLOCK_PERIOD/2;
            clk <= '1';
            wait for CLOCK_PERIOD/2;
        end loop;
        wait;
    end process;

    -- Сценарій тесту
    stim_proc : process
    begin
        -- Скидання
        reset_n <= '0';
        wait for 100 ns;
        reset_n <= '1';
        wait for 100 ns;

        -- Відправка байта 0x55
        tx_data  <= x"55";
        tx_start <= '1';
        wait for CLOCK_PERIOD;
        tx_start <= '0';

        -- Чекати, поки rx_ready стане '1'
        wait until rx_ready = '1';
        assert rx_data = x"55"
        report "UART loopback test PASSED"
        severity note;

        wait for 100 ns;
        -- Відправка іншого байта 0xA5
        tx_data  <= x"A5";
        tx_start <= '1';
        wait for CLOCK_PERIOD;
        tx_start <= '0';

        wait until rx_ready = '1';
        assert rx_data = x"A5"
        report "UART loopback test PASSED"
        severity note;

        wait;
    end process;

end Behavioral;
