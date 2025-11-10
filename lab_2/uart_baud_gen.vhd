-- uart_baud_gen.vhd
-- Генератор такту для UART (16× oversampling)
-- Вхід: clk - системний тактовий сигнал
--        reset_n - активний низький сигнал скидання
-- Вихід: baud_tick - тактова частота для UART

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_baud_gen is
    generic (
        CLOCK_FREQ : integer := 50000000; -- системна частота, Гц
        BAUD_RATE  : integer := 9600      -- бажана швидкість UART
    );
    port(
        clk       : in  std_logic;
        reset_n   : in  std_logic;
        baud_tick : out std_logic
    );
end uart_baud_gen;

architecture Behavioral of uart_baud_gen is
    constant DIVIDER : integer := CLOCK_FREQ / (BAUD_RATE*16);
    signal counter  : integer range 0 to DIVIDER := 0;
begin
    process(clk, reset_n)
    begin
        if reset_n = '0' then
            counter <= 0;
            baud_tick <= '0';
        elsif rising_edge(clk) then
            if counter = DIVIDER/2 then
                baud_tick <= '1';
            else
                baud_tick <= '0';
            end if;

            if counter = DIVIDER-1 then
                counter <= 0;
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;
end Behavioral;
