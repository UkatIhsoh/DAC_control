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
    Port ( clk : in  STD_LOGIC; --DCM��100MHz�ɂ��� -> ���낢�날����1MHZ��
           rst : in  STD_LOGIC; --WING_B[15]�ɓ���
           switch : in  STD_LOGIC; --WING_B[14]�ɓ���
			  trigger : out std_logic; --�o�͊m�F�p�g���K�[,WING_A[2]�ɏo��
           scl : out  STD_LOGIC; --WING_A[0]�ɏo��
           sda : out  STD_LOGIC); --WING_A[1]�ɏo��
end MCP4726_ctrl;

architecture control of MCP4726_ctrl is

component DCMto100k is
	port(	CLK_IN1 :std_logic;
			CLK_OUT1 :std_logic);
end component;

--constant hz_100k : std_logic_vector(11 downto 0):= X"009"; --1M�N���b�N��100k�N���b�N���Č����邽�߂̃J�E���g�l
--constant half_100k :std_logic_vector(11 downto 0):= X"004"; --100k�̔��� 
constant hz_100k : std_logic_vector(19 downto 0):= X"4E200"; --32M�N���b�N��100k�N���b�N���Č����邽�߂̃J�E���g�l
constant half_100k :std_logic_vector(19 downto 0):= X"27100"; --100k�̔��� 
constant WVDR : std_logic_vector(11 downto 0):= "110000000000"; --Write Volatile DAC Register���[�h(�p���[�_�E���Ȃ�) 
constant level_5 : std_logic_vector(11 downto 0):= X"FFF"; --�o�͂T�{���g����12bit�f�[�^
constant level_25 : std_logic_vector(11 downto 0):= X"800"; --�o��2.�T�{���g����12bit�f�[�^
constant test_data : std_logic_vector(23 downto 0):= X"FFFFFF";

signal clk100M : std_logic; --100M�N���b�N
--signal counter : std_logic_vector(11 downto 0); --100k�N���b�N�\���p
signal counter : std_logic_vector(19 downto 0); --100k�N���b�N�\���p
signal scl_out : STD_LOGIC:='0'; --scl�o�͗p
signal scl_rise : std_logic; --scl�����オ�藧�������茟�o�p
signal sda_out : STD_LOGIC; --sda�o�͗p(�f�[�^���]����high)
signal sda_rise : std_logic; --sda�^�C�~���O���o�p
signal sda_data : std_logic_vector(23 downto 0); --sda�̃f�[�^
signal sda_bit : std_logic_vector(7 downto 0):= X"00"; --sda���M�̂��߂�1�r�b�g���ɂ���Ƃ��Ɏg��
signal sw_ac : STD_LOGIC; --switch�������ꂽ���Ƃ�F�����邽��
signal lv_change : STD_LOGIC; --���x���ύX�p�ϐ�
signal fix : std_logic:= '0'; --�C���p
signal break : std_logic:= '1'; --���[�v�h�~
signal trg : std_logic; --trigger  

begin

	clk100M <= clk; --�e�X�g�x���`�p
--DCM : DCMto100k
--	port map(CLK_IN1 => clk,
--				CLK_OUT1 => clk100M);
--	
	 trigger <= trg;
    scl <= scl_out;
    sda <= sda_out;

    process(clk100M,rst,switch)
    begin
        if rst = '1' then
            counter <= (others => '0');
				sw_ac <= '0';
				scl_rise <= '0';
				sda_rise <= '0';
            lv_change <= '0';
        elsif clk100M' event and clk100M = '1' then
            --100k���̃J�E���g���s��
            if counter = hz_100k then
					counter <= (others => '0');
					scl_rise <= '1';
				elsif counter = half_100k then
					counter <= counter +1;
					sda_rise <= '1';
            else
					counter <= counter +1;
					scl_rise <= '0';
					sda_rise <= '0';
            end if;
        end if;

        --�X�C�b�`�������ꂽ��A�f�[�^���؂�ւ��
        if switch = '1' then
            if sw_ac = '0' then
                sw_ac <= '1';
                if lv_change = '0' then
                    sda_data <= WVDR & level_5;
                    lv_change <= '1';
                else
                    sda_data <= WVDR & level_25;
                    lv_change <= '0';
                end if;
            end if;
			else
				sw_ac <= '0'; 
        end if;
    end process;

    process(counter,sw_ac,scl_rise,sda_rise)
    begin
	 
			if sw_ac = '1' then
				 sda_out <= '1';
				sda_bit <= X"00";
				if break <= '1' then 
					break <= '0';					
				end if;
			end if;

        --100kHz�N���b�N����
        if scl_rise = '1' then
            scl_out <= not scl_out;
        end if;

        --�f�[�^�V�[�g�w��ɑ������f�[�^�o��
        if sda_rise = '1' then
				 if sda_bit = X"00" then
					  sda_out <= '0';
					  trg <= '1';
					  if fix = '1' then
							sda_bit <= sda_bit +1;
							fix <= '0';
					  else
							fix <= '1';
					  end if;
				 elsif sda_bit = X"01" or sda_bit = X"02" then
						trg <= '0';
					  sda_out <= sda_data(23);
					  sda_bit <= sda_bit +1;
				 elsif sda_bit = X"03" or sda_bit = X"04" then
					  sda_out <= sda_data(22);
					  sda_bit <= sda_bit +1;
				 elsif sda_bit = X"05" or sda_bit = X"06" then
					  sda_out <= sda_data(21);
					  sda_bit <= sda_bit +1;
				 elsif sda_bit = X"07" or sda_bit = X"08" then
					  sda_out <= sda_data(20);
					  sda_bit <= sda_bit +1;
				 elsif sda_bit = X"09" or sda_bit = X"0A" then
					  sda_out <= sda_data(19);
					  sda_bit <= sda_bit +1;    
				 elsif sda_bit = X"0B" or sda_bit = X"0C" then
					  sda_out <= sda_data(18);
					  sda_bit <= sda_bit +1;
				 elsif sda_bit = X"0D" or sda_bit = X"0E" then
					  sda_out <= sda_data(17);
					  sda_bit <= sda_bit +1;
				 elsif sda_bit = X"0F" or sda_bit = X"10" then
					  sda_out <= sda_data(16);
					  sda_bit <= sda_bit +1;
				 elsif sda_bit = X"11" or sda_bit = X"12" then
					  sda_out <= '0';
					  sda_bit <= sda_bit +1;
				 elsif sda_bit = X"13" or sda_bit = X"14" then
					  sda_out <= sda_data(15);
					  sda_bit <= sda_bit +1;
				 elsif sda_bit = X"15" or sda_bit = X"16" then
					  sda_out <= sda_data(14);
					  sda_bit <= sda_bit +1;
				 elsif sda_bit = X"17" or sda_bit = X"18" then
					  sda_out <= sda_data(13);
					  sda_bit <= sda_bit +1;
				 elsif sda_bit = X"19" or sda_bit = X"1A" then
					  sda_out <= sda_data(12);
					  sda_bit <= sda_bit +1;
				 elsif sda_bit = X"1B" or sda_bit = X"1C" then
					  sda_out <= sda_data(11);
					  sda_bit <= sda_bit +1;    
				 elsif sda_bit = X"1D" or sda_bit = X"1E" then
					  sda_out <= sda_data(10);
					  sda_bit <= sda_bit +1;
				 elsif sda_bit = X"1F" or sda_bit = X"20" then
					  sda_out <= sda_data(9);
					  sda_bit <= sda_bit +1;
				 elsif sda_bit = X"21" or sda_bit = X"22" then
					  sda_out <= sda_data(8);
					  sda_bit <= sda_bit +1;
				 elsif sda_bit = X"23" or sda_bit = X"24" then
					  sda_out <= '0';
					  sda_bit <= sda_bit +1;
				 elsif sda_bit = X"25" or sda_bit = X"26" then
					  sda_out <= sda_data(7);
					  sda_bit <= sda_bit +1;
				 elsif sda_bit = X"27" or sda_bit = X"28" then
					  sda_out <= sda_data(6);
					  sda_bit <= sda_bit +1;
				 elsif sda_bit = X"29" or sda_bit = X"2A" then
					  sda_out <= sda_data(5);
					  sda_bit <= sda_bit +1;
				 elsif sda_bit = X"2B" or sda_bit = X"2C" then
					  sda_out <= sda_data(4);
					  sda_bit <= sda_bit +1;
				 elsif sda_bit = X"2D" or sda_bit = X"2E" then
					  sda_out <= sda_data(3);
					  sda_bit <= sda_bit +1;    
				 elsif sda_bit = X"2F" or sda_bit = X"30" then
					  sda_out <= sda_data(2);
					  sda_bit <= sda_bit +1;
				 elsif sda_bit = X"31" or sda_bit = X"32" then
					  sda_out <= sda_data(1);
					  sda_bit <= sda_bit +1;
				 elsif sda_bit = X"33" or sda_bit = X"34" then
					  sda_out <= sda_data(0);
					  sda_bit <= sda_bit +1;
				 elsif sda_bit = X"35" or sda_bit = X"36" then
					  sda_out <= '0';
					  sda_bit <= sda_bit +1;
				 else
					   sda_out <= '1';
						if sw_ac = '1' then
							if break <= '1' then 
								break <= '0';					
							end if;
						end if;
				end if;
        end if;

    end process;

end control;

