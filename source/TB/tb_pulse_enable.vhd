-- Testbench automatically generated online
-- at https://vhdl.lapinoo.net
-- Generation date : Thu, 10 Apr 2025 11:09:29 GMT
-- Request id : cfwk-fed377c2-67f7a6e939797

library ieee;
use ieee.std_logic_1164.all;

entity tb_pulse_enable is
end tb_pulse_enable;

architecture tb of tb_pulse_enable is

    component pulse_enable
        port (enable  : in std_logic;
              trigger : out std_logic;
              clk     : in std_logic);
    end component;

    signal enable  : std_logic;
    signal trigger : std_logic;
    signal clk     : std_logic;

    constant TbPeriod : time := 10 ns; -- ***EDIT*** Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : pulse_enable
    port map (enable  => enable,
              trigger => trigger,
              clk     => clk);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- ***EDIT*** Check that clk is really your main clock signal
    clk <= TbClock;

    stimuli : process
    begin

        enable <= '1';
        wait for 100 ns;
        enable <= '0';
        wait for 4000 ms;

        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;

-- Configuration block below is required by some simulators. Usually no need to edit.

configuration cfg_tb_pulse_enable of tb_pulse_enable is
    for tb
    end for;
end cfg_tb_pulse_enable;