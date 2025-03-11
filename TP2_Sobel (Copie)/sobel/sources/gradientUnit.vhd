
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity gradientUnit is
    Port ( I_Pix11, I_Pix12, I_Pix13 : in STD_LOGIC_VECTOR (7 downto 0);
		   I_Pix21, I_Pix22, I_Pix23 : in STD_LOGIC_VECTOR (7 downto 0);
		   I_Pix31, I_Pix32, I_Pix33 : in STD_LOGIC_VECTOR (7 downto 0);
		   O_pixEdge : out  STD_LOGIC		   
		   ); 
end gradientUnit;


architecture Behavioral of gradientUnit is

-- déclaration des signaux internes
	constant S_threshold : integer := 255;
	signal S_GH, S_GV, S_GRAD : integer;
	signal S_Pix11, S_Pix12, S_Pix13, S_Pix21, S_Pix22, S_Pix23, S_Pix31, S_Pix32, S_Pix33 : integer; 

begin

    S_Pix11 <= to_integer(unsigned(I_Pix11));
    S_Pix12 <= to_integer(unsigned(I_Pix12));
    S_Pix13 <= to_integer(unsigned(I_Pix13));
    S_Pix21 <= to_integer(unsigned(I_Pix21));
    S_Pix22 <= to_integer(unsigned(I_Pix22));
    S_Pix23 <= to_integer(unsigned(I_Pix23));
    S_Pix31 <= to_integer(unsigned(I_Pix31));
    S_Pix32 <= to_integer(unsigned(I_Pix32));
    S_Pix33 <= to_integer(unsigned(I_Pix33));
    
	S_GH <= S_Pix13 + 2*S_Pix23 + S_Pix33 - S_Pix11 - 2*S_Pix21 - S_Pix31;
	
	S_GV <= S_Pix11 + 2*S_Pix12 + S_Pix13 - S_Pix31 - 2*S_Pix32 - S_Pix33;
	
	S_GRAD <= abs(S_GH) + abs(S_GV);
	
	O_pixEdge <= '1' when (S_GRAD > S_threshold) else '0';
		

end Behavioral;

