library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity pulse_enable is
	Port (enable	: in STD_LOGIC;
	      trigger	: out STD_LOGIC := 0;
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
          		if (start_pulse = '1') then 		-- zacne se generovat pulz pozadovane sirky
            			if (sig_counter = 1500) then 	-- dokud neni counter 1500 coz znamena sirku pulzu 15 ns
					trigger <= '0'; 	-- vynulovani vystupu
					start_pulse <= '0'; 	-- ukonceni generovani
					sig_counter <= 0; 	-- vynulovani counteru
				else
					trigger <= '1'; 	-- vystup na 1
					sig_counter <= sig_counter + 1;
				end if;
			end if;
		end if;
	end process;
end Behavioral;
