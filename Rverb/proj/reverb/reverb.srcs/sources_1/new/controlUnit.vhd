library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controlUnit is

  port (
    I_clock               : in  std_logic;  -- global clock
    I_reset               : in  std_logic;  -- asynchronous global reset
    I_inputSampleValid    : in  std_logic;  -- Control signal to load the input sample in the sample shift register and shift the register
    I_processingDone      : in  std_logic;
    O_loadShift           : out std_logic;  -- filtered sample
    O_initAddress         : out std_logic;  -- Control signal to initialize register read address
    O_incrAddress         : out std_logic;  -- Control signal to increment register read address
    O_initSum             : out std_logic;  -- Control signal to initialize the MAC register
    O_loadSum             : out std_logic;  -- Control signal to load the MAC register;
    O_loadY               : out std_logic;  -- Control signal to load Y register
    O_FilteredSampleValid : out std_logic  -- Data valid signal for filtered sample
    );

end entity controlUnit;
architecture archi_operativeUnit of controlUnit is


  type T_state is (WAIT_SAMPLE, STORE, PROCESSING_LOOP, OUTPUT, WAIT_END_SAMPLE);  -- state list
  signal SR_presentState : T_state;
  signal SR_futurState   : T_state;

begin

  process (I_reset, I_clock) is
  begin
    if I_reset = '1' then               -- asynchronous reset (active high)
      SR_presentState <= WAIT_SAMPLE;
    elsif rising_edge(I_clock) then     -- rising clock edge
      SR_presentState <= SR_futurState;
    end if;
  end process;

  process (SR_presentState, I_inputSampleValid, I_processingDone) is
  begin
    case SR_presentState is

      when WAIT_SAMPLE =>
          if (I_inputSampleValid = '1') then
            SR_futurState <= STORE;
          else
            SR_futurState <= WAIT_SAMPLE;
          end if;
       
      when STORE =>
        SR_futurState <= PROCESSING_LOOP;
     
      when PROCESSING_LOOP =>
          if (I_processingDone = '1') then
            SR_futurState <= OUTPUT;
          else
            SR_futurState <= PROCESSING_LOOP;
          end if;
         
     
      when OUTPUT =>
        SR_futurState <= WAIT_END_SAMPLE;
     
      when WAIT_END_SAMPLE =>
          if (I_inputSampleValid = '0') then
            SR_futurState <= WAIT_SAMPLE;
          else
            SR_futurState <= WAIT_END_SAMPLE;
          end if;

      when others => null;
    end case;
  end process;

  O_loadShift           <= '1' when SR_presentState=STORE else '0';
  O_initAddress         <= '1' when SR_presentState=STORE else '0';
  O_incrAddress         <= '1' when SR_presentState=PROCESSING_LOOP else '0';
  O_initSum             <= '1' when SR_presentState=STORE else '0';
  O_loadSum             <= '1' when SR_presentState=PROCESSING_LOOP else '0';
  O_loadY               <= '1' when SR_presentState=OUTPUT else '0';
  O_FilteredSampleValid <= '1' when SR_presentState=WAIT_END_SAMPLE else '0';




end architecture archi_operativeUnit;
