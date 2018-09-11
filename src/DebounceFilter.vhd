library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity DebounceFilter is
	generic (
		g_DEBOUNCE_LIMIT : integer := 500000 -- 10 ms 
	); 
	port (
		CLOCK : in  std_logic;
		INP   : in  std_logic;
		OTP   : out std_logic
	);
end entity DebounceFilter;

architecture RTL of DebounceFilter is	
	
	signal r_State : std_logic := '0';
	signal r_Count : integer range 0 to g_DEBOUNCE_LIMIT := 0;
	
begin
	
	p_Debounce : process (CLOCK) is begin
		if rising_edge(CLOCK) then
			
			if (INP /= r_State and r_Count < g_DEBOUNCE_LIMIT) then 
				r_Count <= r_Count + 1;
			elsif r_Count = g_DEBOUNCE_LIMIT then
				r_State <= INP;
				r_Count <= 0;
			else
				r_Count <= 0;
			end if;
			
		end if;
	end process p_Debounce;
	
	OTP <= r_State;
		
end architecture RTL;