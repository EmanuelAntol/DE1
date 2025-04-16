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

entity bcd_mux is
    --Generic (
    --    N_DIGITS : integer := 3;                             -- Digits used for single number
    --    N_SIGNALS : integer := 2;                            -- Numbers displayed
    --);
    Port ( clk      : in STD_LOGIC;                          -- Component clock, controls the multiplexer speed (ideally 50 ms)
           hold     : in STD_LOGIC;                          -- Hold the current displayed values
           bcd      : in STD_LOGIC_VECTOR (23 downto 0);--((N_DIGITS*4)*N_SIGNALS)-1  -- BCD inputs for all digits
           bin      : out STD_LOGIC_VECTOR (3 downto 0);     -- Binary output to 7 segment display component
           anodes   : out STD_LOGIC_VECTOR (7 downto 0));--N_DISPLAYS-1  -- 7 segment display anode vector, supports 8 displays
end bcd_mux;

architecture Behavioral of bcd_mux is
    signal sig_bcd : STD_LOGIC_VECTOR (23 downto 0); --(N_DIGITS*4-1)*N_SIGNALS -- BCD signal buffer
    signal next_digit : integer range 0 to 5;                -- Next digit to display
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
            -- 1. set the following digit
            -- 2. separate one digit from the buffer
            -- 3. activate corresponding display anode
            case next_digit is --todo unhardcode
                when 0 =>
                    next_digit <= 1;
                    bin <= sig_bcd(3 downto 0);
                    anodes <= b"1111_1110";
                when 1 =>
                    next_digit <= 2;
                    bin <= sig_bcd(7 downto 4);
                    anodes <= b"1111_1101";
                when 2 =>
                    next_digit <= 3;
                    bin <= sig_bcd(11 downto 8);
                    anodes <= b"1111_1011";
                when 3 =>
                    next_digit <= 4;
                    bin <= sig_bcd(15 downto 12);
                    anodes <= b"1110_1111";
                when 4 =>
                    next_digit <= 5;
                    bin <= sig_bcd(19 downto 16);
                    anodes <= b"1101_1111";
                when 5 =>
                    next_digit <= 0;
                    bin <= sig_bcd(23 downto 20);
                    anodes <= b"1011_1111";
                when others => --for initialization
                    next_digit <= 0;
            end case;

      end if;    
    end process multiplex;

end Behavioral;
