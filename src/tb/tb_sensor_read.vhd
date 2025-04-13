-- Testbench automatically generated online
-- at https://vhdl.lapinoo.net
-- Generation date : Sun, 13 Apr 2025 10:48:10 GMT
-- Request id : cfwk-fed377c2-67fb966adddee

library ieee;
use ieee.std_logic_1164.all;

entity tb_sensor_read is
end tb_sensor_read;

architecture tb of tb_sensor_read is

    component sensor_read
        generic(
        MIN_ERR_DISTANCE : integer := 5;
        MAX_ERR_DISTANCE : integer := 400);
        
        port (clk       : in std_logic;
              trigger   : in std_logic;
              echo      : in std_logic;
              oob_error : out std_logic;
              distance  : out std_logic_vector (8 downto 0));
    end component;

    signal clk       : std_logic;
    signal trigger   : std_logic;
    signal echo      : std_logic;
    signal oob_error : std_logic;
    signal distance  : std_logic_vector (8 downto 0);

    constant C_MIN_ERR_DISTANCE : integer := 5;
    constant C_MAX_ERR_DISTANCE : integer := 400;
    constant TbPeriod : time := 10 ns; -- ***EDIT*** Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : sensor_read
    generic map(
    MIN_ERR_DISTANCE => C_MIN_ERR_DISTANCE,
    MAX_ERR_DISTANCE => C_MAX_ERR_DISTANCE
    )
    port map (clk       => clk,
              trigger   => trigger,
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
        trigger <= '0';
        echo <= '0';
        wait for 20ns ;
        trigger <= '1';
        wait for 15us ;
        trigger <= '0';
        wait for 15us ;
        echo <= '1';
        wait for 10ms ;
        echo <= '0';
        wait for 20ms ;
        wait for 100 * TbPeriod;

        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;

-- Configuration block below is required by some simulators. Usually no need to edit.

configuration cfg_tb_sensor_read of tb_sensor_read is
    for tb
    end for;
end cfg_tb_sensor_read;