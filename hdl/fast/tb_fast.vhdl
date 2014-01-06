--
-- Copyright (C) 2013 Martin Åberg
--
--  This program is free software: you can redistribute it
--  and/or modify it under the terms of the GNU General Public
--  License as published by the Free Software Foundation,
--  either version 3 of the License, or (at your option)
--  any later version.
--
--  This program is distributed in the hope that it will
--  be useful, but WITHOUT ANY WARRANTY; without even the
--  implied warranty of MERCHANTABILITY or FITNESS FOR A
--  PARTICULAR PURPOSE.  See the GNU General Public License
--  for more details.
--
--  You should have received a copy of the GNU General
--  Public License along with this program.  If not, see
--  <http://www.gnu.org/licenses/>.
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.greta_pkg.all;

entity tb_fast is
end;

architecture testbench of tb_fast is
  --- GRETA
  signal clk            : std_logic := '1';
  signal reset          : std_logic;

  signal req            : std_logic;
  signal nwe            : bus_nwe;
  signal dev_select     : std_logic;
  signal addr           : bus_addr;
  signal wdata          : bus_data;
  signal rdata          : bus_data;
  signal config_in      : std_logic := '0';
  signal config_out     : std_logic;

  signal ram            : ram_bus;
  signal ram_nwe        : bus_nwe;
  signal ram_ack        : std_logic := '1';
  signal ram_rdata      : bus_data := x"1234";
  signal end_of_simulation : boolean := false;

  constant CLK_PERIOD : Delay_length := 7.5 ns;
begin

  dut : entity work.fast port map(
    clk             => clk,
    reset           => reset,
    --- GRETA
    req             => req,
    nwe             => nwe,
    dev_select      => dev_select,
    addr            => addr,
    wdata           => wdata,
    rdata           => rdata,
    config_in       => config_in,
    config_out      => config_out,
    --- RAM controller
    ram             => ram,
    ram_ack         => ram_ack,
    ram_rdata       => ram_rdata
  );

  process
  begin
    if end_of_simulation = false then
      clk <= not clk;
      wait for CLK_PERIOD / 2.0;
    else
      wait;
    end if;
  end process;

  process
    -- These procedures simulate the behavior of bus_interface.
    procedure dev_reset is
    begin
      reset <= '1';
      req <= '0';
      nwe <= READ_WORD;
      wait for CLK_PERIOD * 7;
      wait until rising_edge(clk);
      reset <= '0';
    end;

    procedure dev_write(
      constant a      : in    bus_addr24;
      constant d      : in    std_logic_vector
    ) is
    begin
      wait until rising_edge(clk);
      addr <= a(addr'range);
      wait for CLK_PERIOD * 7;
      wait until rising_edge(clk);

      if d'length = 8 and a(0) = '0' then
        wdata <= d & "UUUUUUUU";
        nwe <= WRITE_UPPER;
      elsif d'length = 8 and a(0) = '1' then
        wdata <= "UUUUUUUU" & d;
        nwe <= WRITE_LOWER;
      elsif d'length = 16 then
        assert a(0) = '0'
          report "dev_write: Illegal address alignment for word " &
           "write."
          severity failure;
        wdata <= d;
        nwe <= WRITE_WORD;
      else
        report "dev_write: Illegal data width. Only byte and " &
         "word access supported."
          severity failure;
      end if;

      wait for CLK_PERIOD * 3;
      wait until rising_edge(clk);
      req <= '1';
      wait until rising_edge(clk);
      req <= '0';
      wait until rising_edge(clk);
      wait until rising_edge(clk);
    end;

    procedure dev_read(
      constant a        : in    bus_addr24;
      variable rd       : out   std_logic_vector;
      variable selected : out   boolean
    ) is
    begin
      wait until rising_edge(clk);
      addr <= a(addr'range);
      wait for CLK_PERIOD * 3;
      wait until rising_edge(clk);
      if rd'length = 8 then
        nwe <= READ_WORD;
      elsif rd'length = 16 then
        assert a(0) = '0'
          report "dev_read: Illegal address alignment for word " &
           "read."
          severity failure;
        nwe <= READ_WORD;
      else
        report "dev_read: Illegal data width. Only byte and " &
         " word supported."
          severity failure;
      end if;
      wait until rising_edge(clk);
      req <= '1';
      wait until rising_edge(clk);
      req <= '0';
      wait for CLK_PERIOD * 7;
      wait until rising_edge(clk);
      if dev_select = '1' then
        selected := true;
      else
        selected := false;
      end if;
      wait until rising_edge(clk);

      if rd'length = 8 and a(0) = '0' then
        rd := rdata(15 downto 8);
      elsif rd'length = 8 and a(0) = '1' then
        rd := rdata(7 downto 0);
      else
        rd := rdata;
      end if;
      wait until rising_edge(clk);
    end;

    -- Asserts that reads from the the memory area from a to b
    -- are silent. That is they hold both dev_select and rdata
    -- to zero.
    procedure dev_assert_silent(
      constant a        : in    integer;
      constant b        : in    integer
    ) is
      variable d        : bus_data;
      variable s        : boolean;
    begin
      for i in a to b loop
        if i mod 2 = 0 then
          dev_read(std_logic_vector(to_unsigned(i, 24)), d, s);
          assert s = false;
          assert d = x"0000";
        end if;
      end loop;
    end;

    procedure verify_rom is
      variable d16      : bus_data;
      variable s        : boolean;
    begin
      -- Actual AUTOCONFIG0 area. Compare with ROM here!
      dev_read(std_logic_vector(to_unsigned(16#E80000#, 24)), d16, s);
      assert d16(15 downto 12) = "1110";
      assert s = true;
  
      dev_read(std_logic_vector(to_unsigned(16#E80002#, 24)), d16, s);
      assert d16(15 downto 12) = "1000";
      assert s = true;
  
      dev_read(std_logic_vector(to_unsigned(16#E80004#, 24)), d16, s);
      assert d16(15 downto 12) = "1111";
      assert s = true;
  
      dev_read(std_logic_vector(to_unsigned(16#E80006#, 24)), d16, s);
      assert d16(15 downto 12) = "1110";
      assert s = true;
  
      for i in 16#E80008# to 16#E8000E# loop
        if i mod 2 = 0 then
          dev_read(std_logic_vector(to_unsigned(i, 24)), d16, s);
          assert d16(15 downto 12) = "1111";
          assert s = true;
        end if;
      end loop;
  
      dev_read(std_logic_vector(to_unsigned(16#E80010#, 24)), d16, s);
      assert d16(15 downto 12) = not HACKER_MANUFACTURER(15 downto 12);
      assert s = true;
  
      dev_read(std_logic_vector(to_unsigned(16#E80012#, 24)), d16, s);
      assert d16(15 downto 12) = not HACKER_MANUFACTURER(11 downto  8);
      assert s = true;
  
      dev_read(std_logic_vector(to_unsigned(16#E80014#, 24)), d16, s);
      assert d16(15 downto 12) = not HACKER_MANUFACTURER( 7 downto  4);
      assert s = true;
  
      dev_read(std_logic_vector(to_unsigned(16#E80016#, 24)), d16, s);
      assert d16(15 downto 12) = not HACKER_MANUFACTURER( 3 downto  0);
      assert s = true;
  
      for i in 16#E80018# to 16#E8003E# loop
        if i mod 2 = 0 then
          dev_read(std_logic_vector(to_unsigned(i, 24)), d16, s);
          assert d16(15 downto 12) = "1111";
          assert s = true;
        end if;
      end loop;
  
      dev_read(std_logic_vector(to_unsigned(16#E80040#, 24)), d16, s);
      assert d16(15 downto 12) = "0000";
      assert s = true;
  
      dev_read(std_logic_vector(to_unsigned(16#E80042#, 24)), d16, s);
      assert d16(15 downto 12) = "0000";
      assert s = true;
  
      for i in 16#E80044# to 16#E8007E# loop
        if i mod 2 = 0 then
          dev_read(std_logic_vector(to_unsigned(i, 24)), d16, s);
          assert d16(15 downto 12) = "1111";
          assert s = true;
        end if;
      end loop;
    end;

    procedure assert_fast_ram_silent is
    begin
      -- Test borders of the three areas in 8MB space.
      dev_assert_silent(16#1FFFF0#, 16#200010#);
      dev_assert_silent(16#3FFFF0#, 16#400010#);
      dev_assert_silent(16#7FFFF0#, 16#800010#);
      dev_assert_silent(16#9FFFF0#, 16#A00010#);
    end;

    procedure assert_rom_silent is
    begin
      -- AUTOCONFIG SPACE
      dev_assert_silent(16#E7FFF0#, 16#E80010#);
      dev_assert_silent(16#E8FFF0#, 16#E90010#);
    end;

    procedure assert_all_silent is
    begin
      assert_fast_ram_silent;
      assert_rom_silent;
    end;

    variable d16  : bus_data;
    variable d8   : bus_data8;
    variable s    : boolean;
  begin
    dev_reset;
    -- Assure that DUT doesn't set dev_select when unconfigured.
    assert_all_silent;

    config_in <= '1';
    -- Evaluate the UNCONFIGURED state when selected for configuraton.
    -- Area before AUTOCONFIG0
    dev_assert_silent(16#E7FFF0#, 16#E7FFFF#);

    -- Area after AUTOCONFIG0
    dev_assert_silent(16#E90000#, 16#E90010#);

    -- Test borders of the three areas in 8MB space.
    dev_assert_silent(16#1FFFF0#, 16#200010#);
    dev_assert_silent(16#3FFFF0#, 16#400010#);
    dev_assert_silent(16#7FFFF0#, 16#800010#);
    dev_assert_silent(16#9FFFF0#, 16#A00010#);

    verify_rom;

    -- Tell the device to shut up.
    assert config_out = '0';
    dev_write(x"E8004C", x"abcd");
    assert config_out = '1';
    -- Verify that it did.
    assert_all_silent;

    -- Configure device.
    config_in <= '1';
    dev_reset;
    assert config_out = '0';
    dev_write(x"E80048", x"abcd");
    assert config_out = '1';
    assert_rom_silent;

    dev_read(std_logic_vector(to_unsigned(16#200000#, 24)), d16, s);
    end_of_simulation <= true;
    wait;
  end process;

  -- Ensure that rdata is zero whenever we are not selected.
  process
  begin
    wait until rising_edge(clk);
    if reset = '0' and dev_select = '0' then
      assert rdata = x"0000";
    end if;
  end process;
end;

