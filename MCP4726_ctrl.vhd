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

constant hz_100k : std_logic_vector(11 downto 0): = X"3E8"; --100Mクロックで100kクロックを再現するためのカウント値
constant half_100k :std_logic_vector(11 downto 0): = X"1F4"; --100kの半分 
constant WVDR : std_logic_vector(11 downto 0):= "110000000000" --Write Volatile DAC Registerモード(パワーダウンなし) 
constant level_5 : std_logic_vector(11 downto 0):= X"FFF"; --出力５ボルト時の12bitデータ
constant level_25 : std_logic_vector(11 downto 0):= X"800"; --出力2.５ボルト時の12bitデータ

signal scl_out : STD_LOGIC; --scl出力用
signal sda_out : STD_LOGIC:= '1'; --sda出力用(データ未転送時high)
signal sda_data : std_logic_vector(23 downto 0); --sdaのデータ
signal sda_bit : std_logic_vector(7 downto 0):= X"FF"; --sda送信のために1ビットずつにするときに使う
signal sw_ac : STD_LOGIC; --switchが押されたことを認識するため
signal lv_change : STD_LOGIC; --レベル変更用変数

begin

    scl <= scl_out;
    sda <= sda_out;

    process(clk,rst,switch)
    begin
        if rst = '1' then
            counter <= (others => '0');
            sw_ac <= '0';
            lv_change <= '0';
        elsif clk' event and clk = '1' then
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
                    sda_data <= WVDR & level_33;
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
            sda_out <= "1";
            sda_bit <= X"00";
        end if;

        --100kHzクロック生成
        if counter = hz_100k then
            scl_out <= not scl_out;
        end if;

        --データシート指定に則ったデータ出力
        if counter = half_100k then
            case sda_bit is
                when X"00" or X"01" =>
                    sda_out <= "0";
                    sda_bit <= sda_bit +1;
                when X"02" =>
                    sda_out <= "0";
                    sda_bit <= sda_bit +1;
                when X"03" or X"04" or X"05" or X"06" =>
                    sda_out <= sda_data(23);
                    sda_bit <= sda_bit +1;
                when X"07" or X"08" or X"09" or X"0A" =>
                    sda_out <= sda_data(22);
                    sda_bit <= sda_bit +1;
                when X"0B" or X"0C" or X"0D" or X"0E" =>
                    sda_out <= sda_data(21);
                    sda_bit <= sda_bit +1;
                when X"0F" or X"10" or X"11" or X"12" =>
                    sda_out <= sda_data(20);
                    sda_bit <= sda_bit +1;
                when X"13" or X"14" or X"15" or X"16" =>
                    sda_out <= sda_data(19);
                    sda_bit <= sda_bit +1;    
                when X"17" or X"18" or X"19" or X"1A" =>
                    sda_out <= sda_data(18);
                    sda_bit <= sda_bit +1;
                when X"1B" or X"1C" or X"1D" or X"1E" =>
                    sda_out <= sda_data(17);
                    sda_bit <= sda_bit +1;
                when X"1F" or X"20" or X"21" or X"22" =>
                    sda_out <= sda_data(16);
                    sda_bit <= sda_bit +1;
                when X"23" or X"24" or X"25" or X"26" =>
                    sda_out <= '0';
                    sda_bit <= sda_bit +1;
                when X"27" or X"28" or X"29" or X"2A" =>
                    sda_out <= sda_data(15);
                    sda_bit <= sda_bit +1;
                when X"2B" or X"2C" or X"2D" or X"2E" =>
                    sda_out <= sda_data(14);
                    sda_bit <= sda_bit +1;
                when X"2F" or X"30" or X"31" or X"32" =>
                    sda_out <= sda_data(13);
                    sda_bit <= sda_bit +1;
                when X"33" or X"34" or X"35" or X"36" =>
                    sda_out <= sda_data(12);
                    sda_bit <= sda_bit +1;
                when X"37" or X"38" or X"39" or X"3A" =>
                    sda_out <= sda_data(11);
                    sda_bit <= sda_bit +1;    
                when X"3B" or X"3C" or X"3D" or X"3E" =>
                    sda_out <= sda_data(10);
                    sda_bit <= sda_bit +1;
                when X"3F" or X"40" or X"41" or X"42" =>
                    sda_out <= sda_data(9);
                    sda_bit <= sda_bit +1;
                when X"43" or X"44" or X"45" or X"46" =>
                    sda_out <= sda_data(8);
                    sda_bit <= sda_bit +1;
                when X"47" or X"48" or X"49" or X"4A" =>
                    sda_out <= '0';
                    sda_bit <= sda_bit +1;
                when X"4B" or X"4C" or X"4D" or X"4E" =>
                    sda_out <= sda_data(7);
                    sda_bit <= sda_bit +1;
                when X"4F" or X"50" or X"51" or X"52" =>
                    sda_out <= sda_data(6);
                    sda_bit <= sda_bit +1;
                when X"53" or X"54" or X"55" or X"56" =>
                    sda_out <= sda_data(5);
                    sda_bit <= sda_bit +1;
                when X"57" or X"58" or X"59" or X"5A" =>
                    sda_out <= sda_data(4);
                    sda_bit <= sda_bit +1;
                when X"5B" or X"5C" or X"5D" or X"5E" =>
                    sda_out <= sda_data(3);
                    sda_bit <= sda_bit +1;    
                when X"5F" or X"60" or X"61" or X"62" =>
                    sda_out <= sda_data(2);
                    sda_bit <= sda_bit +1;
                when X"63" or X"64" or X"65" or X"66" =>
                    sda_out <= sda_data(1);
                    sda_bit <= sda_bit +1;
                when X"67" or X"68" or X"69" or X"6A" =>
                    sda_out <= sda_data(0);
                    sda_bit <= sda_bit +1;
                when X"6B" or X"6C" =>
                    sda_out <= '0';
                    sda_bit <= sda_bit +1;
                when others =>
                    sda_out <= '1';
            end case;
        end if;

    end process;

end control;

