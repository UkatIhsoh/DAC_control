--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:11:01 06/22/2020
-- Design Name:   
-- Module Name:   E:/hoshino_Data/SotsuKen/ISE/DAC_control/MCP4726_test.vhd
-- Project Name:  DAC_control
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: MCP4726_ctrl
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE ieee.numeric_std.ALL;
 
ENTITY MCP4726_test IS
END MCP4726_test;
 
ARCHITECTURE behavior OF MCP4726_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT MCP4726_ctrl
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         switch : IN  std_logic;
			trigger : out std_logic;
         scl : OUT  std_logic;
         sda : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal switch : std_logic := '0';

 	--Outputs
	signal trigger : std_logic;
   signal scl : std_logic;
   signal sda : std_logic;

   -- Clock period definitions
   constant clk_period : time := 1 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: MCP4726_ctrl PORT MAP (
          clk => clk,
          rst => rst,
          switch => switch,
			 trigger => trigger,
          scl => scl,
          sda => sda
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	
		rst <= '1';
      wait for clk_period*10;
		rst <= '0';
      -- insert stimulus here
		wait for clk_period*10;
		switch <= '1';
		wait for clk_period;
		switch <= '0';     

		wait;
   end process;

END;
