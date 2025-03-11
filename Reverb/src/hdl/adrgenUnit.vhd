
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity adrgenUnit is
    Port ( clk	 		 : in STD_LOGIC;
		   reset	 	 : in STD_LOGIC;
		   I_clr_PtrLine : in STD_LOGIC;
		   I_inc_PtrLine : in STD_LOGIC;
		   I_clr_PtrCol  : in STD_LOGIC;
		   I_inc_PtrCol  : in STD_LOGIC;
		   I_selPix 	 : in STD_LOGIC_VECTOR (1 downto 0);
		   O_EndImage	 : out STD_LOGIC;
		   O_NewLine	 : out STD_LOGIC;
		   O_ADR_R		 : out STD_LOGIC_VECTOR (13 downto 0); -- La profondeur de la mémoire IN = 100x100 = 10000
		   O_ADR_W	 	 : out STD_LOGIC_VECTOR (13 downto 0)  -- La profondeur de la mémoire OUT = 100x100 = 10000   
		   ); 
end adrgenUnit;


architecture Behavioral of adrgenUnit is

-- déclaration des signaux internes
signal S_PtrLine, S_PtrCol : unsigned(6 downto 0);
signal S_mult, S_sum : unsigned(13 downto 0);
signal S_mux : integer;
signal S_lastLine, S_lastCol : STD_LOGIC;


begin

    process(clk, reset)
    
    begin
	   if(reset = '1') then
	       S_PtrLine <= (others => '0');
	       S_PtrCol <= (others => '0');
		
       elsif(rising_edge(clk)) then
            if I_clr_PtrLine = '1' then
                S_PtrLine <= (others => '0');
            
            elsif I_inc_PtrLine = '1' then
                if S_PtrLine = 98 then
                    S_PtrLine <= (others => '0');
                else
                    S_PtrLine <= S_PtrLine + 1;
                end if;
            end if;
            
            if I_clr_PtrCol = '1' then
                S_PtrCol <= (others => '0');
            
            elsif I_inc_PtrCol = '1' then
                if S_PtrCol = 99 then
                    S_PtrCol <= (others => '0');
                else
                    S_PtrCol <= S_PtrCol + 1;
                end if;
            
            end if;
            
       end if;
    
    end process;
    
    process(I_selPix)
    begin
        case I_selPix is
            when "00" => 
                S_mux <= 0;
            when "01" => 
                S_mux <= 100;
            when "10" => 
                S_mux <= 200;
            
            when others => 
                S_mux <= 0;
         end case;
    end process;
        
        
        
    
    S_mult <= S_PtrLine * 100;
    S_sum <= S_mult + S_PtrCol;
    S_lastLine <= '1' when (S_PtrLine=98) else '0';
    S_lastCol <= '1' when (S_PtrCol=0) else '0';
    
    O_EndImage <= '1' when (S_lastLine='1' and S_lastCol='1') else '0';
    -- O_EndImage <= '1' when ((S_sum + S_mux) = 9999)  else '0';
    O_NewLine <= S_lastCol;
	O_ADR_W <= std_logic_vector(S_sum + 99);
	O_ADR_R <= std_logic_vector(S_sum + S_mux);
	
	

end Behavioral;

