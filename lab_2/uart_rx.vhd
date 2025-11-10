-- uart_rx.vhd
-- Приймач UART, 8N1, 16× oversampling

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_rx is
    port(
        clk       : in  std_logic;
        reset_n   : in  std_logic;
        rxd_in    : in  std_logic;
        baud_tick : in  std_logic;
        rx_data   : out std_logic_vector(7 downto 0);
        rx_ready  : out std_logic
    );
end uart_rx;

architecture Behavioral of uart_rx is
    type state_type is (IDLE, START_BIT, DATA_BITS, STOP_BIT);
    signal state      : state_type := IDLE;
    signal bit_cnt    : integer range 0 to 7 := 0;
    signal shift_reg  : std_logic_vector(7 downto 0) := (others=>'0');
    signal sample_cnt : integer range 0 to 15 := 0;
    signal rx_reg     : std_logic_vector(7 downto 0) := (others=>'0');
begin
    rx_data  <= rx_reg;

    process(clk, reset_n)
    begin
        if reset_n = '0' then
            state      <= IDLE;
            shift_reg  <= (others=>'0');
            bit_cnt    <= 0;
            sample_cnt <= 0;
            rx_ready   <= '0';
            rx_reg     <= (others=>'0');
        elsif rising_edge(clk) then

            -- ВИПРАВЛЕНО: 'ready' - це імпульс.
            -- Він '0' за замовчуванням у кожному такті...
            rx_ready <= '0'; 

            if baud_tick = '1' then
                case state is
                    when IDLE =>
                        if rxd_in = '0' then -- Знайшли старт-біт
                            state      <= START_BIT;
                            sample_cnt <= 0;
                        end if;

                    when START_BIT =>
                        -- Чекаємо СЕРЕДИНИ старт-біта
                        if sample_cnt = 7 then 
                            if rxd_in = '0' then -- Перевіряємо, чи це не шум
                                state      <= DATA_BITS;
                                sample_cnt <= 0; 
                                bit_cnt    <= 0;
                            else
                                state <= IDLE; -- Це був шум, повертаємось
                            end if;
                        else
                            sample_cnt <= sample_cnt + 1;
                        end if;

                    when DATA_BITS =>
                        -- Чекаємо 16 тіків, що приводить нас до СЕРЕДИНИ біта
                        if sample_cnt = 15 then 
                            shift_reg(bit_cnt) <= rxd_in; -- Семплуємо
                            sample_cnt <= 0; 
                            if bit_cnt = 7 then
                                state <= STOP_BIT;
                            else
                                bit_cnt <= bit_cnt + 1;
                            end if;
                        else
                            sample_cnt <= sample_cnt + 1;
                        end if;

                    when STOP_BIT =>
                        -- Чекаємо середини стоп-біта
                        if sample_cnt = 15 then 
                            if rxd_in = '1' then -- Перевіряємо валідний стоп-біт
                                rx_reg <= shift_reg;
                                -- ...тільки в цей момент він стає '1' на один такт
                                rx_ready  <= '1'; 
                            end if;
                            state <= IDLE; -- У будь-якому випадку повертаємось в IDLE
                        else
                            sample_cnt <= sample_cnt + 1;
                        end if;

                    when others =>
                        state <= IDLE;
                end case;
            end if;
        end if;
    end process;
    
end Behavioral;