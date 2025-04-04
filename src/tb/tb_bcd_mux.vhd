-- Testbench automatically generated online
-- at https://vhdl.lapinoo.net
-- Generation date : Fri, 04 Apr 2025 11:35:20 GMT
-- Request id : cfwk-fed377c2-67efc3f8d9823

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_bcd_mux is
end tb_bcd_mux;

architecture tb of tb_bcd_mux is

    component bcd_mux
        --generic (
        --    N_DIGITS : integer := 3;
        --    N_SIGNALS : integer := 2;
        --    N_DISPLAYS : integer := 8
        --);
        port (clk         : in std_logic;
              hold        : in std_logic;
              bcd         : in std_logic_vector (23 downto 0); --N_DIGITS*4*N_SIGNALS-1
              bin         : out std_logic_vector (3 downto 0);
              anodes      : out std_logic_vector (7 downto 0)); --N_DISPLAYS-1
    end component;

    signal clk         : std_logic;
    signal hold        : std_logic;
    constant C_NDIGITS : integer := 3;
    constant C_NSIGNALS : integer := 2;
    signal bcd         : std_logic_vector (C_NDIGITS*4*C_NSIGNALS-1 downto 0);
    signal bin         : std_logic_vector (3 downto 0);
    constant C_NDISPLAYS : integer := 8;
    signal anodes      : std_logic_vector (C_NDISPLAYS-1 downto 0);

    constant TbPeriod : time := 10 ns; -- ***EDIT*** Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : bcd_mux
    --generic map (
    --    N_DIGITS => C_NDIGITS,
    --    N_SIGNALS => C_NSIGNALS,
    --    N_DISPLAYS => C_NDISPLAYS
    --)
    port map (clk         => clk,
              hold        => hold,
              bcd         => bcd,
              bin         => bin,
              anodes      => anodes);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- ***EDIT*** Check that clk is really your main clock signal
    clk <= TbClock;

    stimuli : process
    begin
        -- ***EDIT*** Adapt initialization as needed
        hold <= '0';

        bcd <= b"1000_1001_1010_1100_1101_1110";
        --bcd <= x"8"&x"9"&x"a"&x"c"&x"d"&x"e";
        wait for 6 * TbPeriod;

        bcd <= x"a"&x"4"&x"0"&x"4"&x"5"&x"9";
        wait for 6 * TbPeriod;

        hold <= '1';
        wait for 2 * TbPeriod;

        bcd <= x"c"&x"b"&x"a"&x"d"&x"f"&x"f";
        wait for 6 * TbPeriod;

        hold <= '0';
        wait for 2 * TbPeriod;

        bcd <= x"9"&x"8"&x"7"&x"6"&x"5"&x"4";
        wait for 6 * TbPeriod;

        -- ***EDIT*** Add stimuli here
        --wait for 100 * TbPeriod;

        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;

-- Configuration block below is required by some simulators. Usually no need to edit.

configuration cfg_tb_bcd_mux of tb_bcd_mux is
    for tb
    end for;
end cfg_tb_bcd_mux;