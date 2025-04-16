----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/04/2025 12:44:00 AM
-- Design Name: 
-- Module Name: bcd_mux - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

-- Entity displays maximum of two hex numbers one to four digits wide
-- Should be instantiated

entity bcd_mux is
    Generic (
        N_DIGITS : integer range 1 to 4 := 3;                             -- Digits used for single number
        N_SIGNALS : integer range 1 to 2 := 2                            -- Numbers displayed
    );
    Port ( clk      : in STD_LOGIC;                          -- Component clock, controls the multiplexer speed (ideally 50 ms)
           hold     : in STD_LOGIC;                          -- Hold the current displayed values
           bcd      : in STD_LOGIC_VECTOR ((N_DIGITS*4)*N_SIGNALS-1 downto 0);  -- BCD inputs for all digits
           bin      : out STD_LOGIC_VECTOR (3 downto 0);     -- Binary output to 7 segment display component
           anodes   : out STD_LOGIC_VECTOR (7 downto 0));     -- 7 segment display anode vector, supports 8 displays
end bcd_mux;

architecture Behavioral of bcd_mux is
    signal sig_bcd : STD_LOGIC_VECTOR ((N_DIGITS*4)*N_SIGNALS-1 downto 0); -- BCD signal buffer
    signal next_digit : integer range 0 to N_DIGITS*N_SIGNALS-1 := 0;                -- Next digit to display
    signal space : integer range 1 to 3 := 4 - N_DIGITS; -- make constant out of this
begin

    -- Main multiplexer process
    -- Triggers on every clock input
    multiplex : process (clk) is
    begin

      if rising_edge(clk) then
        -- Hold the value if hold is active,
        -- buffer new input value if hold inactive.
        if hold = '0' then
            sig_bcd <= bcd;
        end if;

            -- Multiplex according to next digit number
            -- 1. separate one digit from the buffer
            -- 2. activate corresponding display anode and space it if two signals
            -- 3. write the next digit or start ahead

            bin <= sig_bcd(next_digit*4+3 downto next_digit*4);

            anodes <= (others => '1');
            if N_SIGNALS = 2 and next_digit >= N_DIGITS then
                anodes(next_digit+space) <= '0';
            else
                anodes(next_digit) <= '0';
            end if;

            if next_digit < N_DIGITS*N_SIGNALS-1 then
                next_digit <= next_digit + 1;
            else
                next_digit <= 0;
            end if;

      end if;    
    end process multiplex;

end Behavioral;
