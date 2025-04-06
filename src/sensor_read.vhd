library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity sensor_read is
    generic (
        MIN_ERR_DISTANCE : integer := 5;
        MAX_ERR_DISTANCE : integer := 400
    );
    port (
        clk		: in STD_LOGIC;                        -- 100MHZ board clock input
        trigger		: in STD_LOGIC;                        -- Trigger pulse (same as the sensor input)
	echo		: in STD_LOGIC;                        -- Input signal from the sensors (peak width measurement)
	oob_error	: out STD_LOGIC;                       -- Indicator for when the measured distance is too short or too long (set the bounds in MIN/MAX_ERR_DISTANCE generic varibles)
	distance	: out STD_LOGIC_VECTOR (8 downto 0)    -- Hardware distance limit is ~2-400cm => 9 bit output is needed
    );
end sensor_read;

architecture Behavioral of sensor_read is
    
    constant CM : integer := 5827;                         -- Number of clock pulses from 100MHz signal need for sound wave to travel 1cm
    signal counter : integer range 0 to CM + 1;            -- Internal clock counter
    signal tmp_dst_out : integer range 0 to 401;           -- Temporary distance signal
    type state_type is (IDLE, WAITING, COUNTING, WRITE);    
    signal current_state : state_type := IDLE;             -- Defining the FSM state tracker variable and possible states
    
begin

    read_sens : process (clk) is         
        begin 
        
        case current_state is                              -- FSM process
            when IDLE =>                                   -- "IDLE" state resets the temporary distance, counter signal and waits until the sensor trigger signal is HIGH
                counter  <= 0;
                tmp_dst_out <= 0;
                if (trigger = '1') then
                    current_state <= WAITING;
                end if;
            
            when WAITING =>                                -- when in "WAITING" state, the sound wave has been sent, and the machine waits until "echo" is HIGH
                if (echo = '1') then
                    current_state <= COUNTING;
                end if;
                
            when COUNTING =>                               -- "COUNTING" state counts the number of clock high signals that the "echo" is HIGH
                if (echo = '0' or tmp_dst_out = 401) then  -- if "echo" drops to LOW or the calculated distance is higher than hardware limit, the counting stops
                    current_state <= WRITE;
                end if;
                
                if (echo = '1' and counter = CM) then      -- when the amount of clock high signals ("counter") reaches a number coresponding to 1cm of lenght,
                    tmp_dst_out <= tmp_dst_out + 1;        -- the "counter" is reset and distance counter incremented by 1 ("tmp_dst_out")
                    counter <= 0;
                else 
                    counter <= counter + 1;
                end if;
                
            when WRITE =>                                  -- "WRITE" state sets the "distance" component output to the measured "tmp_dst_out" value 
                distance <= std_logic_vector(to_unsigned(tmp_dst_out, 9));
                                                           -- if the measured value is lower or higher than the customized limits, the "oob_error" is set to HIGH
                if (tmp_dst_out < MIN_ERR_DISTANCE or tmp_dst_out > MAX_ERR_DISTANCE) then
                    oob_error <= '1';
                else
                    oob_error <= '0';
                end if;
                
                current_state <= IDLE;
                
        end case;
    end process read_sens;
    
end Behavioral;
