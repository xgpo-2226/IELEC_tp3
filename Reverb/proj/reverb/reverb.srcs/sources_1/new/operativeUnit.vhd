----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/11/2025 04:01:18 PM
-- Design Name: 
-- Module Name: operativeUnit - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity operativeUnit is

  port (
    I_clock          : in  std_logic;   -- global clock
    I_reset          : in  std_logic;   -- asynchronous global reset
    I_inputSample    : in  std_logic_vector(7 downto 0);  -- 8 bit input sample
    I_loadShift      : in  std_logic;  -- Control signal to load the input sample in the sample shift register and shift the register
    I_initAddress    : in  std_logic;  -- Control signal to initialize register read address
    I_incrAddress    : in  std_logic;  -- Control signal to increment register read address
    I_initSum        : in  std_logic;  -- Control signal to initialize the MAC register
    I_loadSum        : in  std_logic;  -- Control signal to load the MAC register;
    I_loadY          : in  std_logic;   -- Control signal to load Y register
    O_processingDone : out std_logic;   -- Indicate that processing is done -- loadOutput
    O_Y              : out std_logic_vector(7 downto 0)   -- filtered sample
    );

end entity operativeUnit;

architecture arch_operativeUnit of operativeUnit is
  type registerFile is array(0 to 15) of signed(7 downto 0); -- chiffres entiers
  signal SR_coefRegister : registerFile;


  signal SR_shiftRegister : registerFile;  -- shift register file used to store and shift input samples
  signal SC_multOperand1  : signed(7 downto 0);
  signal SC_multOperand2  : signed(7 downto 0);
  signal SC_MultResult    : signed(15 downto 0);  -- Result of the multiplication Xi*Hi
  signal SC_addResult     : signed(19 downto 0);  -- result of the accumulation addition
  signal SR_sum           : signed(19 downto 0);  -- Accumulation register
  signal SR_Y             : signed(7 downto 0);  -- filtered sample storage register
  signal SR_readAddress   : integer range 0 to 15;  -- register files read address



begin

-- Low-pass filter provided with octave (or Matlab command
--fir1(15, .001)/sqrt(sum(fir1(15, .001).^2))*2^6
  SR_coefRegister <= (to_signed(2, 8),  -- ROM register used file to store FIR coefficients -- chiffres fractionnaires entre -1 et +1; premier chiffre est signée
                      to_signed(3, 8),
                      to_signed(6, 8),
                      to_signed(10, 8),
                      to_signed(15, 8),
                      to_signed(20, 8),
                      to_signed(24, 8),
                      to_signed(26, 8),
                      to_signed(26, 8),
                      to_signed(24, 8),
                      to_signed(20, 8),
                      to_signed(15, 8),
                      to_signed(10, 8),
                      to_signed(6, 8),
                      to_signed(3, 8),
                      to_signed(2, 8)
                      );

  shift : process (I_reset, I_clock) is
  begin  -- process shift
    if I_reset = '1' then               -- asynchronous reset (active high)
      SR_shiftRegister <= (others => (others => '0'));
    elsif rising_edge(I_clock) then
      if (I_loadShift = '1') then
          SR_shiftRegister(1 to 15)  <= SR_shiftRegister(0 to 14);
          SR_shiftRegister(0)  <= SIGNED(I_inputSample);
      end if;
    end if;
  end process shift;

  incr_address : process (I_reset, I_clock) is
  begin
    if I_reset = '1' then               -- asynchronous reset (active high)
      SR_readAddress <= 0;
    elsif rising_edge(I_clock) then
       if (I_initAddress = '1') then
          SR_readAddress <= 0;
       elsif (I_incrAddress = '1') then
            if (SR_readAddress = 15) then
                SR_readAddress <= 0;
            else
                SR_readAddress <= SR_readAddress + 1;
            end if;
       end if;

    end if;
  end process incr_address;

  O_processingDone <= '1' when SR_readAddress = 14 else '0' ;

  SC_multOperand1 <= SR_shiftRegister(SR_readAddress);   -- 8 bits
  SC_multOperand2 <= SR_coefRegister(SR_readAddress);    -- 8 bits
  SC_MultResult   <= SC_multOperand1*SC_multOperand2;  -- 16 bits
  SC_addResult    <= resize(SC_MultResult, SC_addResult'length) + SR_sum;

  sum_acc : process (I_reset, I_clock) is
  begin
    if I_reset = '1' then               -- asynchronous reset (active high)
      SR_sum <= (others => '0');
    elsif rising_edge(I_clock) then
        if (I_initSum= '1') then
          SR_sum <= (others => '0');
       elsif (I_loadSum = '1') then
          SR_sum <= SC_addResult;
       end if;
    end if;
  end process sum_acc;

  store_result : process (I_reset, I_clock) is
  begin
    if I_reset = '1' then               -- asynchronous reset (active high)
      SR_Y <= (others => '0');
    elsif rising_edge(I_clock) then
       if (I_loadY= '1') then
        if SC_addResult(6) = '1' then
          SR_Y <= SC_addResult(14 downto 7) + 1;
        else
          SR_Y <= SC_addResult(14 downto 7);
        end if;
       end if;
    end if;

  end process store_result;

  O_Y <= std_logic_vector(SR_Y);

end architecture arch_operativeUnit;