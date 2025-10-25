-- uart_rx.vhd
-- Приймач UART, 8N1, 16× oversampling
-- Вхід: clk, reset_n, rxd_in
-- Вихід: rx_data, rx_ready

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
    signal state     : state_type := IDLE;
    signal bit_cnt   : integer range 0 to 7 := 0;
    signal shift_reg : std_logic_vector(7 downto 0) := (others=>'0');
    signal sample_cnt: integer range 0 to 15 := 0;
    signal rx_reg    : std_logic_vector(7 downto 0) := (others=>'0');
    signal ready     : std_logic := '0';
begin
    rx_data  <= rx_reg;
    rx_ready <= ready;

    process(clk, reset_n)
    begin
        if reset_n = '0' then
            state <= IDLE;
            shift_reg <= (others=>'0');
            bit_cnt <= 0;
            sample_cnt <= 0;
            ready <= '0';
        elsif rising_edge(clk) then
            if baud_tick = '1' then
                ready <= '0'; -- чистимо сигнал готовності
                case state is
                    when IDLE =>
                        if rxd_in = '0' then -- старт-біт
                            state <= START_BIT;
                            sample_cnt <= 0;
                        end if;

                    when START_BIT =>
                        if sample_cnt = 15 then
                            state <= DATA_BITS;
                            bit_cnt <= 0;
                            sample_cnt <= 0;
                        else
                            sample_cnt <= sample_cnt + 1;
                        end if;

                    when DATA_BITS =>
                        if sample_cnt = 15 then
                            shift_reg(bit_cnt) <= rxd_in;
                            if bit_cnt = 7 then
                                state <= STOP_BIT;
                            else
                                bit_cnt <= bit_cnt + 1;
                            end if;
                            sample_cnt <= 0;
                        else
                            sample_cnt <= sample_cnt + 1;
                        end if;

                    when STOP_BIT =>
                        if rxd_in = '1' then
                            rx_reg <= shift_reg;
                            ready <= '1';
                        end if;
                        state <= IDLE;

                    when others =>
                        state <= IDLE;
                end case;
            end if;
        end if;
    end process;
end Behavioral;
