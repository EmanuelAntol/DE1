library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_level is
    port (
		CLK100MHZ : in STD_LOGIC;
		BTNC      : in STD_LOGIC;
		CA        : out STD_LOGIC; 
		CB        : out STD_LOGIC;
		CC        : out STD_LOGIC;
		CD        : out STD_LOGIC;
		CE        : out STD_LOGIC;
		CF        : out STD_LOGIC;
		CG        : out STD_LOGIC;
		AN        : out STD_LOGIC_VECTOR (7 downto 0);
		DP        : out STD_LOGIC;
		LED16_R   : out STD_LOGIC;
		LED17_R   : out STD_LOGIC;
		JD1       : out STD_LOGIC;
		JD3       : in STD_LOGIC;
		JD2       : out STD_LOGIC;
		JD4       : in STD_LOGIC	
	);
end top_level;

architecture Behavioral of top_level is
    component clock_en
        generic (
			n_periods : integer
		);
		port (
			clk      : in STD_LOGIC;
			pulse    : out STD_LOGIC);
	end component;
	
	component sensor_readv2
        	generic (
        		MIN_ERR_DISTANCE : integer;
        		MAX_ERR_DISTANCE : integer
    			);
    		port (
		        clk		    : in STD_LOGIC;                                 
			    echo		: in STD_LOGIC;
			    oob_error	: out STD_LOGIC;                     
			    distance    : out STD_LOGIC_VECTOR (8 downto 0)             
    			);
	end component;
	
	component pulse_enable				--trig generator
		Port (enable	: in STD_LOGIC;
	      		trigger	: out STD_LOGIC;
	      		clk	: in std_logic
			);
	end component;

	component bcd_mux				-- bcd multiplexor
        generic (
            N_DIGITS : integer;
            N_SIGNALS : integer
        );
		Port (  clk : in STD_LOGIC;
           		hold : in STD_LOGIC;
           		bcd : in STD_LOGIC_VECTOR (23 downto 0);--((N_DIGITS*4)*N_SIGNALS)-1
           		bin : out STD_LOGIC_VECTOR (3 downto 0);
           		anodes : out STD_LOGIC_VECTOR (7 downto 0)
		     );
	end component;
	
	component binary_to_bcd
		port (
		        binary_in : in STD_LOGIC_VECTOR(8 downto 0);
                bcd_out   : out STD_LOGIC_VECTOR(11 downto 0)
		    );
	end component;
	
	component bin2seg
		port (                
		        bin   : in    std_logic_vector(3 downto 0);
		        seg   : out   std_logic_vector(6 downto 0)
		    );
	end component;
	
	--SIGNALS
	SIGNAL clock_signal    : STD_LOGIC;
	SIGNAL clock_signal_echo    : STD_LOGIC;
	SIGNAL clock_signal_display    : STD_LOGIC;
	SIGNAL trigger_pulse   : STD_LOGIC;
	SIGNAL echo_1_distance : STD_LOGIC_VECTOR (8 downto 0);
	SIGNAL echo_2_distance : STD_LOGIC_VECTOR (8 downto 0);
	SIGNAL bcd_out_1       : STD_LOGIC_VECTOR(11 downto 0);
	SIGNAL bcd_out_2       : STD_LOGIC_VECTOR(11 downto 0);
	SIGNAL bcd_in_mux      : STD_LOGIC_VECTOR(23 downto 0);
	SIGNAl binary_out_mux  : STD_LOGIC_VECTOR (3 downto 0);
begin
    clock : clock_en
			generic map (
				n_periods => 500_000
			)
			port map (
				clk     => CLK100MHZ,
				pulse   => clock_signal
			);
			
    clock_display : clock_en
			generic map (
				n_periods => 250_000
			)
			port map (
				clk     => CLK100MHZ,
				pulse   => clock_signal_display
			);
			
	clock_echo : clock_en
			generic map (
				n_periods => 20_000_000
			)
			port map (
				clk     => CLK100MHZ,
				pulse   => clock_signal_echo
			);
			
	--Generator for trigger pulse
	trig_gen : pulse_enable
		port map (
		      enable	=> clock_signal_echo,
		      trigger	=> trigger_pulse,
		      clk	    => CLK100MHZ
			);
			
	--Driver for the first ultrasound sensor
    echo_1 : sensor_readv2
			generic map (
			        MIN_ERR_DISTANCE => 5,
			        MAX_ERR_DISTANCE => 400
			)
			port map (
			    clk	   => CLK100MHZ,
				echo	   => JD3,
				oob_error   => LED17_R,
				distance   => echo_1_distance
			    );
    
	--Driver for the first ultrasound sensor		    
    echo_2 : sensor_readv2
			generic map (
			        MIN_ERR_DISTANCE => 5,
			        MAX_ERR_DISTANCE => 400
			)
			port map (
			    clk	   => CLK100MHZ,
				echo	   => JD4,
				oob_error   => LED16_R,
				distance   => echo_2_distance
			    );
    
    --Convertor from binary to BCD code for the first sensor
    bin2bcd_1 : binary_to_bcd
			port map (
			        binary_in => echo_1_distance,
			        bcd_out   => bcd_out_1
			    );

	--Convertor from binary to BCD code for the second sensor
	bin2bcd_2 : binary_to_bcd
			port map (
			        binary_in => echo_2_distance,
			        bcd_out   => bcd_out_2
			    );
    
    --Merge outputs from binary to BCD convertors to one 24 bit signal for multiplexor
    bcd_in_mux <= bcd_out_1 & bcd_out_2;
    
    --Multiplexor for data
	mux : bcd_mux
		generic map (
            N_DIGITS => 3,                        
			N_SIGNALS => 2                                
	    )
		port map (
			clk    => clock_signal,
			hold   => BTNC,
           	bcd    => bcd_in_mux,
           	bin    => binary_out_mux,
           	anodes => AN
		);
			
	display : bin2seg
        port map (           
			bin    => binary_out_mux,
            seg(6) => CA,
            seg(5) => CB,
            seg(4) => CC,
            seg(3) => CD,
	        seg(2) => CE,
			seg(1) => CF,
			seg(0) => CG
			    );
		DP <= '1'; -- to turn of the decimal point on the 7 segment display
		
		--Trigger signals to ultrasound sensors
		JD1 <= trigger_pulse;
		JD2 <= trigger_pulse;
		--LED16_R <= '0';
		--LED17_R <= '0';
end Behavioral;
