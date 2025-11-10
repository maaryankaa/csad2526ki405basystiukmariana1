-- uart_baud_gen.vhd
-- Генератор такту для UART (16× oversampling)
-- Створює імпульс baud_tick кожні DIVIDER тактів системного clk
-- При 50 МГц та 9600 baud: DIVIDER = 50000000/(9600*16) = 326

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_baud_gen is
    generic (
        CLOCK_FREQ : integer := 50000000; -- Системна частота, Гц
        BAUD_RATE  : integer := 9600      -- Бажана швидкість UART, baud
    );
    port(
        clk       : in  std_logic;        -- Системний тактовий сигнал
        reset_n   : in  std_logic;        -- Активний низький reset
        baud_tick : out std_logic         -- Імпульс для UART (16x швидше за baud)
    );
end uart_baud_gen;

architecture Behavioral of uart_baud_gen is
    -- Обчислюємо дільник для 16x oversampling
    constant DIVIDER : integer := CLOCK_FREQ / (BAUD_RATE * 16);
    signal counter   : integer range 0 to DIVIDER-1 := 0;
begin

    process(clk, reset_n)
    begin
        if reset_n = '0' then
            counter   <= 0;
            baud_tick <= '0';
            
        elsif rising_edge(clk) then
            -- За замовчуванням baud_tick = '0'
            baud_tick <= '0';
            
            -- Лічильник досягає DIVIDER-1
            if counter = DIVIDER-1 then
                counter   <= 0;
                baud_tick <= '1';  -- Генеруємо імпульс на 1 такт clk
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;

end Behavioral;