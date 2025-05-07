library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity pulse_enable is
	Port (enable	: in STD_LOGIC;
	      trigger	: out STD_LOGIC := '0';
	      clk	: in std_logic
	);
end pulse_enable;

architecture Behavioral of pulse_enable is
	SIGNAL sig_counter : integer range 0 to 100_000;
	SIGNAL start_pulse : std_logic;
	
begin
	pulse : process(clk) is
	begin
		if (enable = '1') then
			start_pulse <= '1';
		end if;

		if (rising_edge(clk)) then
          		if (start_pulse = '1') then 		-- Pulse generation starts
            			if (sig_counter = 1500) then 	-- The pulse is being generated until the internal counter reaches 1500 which means 15us pulse
					trigger <= '0'; 	-- Set output value to zero
					start_pulse <= '0'; 	-- Stop generating the pulse
					sig_counter <= 0; 	-- Reset internal counter value back to zero
				else
					trigger <= '1'; 	-- Output value is set to 1 while generating the pulse
					sig_counter <= sig_counter + 1;
				end if;
			end if;
		end if;
	end process;
end Behavioral;
