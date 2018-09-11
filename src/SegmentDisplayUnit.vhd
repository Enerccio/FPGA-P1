library IEEE;

use IEEE.std_logic_1164.all;

entity SegmentDisplayUnit is
	port (
		CLOCK : in  std_logic;
		BLINK : in  std_logic;
		DISP  : in  std_logic_vector (3 downto 0);
		
		HEX   : out std_logic_vector (6 downto 0)
	);
end entity SegmentDisplayUnit;

architecture RTL of SegmentDisplayUnit is

	signal w_hex : std_logic_vector (6 downto 0);
		
begin
	
	p_Map : process (DISP, BLINK) begin
		if BLINK = '1' then
			w_hex <= "0000000";
		else
			case DISP is
			  when "0000" => w_hex <= "1111110"; -- 0
			  when "0001" => w_hex <= "0110000"; -- 1
			  when "0010" => w_hex <= "1101101"; -- 2
			  when "0011" => w_hex <= "1111001"; -- 3
			  when "0100" => w_hex <= "0110011"; -- 4
			  when "0101" => w_hex <= "1011011"; -- 5
			  when "0110" => w_hex <= "1011111"; -- 6
			  when "0111" => w_hex <= "1110000"; -- 7
			  when "1000" => w_hex <= "1111111"; -- 8
			  when "1001" => w_hex <= "1111011"; -- 9
			  when "1010" => w_hex <= "1110111"; -- A
			  when "1011" => w_hex <= "0011111"; -- B
			  when "1100" => w_hex <= "1001110"; -- C 
			  when "1101" => w_hex <= "0111101"; -- D
			  when "1110" => w_hex <= "1001111"; -- E
			  when "1111" => w_hex <= "1000111"; -- F
			  when others => w_hex <= "1001001"; -- invalid
			end case;
		end if;
	end process;
	
	HEX(0) <= not w_hex(6);
	HEX(1) <= not w_hex(5);
	HEX(2) <= not w_hex(4);
	HEX(3) <= not w_hex(3);
	HEX(4) <= not w_hex(2);
	HEX(5) <= not w_hex(1);
	HEX(6) <= not w_hex(0);
	
end architecture RTL;