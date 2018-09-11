library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity LongClock is
	generic (
		g_FREQUENCY : integer := 25000000 -- 500 ms 
	); 
	port (
		CLOCK : in  std_logic;
		PULSE : out std_logic
	);
end entity LongClock;

architecture RTL of LongClock is	
	
	signal r_Pulse : std_logic := '0';
	signal r_Count : integer range 0 to g_FREQUENCY := 0;
	
begin
	
	p_Counter : process (CLOCK) is begin
		if rising_edge(CLOCK) then
			
			if (r_Count < g_FREQUENCY) then 
				r_Count <= r_Count + 1;
				r_Pulse <= '0';
			elsif r_Count = g_FREQUENCY then
				r_Pulse <= '1';
				r_Count <= 0;
			else
				r_Pulse <= '0';
				r_Count <= 0;
			end if;
			
		end if;
	end process p_Counter;
	
	PULSE <= r_Pulse;
		
end architecture RTL;