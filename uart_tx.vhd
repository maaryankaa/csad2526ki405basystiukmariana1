-- uart_tx.vhd
-- Передавач UART, 8 біт даних, без парності, 1 стоп-біт (8N1)
-- Вхід: clk, reset_n, tx_start, tx_data
-- Вихід: txd_out, tx_busy

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_tx is
    port(
        clk       : in  std_logic;
        reset_n   : in  std_logic;
        tx_start  : in  std_logic;
        tx_data   : in  std_logic_vector(7 downto 0);
        baud_tick : in  std_logic;
        txd_out   : out std_logic;
        tx_busy   : out std_logic
    );
end uart_tx;

architecture Behavioral of uart_tx is
    type state_type is (IDLE, START_BIT, DATA_BITS, STOP_BIT);
    signal state     : state_type := IDLE;
    signal bit_cnt   : integer range 0 to 7 := 0;
    signal shift_reg : std_logic_vector(7 downto 0) := (others=>'0');
    signal tx_reg    : std_logic := '1';
begin
    txd_out <= tx_reg;
    tx_busy <= '1' when state /= IDLE else '0';

    process(clk, reset_n)
    begin
        if reset_n = '0' then
            state <= IDLE;
            bit_cnt <= 0;
            shift_reg <= (others=>'0');
            tx_reg <= '1';
        elsif rising_edge(clk) then
            if baud_tick = '1' then
                case state is
                    when IDLE =>
                        if tx_start = '1' then
                            shift_reg <= tx_data;
                            state <= START_BIT;
                            tx_reg <= '0'; -- старт-біт
                        else
                            tx_reg <= '1';
                        end if;

                    when START_BIT =>
                        state <= DATA_BITS;
                        bit_cnt <= 0;
                        tx_reg <= shift_reg(0);

                    when DATA_BITS =>
                        if bit_cnt = 7 then
                            state <= STOP_BIT;
                        else
                            bit_cnt <= bit_cnt + 1;
                        end if;
                        shift_reg <= shift_reg(7 downto 1) & '0';
                        tx_reg <= shift_reg(0);

                    when STOP_BIT =>
                        tx_reg <= '1';
                        state <= IDLE;

                    when others =>
                        state <= IDLE;
                end case;
            end if;
        end if;
    end process;
end Behavioral;
