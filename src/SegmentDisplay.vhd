library IEEE;

use IEEE.std_logic_1164.all;

entity SegmentDisplay is
	port (
		CLOCK : in  std_logic;
		EDITED: in  std_logic_vector (2 downto 0);
		
		DISP0 : in  std_logic_vector (3 downto 0);
		DISP1 : in  std_logic_vector (3 downto 0);
		DISP2 : in  std_logic_vector (3 downto 0);
		DISP3 : in  std_logic_vector (3 downto 0);
		DISP4 : in  std_logic_vector (3 downto 0);
		DISP5 : in  std_logic_vector (3 downto 0);
		
		HEX0  : out std_logic_vector (6 downto 0);
		HEX1  : out std_logic_vector (6 downto 0);
		HEX2  : out std_logic_vector (6 downto 0);
		HEX3  : out std_logic_vector (6 downto 0);
		HEX4  : out std_logic_vector (6 downto 0);
		HEX5  : out std_logic_vector (6 downto 0)
	);
end entity SegmentDisplay;

architecture RTL of SegmentDisplay is

	signal w_EditedDisplay : std_logic_vector (5 downto 0) := "000000";
	signal w_BlinkTick	  : std_logic;
	signal r_Blink			  : std_logic 						    := '0';
	signal r_Blinking 	  : std_logic_vector (5 downto 0) := "000000";

begin
	
	e_EditedSegment : entity work.Binary6ToLines
		port map (BINARY => EDITED, LINES => w_EditedDisplay);
	
	e_Delay : entity work.LongClock 
		port map (CLOCK => CLOCK, PULSE => w_BlinkTick);
		
	-- determines whether to switch or not blink status 
	p_BlinkPhaser : process (CLOCK) is begin
		if rising_edge(CLOCK) then
			if w_BlinkTick = '1' then
				r_Blink <= not r_Blink;
				if r_Blink = '0' then
					r_Blinking <= w_EditedDisplay;
				else
					r_Blinking <= "000000";
				end if;
			end if;
		end if;
	end process p_BlinkPhaser;
	
	e_Left0Segment : entity work.SegmentDisplayUnit 
		port map (CLOCK => CLOCK, BLINK => r_Blinking(0), DISP => DISP0, HEX => HEX0);
	e_Left1Segment : entity work.SegmentDisplayUnit 
		port map (CLOCK => CLOCK, BLINK => r_Blinking(1), DISP => DISP1, HEX => HEX1);
	e_Left2Segment : entity work.SegmentDisplayUnit
		port map (CLOCK => CLOCK, BLINK => r_Blinking(2), DISP => DISP2, HEX => HEX2);
	e_Left3Segment : entity work.SegmentDisplayUnit 
		port map (CLOCK => CLOCK, BLINK => r_Blinking(3), DISP => DISP3, HEX => HEX3);
	e_Left4Segment : entity work.SegmentDisplayUnit 
		port map (CLOCK => CLOCK, BLINK => r_Blinking(4), DISP => DISP4, HEX => HEX4);
	e_Left5Segment : entity work.SegmentDisplayUnit 
		port map (CLOCK => CLOCK, BLINK => r_Blinking(5), DISP => DISP5, HEX => HEX5);
	
end architecture RTL;