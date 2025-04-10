library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Entity Declaration
entity binary_to_bcd is
    Port (
        binary_in : in STD_LOGIC_VECTOR(8 downto 0); -- 8-bit binary input
        bcd_out   : out STD_LOGIC_VECTOR(15 downto 0) -- 12-bit BCD output (3 decimal digits)
    );
end binary_to_bcd;

-- Architecture Declaration
architecture Behavioral of binary_to_bcd is
begin
    process(binary_in)
        -- Internal variables for binary and BCD manipulation
        variable binary_value : unsigned(8 downto 0);
        variable bcd_value    : unsigned(15 downto 0);  -- 12 bits for 3 BCD digits
        variable i            : integer;
    begin
        -- Initialize binary and BCD variables
        binary_value := unsigned(binary_in);
        bcd_value := (others => '0'); -- Initialize the BCD output to 0

        -- Double Dabble Algorithm
        for i in 0 to 8 loop
            -- If the most significant digit of BCD is greater than 4, add 3
            if bcd_value(15 downto 12) > "0100" then
                bcd_value(15 downto 12) := bcd_value(12 downto 5) + "0011";
            end if;
            
            if bcd_value(11 downto 8) > "0100" then
                bcd_value(11 downto 8) := bcd_value(11 downto 8) + "0011";
            end if;

            -- If the middle BCD digit is greater than 4, add 3
            if bcd_value(7 downto 4) > "0100" then
                bcd_value(7 downto 4) := bcd_value(7 downto 4) + "0011";
            end if;

            -- If the least significant BCD digit is greater than 4, add 3
            if bcd_value(3 downto 0) > "0100" then
                bcd_value(3 downto 0) := bcd_value(3 downto 0) + "0011";
            end if;

            -- Shift the binary value left and add the current binary bit to the BCD
            bcd_value := bcd_value(14 downto 0) & binary_value(8); -- Shift left
            binary_value := binary_value(7 downto 0) & '0';        -- Shift binary left
        end loop;

        -- Assign the final BCD value to the output
        bcd_out <= std_logic_vector(bcd_value);
    end process;
end Behavioral;