----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:44:46 12/03/2018 
-- Design Name: 
-- Module Name:    MCP4706 - MCP4706 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;
use IEEE.STD_LOGIC_arith.ALL;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MCP4706 is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           clk_out : out  STD_LOGIC;
           data : out  STD_LOGIC);
end MCP4706;

architecture MCP4706 of MCP4706 is

signal clk_div : std_logic;
signal clk_count : std_logic_vector(2 downto 0);
signal clk_stt : std_logic;
signal dat_pas : std_logic;
signal dat_stt : std_logic_vector(6 downto 0);

begin

process(clk,rst)
begin
	if(rst = '0')then
		clk_count <= "000";
		clk_div <= '0';
		clk_stt <= '0';
	elsif(rising_edge(clk))then
		if(clk_stt = '0')then
			if(clk_count = "011")then
				clk_count <= "000";
				clk_div <= '0';
				clk_stt <= '1';
			else
				clk_count <= clk_count +1;
				clk_div <= '1';
				clk_stt <= clk_stt;
			end if;
		elsif(clk_stt = '1')then
			if(clk_count = "011")then
				clk_count <= "000";
				clk_div <= '1';
				clk_stt <= '0';
			else
				clk_count <= clk_count +1;
				clk_div <= '0';
				clk_stt <= clk_stt;
			end if;
		end if;
	elsif(falling_edge(clk))then
		if(clk_stt = '0')then
			if(clk_count = "011")then
				clk_count <= "000";
				clk_div <= '0';
				clk_stt <= '1';
			else
				clk_count <= clk_count +1;
				clk_div <= '1';
				clk_stt <= clk_stt;
			end if;
		elsif(clk_stt = '1')then
			if(clk_count = "011")then
				clk_count <= "000";
				clk_div <= '1';
				clk_stt <= '0';
			else
				clk_count <= clk_count +1;
				clk_div <= '0';
				clk_stt <= clk_stt;
			end if;
		end if;	
	end if;	
end process;
	
process(clk_div,rst)
begin
	if(rst = '0')then
		dat_pas <= '0';
		dat_stt <= (others=>'0');
	elsif(clk_div'event and clk_div='1')then
		if(dat_stt = "0000000")then
			dat_pas <= '1';
			dat_stt <= dat_stt +1;
		elsif(dat_stt = "0000001")then
			dat_pas <= '1';
			dat_stt <= dat_stt +1;
		elsif(dat_stt = "0000010")then
			dat_pas <= '0';
			dat_stt <= dat_stt +1;
		elsif(dat_stt = "0000011")then --start
			dat_pas <= '0';
			dat_stt <= dat_stt +1;
		elsif(dat_stt = "0000100")then --1
			dat_pas <= '1';
			dat_stt <= dat_stt +1;
		elsif(dat_stt = "0000101")then --1
			dat_pas <= '1';
			dat_stt <= dat_stt +1;
		elsif(dat_stt = "0000110")then --0
			dat_pas <= '0';
			dat_stt <= dat_stt +1;
		elsif(dat_stt = "0000111")then --0
			dat_pas <= '0';
			dat_stt <= dat_stt +1;
		elsif(dat_stt = "0001000")then --0
			dat_pas <= '0';
			dat_stt <= dat_stt +1;
		elsif(dat_stt = "0001001")then --0
			dat_pas <= '0';
			dat_stt <= dat_stt +1;
		elsif(dat_stt = "0001010")then --0
			dat_pas <= '0';
			dat_stt <= dat_stt +1;
		elsif(dat_stt = "0001011")then --0
			dat_pas <= '0';
			dat_stt <= dat_stt +1;
		elsif(dat_stt = "0001100")then --0
			dat_pas <= '0';
			dat_stt <= dat_stt +1;
		elsif(dat_stt = "0001101")then --0
			dat_pas <= '0';
			dat_stt <= dat_stt +1;
		elsif(dat_stt = "0001110")then --1
			dat_pas <= '1';
			dat_stt <= dat_stt +1;
		elsif(dat_stt = "0001111")then --1
			dat_pas <= '1';
			dat_stt <= dat_stt +1;
		elsif(dat_stt = "0010000")then --0
			dat_pas <= '0';
			dat_stt <= dat_stt +1;
		elsif(dat_stt = "0010001")then --X
			dat_pas <= '0';
			dat_stt <= dat_stt +1;
		elsif(dat_stt = "0010010")then --0
			dat_pas <= '0';
			dat_stt <= dat_stt +1;
		elsif(dat_stt = "0010011")then --0
			dat_pas <= '0';
			dat_stt <= dat_stt +1;
		elsif(dat_stt = "0010100")then --0
			dat_pas <= '0';
			dat_stt <= dat_stt +1;
		elsif(dat_stt = "0010101")then --1
			dat_pas <= '1';
			dat_stt <= dat_stt +1;
		elsif(dat_stt = "0010110")then --1
			dat_pas <= '1';
			dat_stt <= dat_stt +1;
		elsif(dat_stt = "0010111")then --1
			dat_pas <= '1';
			dat_stt <= dat_stt +1;
		elsif(dat_stt = "0011000")then --1
			dat_pas <= '1';
			dat_stt <= dat_stt +1;
		elsif(dat_stt = "0011001")then --1
			dat_pas <= '1';
			dat_stt <= dat_stt +1;
		elsif(dat_stt = "0011010")then --1
			dat_pas <= '1';
			dat_stt <= dat_stt +1;
		elsif(dat_stt = "0011011")then --1
			dat_pas <= '1';
			dat_stt <= dat_stt +1;
		elsif(dat_stt = "0011100")then --1
			dat_pas <= '1';
			dat_stt <= dat_stt +1;
		elsif(dat_stt = "0011101")then --0
			dat_pas <= '0';
			dat_stt <= dat_stt +1;
		elsif(dat_stt = "0011110")then --1
			dat_pas <= '1';
			dat_stt <= dat_stt +1;
		elsif(dat_stt = "0011111")then --1
			dat_pas <= '1';
			dat_stt <= dat_stt +1;
		elsif(dat_stt = "0100000")then --1
			dat_pas <= '1';
			dat_stt <= dat_stt +1;
		elsif(dat_stt = "0100001")then --1
			dat_pas <= '1';
			dat_stt <= dat_stt +1;
		elsif(dat_stt = "0100010")then --X
			dat_pas <= '0';
			dat_stt <= dat_stt +1;
		elsif(dat_stt = "0100011")then --X
			dat_pas <= '0';
			dat_stt <= dat_stt +1;
		elsif(dat_stt = "0100100")then --X
			dat_pas <= '0';
			dat_stt <= dat_stt +1;
		elsif(dat_stt = "0100101")then --X
			dat_pas <= '0';
			dat_stt <= dat_stt +1;
		elsif(dat_stt = "0010110")then --0
			dat_pas <= '0';
			dat_stt <= dat_stt +1;
		elsif(dat_stt = "0010111")then --0
			dat_pas <= '0';
			dat_stt <= dat_stt +1;
		elsif(dat_stt = "0011000")then --0
			dat_pas <= '0';
			dat_stt <= dat_stt +1;
		elsif(dat_stt = "0011001")then --1
			dat_pas <= '1';
			dat_stt <= dat_stt +1;
		elsif(dat_stt = "0011010")then --1
			dat_pas <= '1';
			dat_stt <= (others=>'0');
		else
			dat_stt <= (others=>'0');
		end if;
	end if;
end process;

clk_out <= clk_div;
data <= dat_pas;

end MCP4706;

