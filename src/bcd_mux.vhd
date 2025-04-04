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
    --    N_DIGITS : integer := 3;
    --    N_SIGNALS : integer := 2;
    --    N_DISPLAYS : integer := 8
    --);
    Port ( clk : in STD_LOGIC;
           hold : in STD_LOGIC;
           bcd : in STD_LOGIC_VECTOR (23 downto 0);--((N_DIGITS*4)*N_SIGNALS)-1
           bin : out STD_LOGIC_VECTOR (3 downto 0);
           anodes : out STD_LOGIC_VECTOR (7 downto 0));--N_DISPLAYS-1
end bcd_mux;

architecture Behavioral of bcd_mux is
    signal sig_bcd : STD_LOGIC_VECTOR (23 downto 0); --(N_DIGITS*4-1)*N_SIGNALS
    signal sig_anodes : STD_LOGIC_VECTOR (7 downto 0); -- choice subtype is not locally staticTerosHDL
begin

    -- Main multiplexer process
    multiplex : process (clk) is
    begin
    
      if rising_edge(clk) then
        -- Hold the value if hold is active
        if hold = '0' then
            sig_bcd <= bcd;
        end if;
    
            -- Multiplex according to previous anode position
            case sig_anodes is --todo unhardcode
                when b"1011_1111" =>
                    sig_anodes <= b"1111_1110";
                    bin <= sig_bcd(3 downto 0);
                when b"1111_1110" =>
                    sig_anodes <= b"1111_1101";
                    bin <= sig_bcd(7 downto 4);
                when b"1111_1101" =>
                    sig_anodes <= b"1111_1011";
                    bin <= sig_bcd(11 downto 8);
                when b"1111_1011" =>
                    sig_anodes <= b"1110_1111";
                    bin <= sig_bcd(15 downto 12);
                when b"1110_1111" =>
                    sig_anodes <= b"1101_1111";
                    bin <= sig_bcd(19 downto 16);
                when b"1101_1111" =>
                    sig_anodes <= b"1011_1111";
                    bin <= sig_bcd(23 downto 20);
                when others => --for initialization
                    sig_anodes <= b"1011_1111";
            end case;

      end if;    
    end process multiplex;

    anodes <= sig_anodes;
end Behavioral;
