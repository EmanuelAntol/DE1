library ieee;
use ieee.std_logic_1164.all;

entity tb_Sensor_readv2 is
end tb_Sensor_readv2;

architecture tb of tb_Sensor_readv2 is

    component Sensor_readv2
        generic(
            MIN_ERR_DISTANCE : integer := 5;
            MAX_ERR_DISTANCE : integer := 400);
        
        port (clk       : in std_logic;
              echo      : in std_logic;
              oob_error : out std_logic;
              distance  : out std_logic_vector (8 downto 0));
    end component;

    signal clk       : std_logic;
    signal echo      : std_logic;
    signal oob_error : std_logic;
    signal distance  : std_logic_vector (8 downto 0);

    constant C_MIN_ERR_DISTANCE : integer := 5;
    constant C_MAX_ERR_DISTANCE : integer := 400;
    constant TbPeriod : time := 10 ns; -- ***EDIT*** Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : Sensor_readv2
    generic map(
    MIN_ERR_DISTANCE => C_MIN_ERR_DISTANCE,
    MAX_ERR_DISTANCE => C_MAX_ERR_DISTANCE
    )

    
    port map (clk       => clk,
              echo      => echo,
              oob_error => oob_error,
              distance  => distance);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- ***EDIT*** Check that clk is really your main clock signal
    clk <= TbClock;

    stimuli : process
    begin
        -- ***EDIT*** Adapt initialization as needed
        echo <= '0';
        wait for 1 ms;
        
        echo <= '1';
        wait for 5.827 ms;
        echo <= '0';

        wait for 1 ms;

        -- Simulate echo for 3 cm (should trigger oob_error low bound)
        echo <= '1';
        wait for 0.175 ms; -- 3 * 5827 * 10ns = 174810 ns
        echo <= '0';

        wait for 1 ms;

        -- Simulate echo for 450 cm (should trigger oob_error high bound)
        echo <= '1';
        wait for 26.2215 ms; -- 450 * 5827 * 10ns
        echo <= '0';

        wait for 5 ms;

        -- ***EDIT*** Add stimuli here
        wait for 100 * TbPeriod;

        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;

-- Configuration block below is required by some simulators. Usually no need to edit.

configuration cfg_tb_Sensor_readv2 of tb_Sensor_readv2 is
    for tb
    end for;
end cfg_tb_Sensor_readv2;