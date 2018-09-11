library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Binary6ToLines is
	port (
		BINARY: in  std_logic_vector (2 downto 0);
		LINES : out std_logic_vector (5 downto 0)
	);
end entity Binary6ToLines;

architecture RTL of Binary6ToLines is

	signal w_Lines : std_logic_vector (5 downto 0) := "000000";
	
begin

	p_Liner : process (BINARY) begin
		case BINARY is
			when "001" => w_Lines <= "000001";
			when "010" => w_Lines <= "000010"; 
			when "011" => w_Lines <= "000100"; 
			when "100" => w_Lines <= "001000"; 
			when "101" => w_Lines <= "010000"; 
			when "110" => w_Lines <= "100000"; 	
			when others => w_Lines <= "000000";
		end case;
	end process;
	
	LINES <= w_Lines;
	
end architecture RTL;