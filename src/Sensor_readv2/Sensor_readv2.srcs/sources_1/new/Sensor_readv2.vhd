library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Sensor_readv2 is
    generic (
        MIN_ERR_DISTANCE : integer := 5;
        MAX_ERR_DISTANCE : integer := 400
    );
    port (
        clk		    : in STD_LOGIC;                                        -- 100MHZ board clock input                       
		echo		: in STD_LOGIC;                                        -- Input signal from the sensors (peak width measurement)
		oob_error	: out STD_LOGIC;                                -- Indicator for when the measured distance is too short or too long (set the bounds in MIN/MAX_ERR_DISTANCE generic varibles)
		distance	: out STD_LOGIC_VECTOR (8 downto 0)     -- Hardware distance limit is ~2-400cm => 9 bit output is needed
    );

end Sensor_readv2;

architecture Behavioral of Sensor_readv2 is
    constant CM : integer := 5827;                                  -- Number of clock pulses from 100MHz signal need for sound wave to travel 1cm
    constant DEBOUNCE_THRESHOLD : integer := 10;                    -- Debounce time in clock cycles
    signal counter : integer range 0 to CM + 10;                     -- Internal clock counter
    signal tmp_dst_out : integer range 0 to 450;                    -- Temporary distance signal
    signal echo_sync     : std_logic := '0';                        -- Synchronized echo
    signal echo_stable   : std_logic := '0';                        -- Debounced echo
    signal echo_last     : std_logic := '0';                        -- Previous state
    signal debounce_cnt  : integer range 0 to DEBOUNCE_THRESHOLD + 1 := 0;  -- Debounce counter
    type state_type is (IDLE, COUNTING, WRITE);    
    signal current_state : state_type := IDLE;             -- Defining the FSM state tracker variable and possible states
    

begin

    debounce_process : process(clk)
        begin
            if rising_edge(clk) then
                echo_sync <= echo;  
        
                if echo_sync = echo_last then
                    if debounce_cnt < DEBOUNCE_THRESHOLD then
                        debounce_cnt <= debounce_cnt + 1;
                    end if;
                else
                    debounce_cnt <= 0;
                end if;
        
                if debounce_cnt = DEBOUNCE_THRESHOLD then
                    echo_stable <= echo_sync;
                end if;
        
                echo_last <= echo_sync;
            end if;
    end process;
    
    
    read_sens : process (clk) is         
        begin 
        
        if rising_edge(clk) then
            case current_state is                              -- FSM process
                when IDLE =>                                   -- "IDLE" state resets the temporary distance, counter signal and waits until the sensor echo signal is HIGH
                    counter  <= 0;
                    tmp_dst_out <= 0;
                    if (echo_stable = '1') then
                        current_state <= COUNTING;
                    end if;
                
                    
                when COUNTING =>
                    if (echo_stable = '1' and counter = CM) then      -- when the amount of clock high signals ("counter") reaches a number coresponding to 1cm of lenght,
                        tmp_dst_out <= tmp_dst_out + 1;        -- the "counter" is reset and distance counter incremented by 1 ("tmp_dst_out")
                        counter <= 0;
                    else    
                        counter <= counter + 1;
                    end if;
                                                               -- "COUNTING" state counts the number of clock high signals that the "echo" is HIGH
                    if (echo_stable = '0' or tmp_dst_out > 400) then                       -- if "echo" drops to LOW, the counting stops
                        current_state <= WRITE;
                    end if;
                    
                    
                        
                when WRITE =>                                  -- "WRITE" state sets the "distance" component output to the measured "tmp_dst_out" value 
                    distance <= std_logic_vector(to_unsigned(tmp_dst_out, 9));
                                                               -- if the measured value is lower or higher than the customized limits, the "oob_error" is set to HIGH
                    if (tmp_dst_out < MIN_ERR_DISTANCE or tmp_dst_out > MAX_ERR_DISTANCE) then
                        oob_error <= '1';
                    else
                        oob_error <= '0';
                    end if;
                    
                    if (echo_stable = '0') then                    
                        current_state <= IDLE;
                    end if;

               
                
            end case;
        end if;       
    end process read_sens;


end Behavioral;
