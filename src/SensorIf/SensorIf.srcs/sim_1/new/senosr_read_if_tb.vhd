library ieee;
use ieee.std_logic_1164.all;

entity tb_sensor_read_if is
end tb_sensor_read_if;

architecture tb of tb_sensor_read_if is

    component sensor_read_if
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

    dut : sensor_read_if
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
        echo <= '0';
        wait for 15us ;
        echo <= '1';
        wait for 10ms ;
        echo <= '0';
        wait for 20ms ;

        wait for 15us ;
        echo <= '1';
        wait for 200us ;
        echo <= '0';
        wait for 20ms ;
        
         wait for 15us ;
        echo <= '1';
        wait for 800us ;
        echo <= '0';
        wait for 20ms ;



        wait for 100 * TbPeriod;

        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;

-- Configuration block below is required by some simulators. Usually no need to edit.

configuration cfg_tb_sensor_read_if of tb_sensor_read_if is
    for tb
    end for;
end cfg_tb_sensor_read_if;