library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sensor_read_if is
    generic (
        MIN_ERR_DISTANCE : integer := 5;
        MAX_ERR_DISTANCE : integer := 400
    );
    port (
        clk		    : in STD_LOGIC;                        -- 100MHZ board clock input 
		echo		: in STD_LOGIC;                        -- Input signal from the sensors (peak width measurement)
		oob_error	: out STD_LOGIC;                       -- Indicator for when the measured distance is too short or too long (set the bounds in MIN/MAX_ERR_DISTANCE generic varibles)
		distance	: out STD_LOGIC_VECTOR (8 downto 0)    -- Hardware distance limit is ~2-400cm => 9 bit output is needed
    );

end sensor_read_if;

architecture Behavioral of sensor_read_if is

    
    constant CM : integer := 2914;                         -- Number of clock pulses from 100MHz signal need for sound wave to travel 1cm
    signal counter : integer range 0 to CM + 1;            -- Internal clock counter
    signal tmp_dst_out : integer range 0 to 401;           -- Temporary distance signal
    signal echoBuffer : STD_LOGIC := '0';
    
begin

    sensor_read : process (clk) is         
        begin 
        
        if (echo = '1' and echoBuffer = '0') then
			echoBuffer <= '1';
            tmp_dst_out <= 0;
            counter <= 0; 
        end if;

        if rising_edge(clk) then

            if (echo = '1' and echoBuffer = '1') then     
                if (counter = CM) then
                    tmp_dst_out <= tmp_dst_out + 1;
                    counter <= 0;
                else
                    counter <= counter + 1;
                end if;
                
            elsif (echo = '0' and echoBuffer = '1') then   
                echoBuffer <= '0';
                distance <= std_logic_vector(to_unsigned(tmp_dst_out, 9));
                if (tmp_dst_out < MIN_ERR_DISTANCE or tmp_dst_out > MAX_ERR_DISTANCE) then
                    oob_error <= '1';
                else
                    oob_error <= '0';
                end if;
                
            else
                distance <= std_logic_vector(to_unsigned(tmp_dst_out, 9));
                if (tmp_dst_out < MIN_ERR_DISTANCE or tmp_dst_out > MAX_ERR_DISTANCE) then
                    oob_error <= '1';
                else
                    oob_error <= '0';
                end if;
            end if;
        end if;
        
    end process sensor_read;
    


end Behavioral;
