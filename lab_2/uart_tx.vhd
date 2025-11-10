-- uart_tx.vhd
-- Передавач UART, 8N1
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
    signal data_reg  : std_logic_vector(7 downto 0) := (others=>'0');
    signal bit_cnt   : integer range 0 to 7 := 0;
    signal tick_cnt  : integer range 0 to 15 := 0;
begin

    process(clk, reset_n)
    begin
        if reset_n = '0' then
            state     <= IDLE;
            txd_out   <= '1';
            tx_busy   <= '0';
            data_reg  <= (others=>'0');
            bit_cnt   <= 0;
            tick_cnt  <= 0;
            
        elsif rising_edge(clk) then
            
            case state is
                when IDLE =>
                    txd_out  <= '1';
                    tx_busy  <= '0';
                    bit_cnt  <= 0;
                    tick_cnt <= 0;
                    
                    if tx_start = '1' then
                        data_reg <= tx_data;
                        state    <= START_BIT;
                        tx_busy  <= '1';
                    end if;
                
                when START_BIT =>
                    txd_out <= '0';
                    
                    if baud_tick = '1' then
                        if tick_cnt = 15 then
                            tick_cnt <= 0;
                            state    <= DATA_BITS;
                        else
                            tick_cnt <= tick_cnt + 1;
                        end if;
                    end if;
                
                when DATA_BITS =>
                    txd_out <= data_reg(bit_cnt);
                    
                    if baud_tick = '1' then
                        if tick_cnt = 15 then
                            tick_cnt <= 0;
                            
                            if bit_cnt = 7 then
                                state   <= STOP_BIT;
                                bit_cnt <= 0;
                            else
                                bit_cnt <= bit_cnt + 1;
                            end if;
                        else
                            tick_cnt <= tick_cnt + 1;
                        end if;
                    end if;
                
                when STOP_BIT =>
                    txd_out <= '1';
                    
                    if baud_tick = '1' then
                        if tick_cnt = 15 then
                            tick_cnt <= 0;
                            state    <= IDLE;
                            tx_busy  <= '0';
                        else
                            tick_cnt <= tick_cnt + 1;
                        end if;
                    end if;
                
                when others =>
                    state <= IDLE;
            end case;
            
        end if;
    end process;

end Behavioral;