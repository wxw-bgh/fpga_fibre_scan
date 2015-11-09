--*****************************************************************************
--  @Copyright 2010 by guyoubao, All rights reserved.                    
--  Module name : Pulse control
--  Call by     : 
--  Description :
--  IC          : EP3C16F484C6
--  Version     : A                                                   
--  Note:       : 
--  Author      : guyoubao 
--  Date        : 2010.08.28                                                  
--  Update      :   
--               160MHz-- 38M peak, 11-68M -6dB
--               O_trig(0-1)    --  A1 
--               O_trig(14-15)  --  A8 
--                
--*****************************************************************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity pulse is
port
(
    I_clk         :   in    std_logic;
    I_reset_n     :   in    std_logic;       
    I_pulse_trig  :   in    std_logic;
    
    O_pulse       :   out std_logic_vector(3 downto 0)                    
);
end pulse;

architecture ARC_pulse of pulse is

signal S_cnt        : std_logic_vector(7 downto 0);
signal s_case       : std_logic_vector(1 downto 0);
signal s_pulse_buf  : std_logic; 
signal s_pulse      : std_logic_vector(3 downto 0);



begin



O_pulse <= s_pulse;



process(I_reset_n,I_clk)
begin
  if I_reset_n = '0' then
    s_case <= (others=>'0');
    S_cnt <= (others=>'0');
    s_pulse(0) <= '0';             
    s_pulse(1) <= '1'; 
    s_pulse(2) <= '0'; 
    s_pulse_buf <= '0';
  elsif rising_edge(I_clk) then
    
    s_pulse_buf <= I_pulse_trig;
  
    case s_case is
      when "00" =>                             
        if(s_pulse_buf = '0' and I_pulse_trig = '1')then        --rise
            s_case <= "01";
            S_cnt <= S_cnt + '1';
        else              
            s_case <= (others=>'0');
            S_cnt <= (others=>'0');
            s_pulse(0) <= '0';             
            s_pulse(1) <= '0'; 
            s_pulse(2) <= '0'; 
        end if;
        
      when "01" => -- 60M时钟，5M发射，6个N6个P6个拉回零，可结合TC8220的发射时序，6个N+6个P=12个周期，60/12=5M，即为发射频率。
        S_cnt <= S_cnt + '1';  
        
        
        if(S_cnt >= 5 and S_cnt <= 10)then        
            s_pulse(0) <= '1'; 
        else
            s_pulse(0) <= '0';
        end if;   
        if(S_cnt >= 11 and S_cnt <= 16)then                   --monocycle, positive first
            s_pulse(1) <= '1';
        else
            s_pulse(1) <= '0';
        end if;
  		           
        if(S_cnt >= 17 and S_cnt <= 22)then        
            s_pulse(2) <= '1'; 
        else
            s_pulse(2) <= '0';
        end if;             
             
        if(S_cnt = 0)then        
            s_case <= (others=>'0');
        end if;                                  
         
      when others =>            
        s_case     <= (others=>'0');
        S_cnt      <= (others=>'0');
        s_pulse(0) <= '0';             
        s_pulse(1) <= '0';
        s_pulse(2) <= '0'; 
          
    end case;
	 

  end if;
  
  
end process;


--process(I_reset,I_clk)
--begin
--  if I_reset = '0' then
--    s_case <= (others=>'0');
--    S_cnt <= (others=>'0');
--    s_pulse(0) <= '0';             
--    s_pulse(1) <= '1'; 
--    s_pulse_buf <= '0';
--  elsif rising_edge(I_clk) then
--    
--    s_pulse_buf <= I_pulse_trig;
--  
--    case s_case is
--      when "00" =>                             
--        if(s_pulse_buf = '0' and I_pulse_trig = '1')then     
--            s_case <= "01";
--            S_cnt <= S_cnt + '1';
--        else              
--            s_case <= (others=>'0');
--            S_cnt <= (others=>'0');
--            s_pulse(0) <= '0';             
--            s_pulse(1) <= '1'; 
--        end if;
--        
--      when "01" =>
--        S_cnt <= S_cnt + '1';  
--        if(S_cnt >= 4 and S_cnt <= 5)then                   --monocycle, positive first   35MHz at 300MHz clk
--            s_pulse(1) <= '0';
--        else
--            s_pulse(1) <= '1';
--        end if;
--        
--        if(S_cnt >= 2 and S_cnt <= 3)then        
--            s_pulse(0) <= '1'; 
--        else
--            s_pulse(0) <= '0';
--        end if;                 
--             
--        if(S_cnt = 0)then        
--            s_case <= (others=>'0');
--        end if;                                  
--         
--      when others =>            
--        s_case <= (others=>'0');
--        S_cnt <= (others=>'0');
--        s_pulse(0) <= '0';             
--        s_pulse(1) <= '1';
--          
--    end case;
--
--  end if;
--end process;
    
end ARC_pulse;