-- tb_uart.vhd
-- Simple testbench for UART without automatic checks
-- For visual analysis on waveform

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_uart is
end tb_uart;

architecture Behavioral of tb_uart is
    -- Constants
    constant CLK_PERIOD  : time := 20 ns;        -- 50 MHz
    constant BIT_PERIOD  : time := 104166 ns;    -- 9600 baud
    
    -- Signals for uart_top connection
    signal clk       : std_logic := '0';
    signal reset_n   : std_logic := '0';
    signal tx_start  : std_logic := '0';
    signal tx_data   : std_logic_vector(7 downto 0) := (others=>'0');
    signal rxd_in    : std_logic := '1';
    signal txd_out   : std_logic;
    signal rx_data   : std_logic_vector(7 downto 0);
    signal rx_ready  : std_logic;
    
    -- Helper signal to stop simulation
    signal sim_done : boolean := false;
    
begin
    -- ============================================
    -- UART module instance under test
    -- ============================================
    uut: entity work.uart_top
        port map (
            clk      => clk,
            reset_n  => reset_n,
            tx_start => tx_start,
            tx_data  => tx_data,
            rxd_in   => rxd_in,
            txd_out  => txd_out,
            rx_data  => rx_data,
            rx_ready => rx_ready
        );
    
    -- ============================================
    -- Clock generation (CLK)
    -- ============================================
    clk_process : process
    begin
        while not sim_done loop
            clk <= '0';
            wait for CLK_PERIOD/2;
            clk <= '1';
            wait for CLK_PERIOD/2;
        end loop;
        wait;
    end process;
    
    -- ============================================
    -- Main stimulus process
    -- ============================================
    stimulus : process
    begin
        -- ========================================
        -- 1. Reset signal generation
        -- ========================================
        report "Starting UART testing" severity note;
        
        reset_n <= '0';  -- Active reset
        rxd_in  <= '1';  -- RX line idle
        wait for 200 ns;
        
        reset_n <= '1';  -- Release reset
        wait for 200 ns;
        
        -- ========================================
        -- 2. Send test data to transmitter (TX)
        -- ========================================
        report "Test 1: Transmit byte 0xA5" severity note;
        
        tx_data  <= X"A5";  -- Load data
        tx_start <= '1';    -- Start transmission
        wait for CLK_PERIOD;
        tx_start <= '0';    -- Release start signal
        
        -- Wait for transmission to complete (10 bits * 104 us)
        wait for BIT_PERIOD * 11;
        
        report "Test 1 complete" severity note;
        wait for 500 us;
        
        -- ========================================
        -- 3. Simulate data transmission to receiver (RX)
        -- ========================================
        report "Test 2: Receive byte 0x55" severity note;
        
        -- Start bit
        rxd_in <= '0';
        wait for BIT_PERIOD;
        
        -- Bit 0 (LSB): 0x55 = 01010101
        rxd_in <= '1';
        wait for BIT_PERIOD;
        
        -- Bit 1
        rxd_in <= '0';
        wait for BIT_PERIOD;
        
        -- Bit 2
        rxd_in <= '1';
        wait for BIT_PERIOD;
        
        -- Bit 3
        rxd_in <= '0';
        wait for BIT_PERIOD;
        
        -- Bit 4
        rxd_in <= '1';
        wait for BIT_PERIOD;
        
        -- Bit 5
        rxd_in <= '0';
        wait for BIT_PERIOD;
        
        -- Bit 6
        rxd_in <= '1';
        wait for BIT_PERIOD;
        
        -- Bit 7 (MSB)
        rxd_in <= '0';
        wait for BIT_PERIOD;
        
        -- Stop bit
        rxd_in <= '1';
        wait for BIT_PERIOD;
        
        report "Test 2 complete" severity note;
        wait for 500 us;
        
        -- ========================================
        -- 4. Transmit another byte via TX
        -- ========================================
        report "Test 3: Transmit byte 0x3C" severity note;
        
        tx_data  <= X"3C";
        tx_start <= '1';
        wait for CLK_PERIOD;
        tx_start <= '0';
        
        wait for BIT_PERIOD * 11;
        
        report "Test 3 complete" severity note;
        wait for 500 us;
        
        -- ========================================
        -- 5. Receive another byte
        -- ========================================
        report "Test 4: Receive byte 0xFF" severity note;
        
        -- Start bit
        rxd_in <= '0';
        wait for BIT_PERIOD;
        
        -- All bits = '1' for 0xFF
        for i in 0 to 7 loop
            rxd_in <= '1';
            wait for BIT_PERIOD;
        end loop;
        
        -- Stop bit
        rxd_in <= '1';
        wait for BIT_PERIOD;
        
        report "Test 4 complete" severity note;
        wait for 500 us;
        
        -- ========================================
        -- End of simulation
        -- ========================================
        report "All tests complete. Check waveform." severity note;
        sim_done <= true;
        wait;
    end process;

end Behavioral;