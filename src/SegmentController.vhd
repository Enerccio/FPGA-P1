library IEEE;

use IEEE.std_logic_1164.all;

entity SegmentController is
	port (
		-- clock input
		CLOCK_50 : in  std_logic;
		
		-- key controls input
		-- buttons SW (0-3) determining which diplay is edited
		SW       : in  std_logic_vector (9 downto 0);
		-- KEY(0) - hold 2 seconds to start editing, hold 2 seconds to save
		-- KEY(2) - increase edited value by 1
		-- KEY(3) - decrease edited value by 1
		KEY      : in  std_logic_vector (3 downto 0);
		
		-- display 7 segment outputs
		HEX0     : out std_logic_vector (6 downto 0);
		HEX1     : out std_logic_vector (6 downto 0);
		HEX2     : out std_logic_vector (6 downto 0);
		HEX3     : out std_logic_vector (6 downto 0);
		HEX4     : out std_logic_vector (6 downto 0);
		HEX5     : out std_logic_vector (6 downto 0)
	);
end entity SegmentController;

architecture RTL of SegmentController is

	type t_Memory is array (0 to 5) of std_logic_vector (3 downto 0);
	
	constant c_ONE 					 : std_logic_vector(3 downto 0) := "0001";
	
	-- holds the configuration of the set numbers
	signal r_Memory 		 			 : t_Memory := (others => (others => '0')); 
	-- whether we are in edit mode or not
	signal r_EditMode     			 : std_logic := '0';
	-- signal to prevent immediate garbage save due to clock
	signal r_EditModeCheck 			 : std_logic := '0';
	-- button state
	signal w_ButtonPushed 			 : std_logic_vector (2 downto 0);
	signal r_ButtonPushed 			 : std_logic_vector (2 downto 0);
	-- editing which segment display
	signal w_EditingSegment	   	 : std_logic_vector (2 downto 0);
	signal r_EditingSegmentActive	 : std_logic_vector (2 downto 0);
	-- edited memory cell wire 
	signal r_EditedMemoryCell	    : std_logic_vector (3 downto 0);
	signal w_EditedMemoryCellPlus  : std_logic_vector (3 downto 0);
	signal w_EditedMemoryCellMinus : std_logic_vector (3 downto 0);
	
	-- memory rerouting when editing
	signal w_Memory 		 			 : t_Memory := (others => (others => 'U')); 
	
begin
	-- 2000ms at 50 MHz is 100000000	
	e_Debouncer0 : entity work.DebounceFilter 
		generic map (g_DEBOUNCE_LIMIT => 100000000)
		port map (CLOCK => CLOCK_50, INP => KEY(0), OTP => w_ButtonPushed(0));
	-- 100ms at 50 MHz is 5000000
	e_Debouncer2 : entity work.DebounceFilter 
		generic map (g_DEBOUNCE_LIMIT => 5000000)
		port map (CLOCK => CLOCK_50, INP => KEY(2), OTP => w_ButtonPushed(1));
	e_Debouncer3 : entity work.DebounceFilter 
		generic map (g_DEBOUNCE_LIMIT => 5000000)
		port map (CLOCK => CLOCK_50, INP => KEY(3), OTP => w_ButtonPushed(2));

	-- adder
	e_Adder : entity work.Counter 
		port map (INPUT_NUMBER => r_EditedMemoryCell, CONST_NUMBER => c_ONE, CARRY_IN => '0', OUTPUT_NUMBER => w_EditedMemoryCellPlus);
	-- subtractor
	e_Subtractor : entity work.Counter 
		port map (INPUT_NUMBER => r_EditedMemoryCell, CONST_NUMBER => not c_ONE, CARRY_IN => '1', OUTPUT_NUMBER => w_EditedMemoryCellMinus);
		
	w_EditingSegment(0) <= SW(0);
	w_EditingSegment(1) <= SW(1);
	w_EditingSegment(2) <= SW(2);
	
	p_SegmentController : process (CLOCK_50) is begin			
		if rising_edge(CLOCK_50) then
			r_ButtonPushed <= w_ButtonPushed;
			r_EditModeCheck <= '0';
			r_EditingSegmentActive(0) <= w_EditingSegment(0) and r_EditMode;
			r_EditingSegmentActive(1) <= w_EditingSegment(1) and r_EditMode;
			r_EditingSegmentActive(2) <= w_EditingSegment(2) and r_EditMode;
			
			if r_EditMode = '1' then
				-- we are in edit mode
				-- buttons +- now will work and edit memory cells
				
				if w_ButtonPushed(1) = '0' and r_ButtonPushed(1) = '1' then
					-- - button pushed, lower the value
					r_EditedMemoryCell <= w_EditedMemoryCellPlus;
				elsif w_ButtonPushed(2) = '0' and r_ButtonPushed(2) = '1' then
					-- + button pushed, increase the value
					r_EditedMemoryCell <= w_EditedMemoryCellMinus;
				end if;
				
				if w_ButtonPushed(0) = '0' and r_ButtonPushed(0) = '1' and r_EditModeCheck /= '1' then	
					-- store settings
					case w_EditingSegment is
						when "001" => r_Memory(0) <= r_EditedMemoryCell;
						when "010" => r_Memory(1) <= r_EditedMemoryCell; 
						when "011" => r_Memory(2) <= r_EditedMemoryCell; 
						when "100" => r_Memory(3) <= r_EditedMemoryCell; 
						when "101" => r_Memory(4) <= r_EditedMemoryCell; 
						when "110" => r_Memory(5) <= r_EditedMemoryCell; 
						when others => null;
					end case;
					r_EditMode <= '0';
				end if;
			else
				-- we are in display mode
				-- buttons +- do not work and we only pass state to display unchanged
				if w_ButtonPushed(0) = '0' and r_ButtonPushed(0) = '1' then
					r_EditMode <= '1'; 
					r_EditModeCheck <= '1';
					
					case w_EditingSegment is
						when "001" => r_EditedMemoryCell <= r_Memory(0);
						when "010" => r_EditedMemoryCell <= r_Memory(1); 
						when "011" => r_EditedMemoryCell <= r_Memory(2); 
						when "100" => r_EditedMemoryCell <= r_Memory(3); 
						when "101" => r_EditedMemoryCell <= r_Memory(4); 
						when "110" => r_EditedMemoryCell <= r_Memory(5); 
						when others => null;
					end case;
				end if;
			end if;
		end if;
	end process;
	
	p_SegmentWirer : process (r_EditedMemoryCell, r_Memory, r_EditMode, w_EditingSegment) is begin	
		w_Memory <= r_Memory;
		
		if r_EditMode = '1' then
			-- display segment with memory modifiable if not permanent
			case w_EditingSegment is
				when "001" => 
					w_Memory(0) <= r_EditedMemoryCell;
				when "010" => 
					w_Memory(1) <= r_EditedMemoryCell;
				when "011" => 
					w_Memory(2) <= r_EditedMemoryCell; 
				when "100" => 
					w_Memory(3) <= r_EditedMemoryCell;
				when "101" => 
					w_Memory(4) <= r_EditedMemoryCell;
				when "110" => 
					w_Memory(5) <= r_EditedMemoryCell; 
				when others => null;
			end case;
		end if;
	end process;
	
	e_SegmentDisplay : entity work.SegmentDisplay 
		port map (CLOCK => CLOCK_50, EDITED => r_EditingSegmentActive, 
			DISP0 => w_Memory(0), DISP1 => w_Memory(1), DISP2 => w_Memory(2), 
			DISP3 => w_Memory(3), DISP4 => w_Memory(4), DISP5 => w_Memory(5), 
			HEX0 => HEX0, HEX1 => HEX1, HEX2 => HEX2,
			HEX3 => HEX3, HEX4 => HEX4, HEX5 => HEX5);
	
end architecture RTL;