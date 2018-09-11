library IEEE;

use IEEE.std_logic_1164.all;

entity Counter is
	port (
		INPUT_NUMBER  : in  std_logic_vector (3 downto 0);
		CONST_NUMBER  : in  std_logic_vector (3 downto 0);
		CARRY_IN		  : in  std_logic;
		OUTPUT_NUMBER : out std_logic_vector (3 downto 0)
	);
end entity Counter;

architecture RTL of Counter is	

	signal w_in 	  : std_logic_vector (4 downto 0);
	signal w_const	  : std_logic_vector (4 downto 0);
	signal w_carry   : std_logic_vector (5 downto 0) := "000000";
	signal w_out	  : std_logic_vector (4 downto 0);
	 
begin
	w_in(0) <= INPUT_NUMBER(0);
	w_in(1) <= INPUT_NUMBER(1);
	w_in(2) <= INPUT_NUMBER(2);
	w_in(3) <= INPUT_NUMBER(3);
	w_in(4) <= '0';
	
	w_const(0) <= CONST_NUMBER(0);
	w_const(1) <= CONST_NUMBER(1);
	w_const(2) <= CONST_NUMBER(2);
	w_const(3) <= CONST_NUMBER(3);
	w_const(4) <= CARRY_IN;
	
	w_carry(0) <= CARRY_IN;
	
	gen_counter: for i in 0 to 4 generate
		w_out(i) <= w_carry(i) xor w_const(i) xor w_in(i);
		w_carry(i + 1) <= (w_const(i) and w_in(i)) or (w_carry(i) and (w_const(i) xor w_in(i)));
	end generate gen_counter;
	
	OUTPUT_NUMBER(0) <= w_out(0);
	OUTPUT_NUMBER(1) <= w_out(1);
	OUTPUT_NUMBER(2) <= w_out(2);
	OUTPUT_NUMBER(3) <= w_out(3);
		
end architecture RTL;