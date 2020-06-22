----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:45:17 06/19/2020 
-- Design Name: 
-- Module Name:    MCP4726_ctrl - control 
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
use IEEE.STD_LOGIC_arith.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MCP4726_ctrl is
    Port ( clk : in  STD_LOGIC; --DCMで100MHzにする
           rst : in  STD_LOGIC;
           switch : in  STD_LOGIC;
           scl : out  STD_LOGIC;
           sda : out  STD_LOGIC);
end MCP4726_ctrl;

architecture control of MCP4726_ctrl is

component DCMto100k is
	port(	CLK_IN1 :std_logic;
			CLK_OUT1 :std_logic);
end component;

constant hz_100k : std_logic_vector(11 downto 0):= X"3E8"; --100Mクロックで100kクロックを再現するためのカウント値
constant half_100k :std_logic_vector(11 downto 0):= X"1F4"; --100kの半分 
constant WVDR : std_logic_vector(11 downto 0):= "110000000000"; --Write Volatile DAC Registerモード(パワーダウンなし) 
constant level_5 : std_logic_vector(11 downto 0):= X"FFF"; --出力５ボルト時の12bitデータ
constant level_25 : std_logic_vector(11 downto 0):= X"800"; --出力2.５ボルト時の12bitデータ

signal clk100M : std_logic; --100Mクロック
signal counter : std_logic_vector(3 downto 0); --100kクロック構成用
signal scl_out : STD_LOGIC; --scl出力用
signal sda_out : STD_LOGIC:= '1'; --sda出力用(データ未転送時high)
signal sda_data : std_logic_vector(23 downto 0); --sdaのデータ
signal sda_bit : std_logic_vector(7 downto 0):= X"FF"; --sda送信のために1ビットずつにするときに使う
signal sw_ac : STD_LOGIC; --switchが押されたことを認識するため
signal lv_change : STD_LOGIC; --レベル変更用変数

begin

DCM : DCMto100k
	port map(CLK_IN1 => clk,
				CLK_OUT1 => clk100M);
	
    scl <= scl_out;
    sda <= sda_out;

    process(clk100M,rst,switch)
    begin
        if rst = '1' then
            counter <= (others => '0');
            sw_ac <= '0';
            lv_change <= '0';
        elsif clk100M' event and clk100M = '1' then
            --100k分のカウントを行う
            if counter = hz_100k then
                counter <= (others => '0');
            else
                counter <= counter +1;
            end if;
        end if;

        --スイッチが押されたら、データが切り替わる
        if switch = '1' then
            if sw_ac = '0' then
                sw_ac <= '1';
            else
                if lv_change = '0' then
                    sda_data <= WVDR & level_5;
                    sw_ac <= '0';
                    lv_change <= '1';
                else
                    sda_data <= WVDR & level_25;
                    sw_ac <= '0';
                    lv_change <= '0';
                end if;
            end if;
        end if;
    end process;

    process(counter,sw_ac)
    begin
        --スイッチが押されたらSDA転送開始
        if sw_ac = '1' then
            sda_out <= '1';
            sda_bit <= X"00";
        end if;

        --100kHzクロック生成
        if counter = hz_100k then
            scl_out <= not scl_out;
        end if;

        --データシート指定に則ったデータ出力
        if counter = half_100k then
				 if sda_bit = X"00" or sda_bit = X"01" then
					  sda_out <= '0';
					  sda_bit <= sda_bit +1;
				 elsif sda_bit = X"02" then
					  sda_out <= '0';
					  sda_bit <= sda_bit +1;
				 elsif sda_bit = X"03" or sda_bit = X"04" or sda_bit = X"05" or sda_bit = X"06" then
					  sda_out <= sda_data(23);
					  sda_bit <= sda_bit +1;
				 elsif sda_bit = X"07" or sda_bit = X"08" or sda_bit = X"09" or sda_bit = X"0A" then
					  sda_out <= sda_data(22);
					  sda_bit <= sda_bit +1;
				 elsif sda_bit = X"0B" or sda_bit = X"0C" or sda_bit = X"0D" or sda_bit = X"0E" then
					  sda_out <= sda_data(21);
					  sda_bit <= sda_bit +1;
				 elsif sda_bit = X"0F" or sda_bit = X"10" or sda_bit = X"11" or sda_bit = X"12" then
					  sda_out <= sda_data(20);
					  sda_bit <= sda_bit +1;
				 elsif sda_bit = X"13" or sda_bit = X"14" or sda_bit = X"15" or sda_bit = X"16" then
					  sda_out <= sda_data(19);
					  sda_bit <= sda_bit +1;    
				 elsif sda_bit = X"17" or sda_bit = X"18" or sda_bit = X"19" or sda_bit = X"1A" then
					  sda_out <= sda_data(18);
					  sda_bit <= sda_bit +1;
				 elsif sda_bit = X"1B" or sda_bit = X"1C" or sda_bit = X"1D" or sda_bit = X"1E" then
					  sda_out <= sda_data(17);
					  sda_bit <= sda_bit +1;
				 elsif sda_bit = X"1F" or sda_bit = X"20" or sda_bit = X"21" or sda_bit = X"22" then
					  sda_out <= sda_data(16);
					  sda_bit <= sda_bit +1;
				 elsif sda_bit = X"23" or sda_bit = X"24" or sda_bit = X"25" or sda_bit = X"26" then
					  sda_out <= '0';
					  sda_bit <= sda_bit +1;
				 elsif sda_bit = X"27" or sda_bit = X"28" or sda_bit = X"29" or sda_bit = X"2A" then
					  sda_out <= sda_data(15);
					  sda_bit <= sda_bit +1;
				 elsif sda_bit = X"2B" or sda_bit = X"2C" or sda_bit = X"2D" or sda_bit = X"2E" then
					  sda_out <= sda_data(14);
					  sda_bit <= sda_bit +1;
				 elsif sda_bit = X"2F" or sda_bit = X"30" or sda_bit = X"31" or sda_bit = X"32" then
					  sda_out <= sda_data(13);
					  sda_bit <= sda_bit +1;
				 elsif sda_bit = X"33" or sda_bit = X"34" or sda_bit = X"35" or sda_bit = X"36" then
					  sda_out <= sda_data(12);
					  sda_bit <= sda_bit +1;
				 elsif sda_bit = X"37" or sda_bit = X"38" or sda_bit = X"39" or sda_bit = X"3A" then
					  sda_out <= sda_data(11);
					  sda_bit <= sda_bit +1;    
				 elsif sda_bit = X"3B" or sda_bit = X"3C" or sda_bit = X"3D" or sda_bit = X"3E" then
					  sda_out <= sda_data(10);
					  sda_bit <= sda_bit +1;
				 elsif sda_bit = X"3F" or sda_bit = X"40" or sda_bit = X"41" or sda_bit = X"42" then
					  sda_out <= sda_data(9);
					  sda_bit <= sda_bit +1;
				 elsif sda_bit = X"43" or sda_bit = X"44" or sda_bit = X"45" or sda_bit = X"46" then
					  sda_out <= sda_data(8);
					  sda_bit <= sda_bit +1;
				 elsif sda_bit = X"47" or sda_bit = X"48" or sda_bit = X"49" or sda_bit = X"4A" then
					  sda_out <= '0';
					  sda_bit <= sda_bit +1;
				 elsif sda_bit = X"4B" or sda_bit = X"4C" or sda_bit = X"4D" or sda_bit = X"4E" then
					  sda_out <= sda_data(7);
					  sda_bit <= sda_bit +1;
				 elsif sda_bit = X"4F" or sda_bit = X"50" or sda_bit = X"51" or sda_bit = X"52" then
					  sda_out <= sda_data(6);
					  sda_bit <= sda_bit +1;
				 elsif sda_bit = X"53" or sda_bit = X"54" or sda_bit = X"55" or sda_bit = X"56" then
					  sda_out <= sda_data(5);
					  sda_bit <= sda_bit +1;
				 elsif sda_bit = X"57" or sda_bit = X"58" or sda_bit = X"59" or sda_bit = X"5A" then
					  sda_out <= sda_data(4);
					  sda_bit <= sda_bit +1;
				 elsif sda_bit = X"5B" or sda_bit = X"5C" or sda_bit = X"5D" or sda_bit = X"5E" then
					  sda_out <= sda_data(3);
					  sda_bit <= sda_bit +1;    
				 elsif sda_bit = X"5F" or sda_bit = X"60" or sda_bit = X"61" or sda_bit = X"62" then
					  sda_out <= sda_data(2);
					  sda_bit <= sda_bit +1;
				 elsif sda_bit = X"63" or sda_bit = X"64" or sda_bit = X"65" or sda_bit = X"66" then
					  sda_out <= sda_data(1);
					  sda_bit <= sda_bit +1;
				 elsif sda_bit = X"67" or sda_bit = X"68" or sda_bit = X"69" or sda_bit = X"6A" then
					  sda_out <= sda_data(0);
					  sda_bit <= sda_bit +1;
				 elsif sda_bit = X"6B" or sda_bit = X"6C" then
					  sda_out <= '0';
					  sda_bit <= sda_bit +1;
				 else
					  sda_out <= '1';
				end if;
        end if;

    end process;

end control;

