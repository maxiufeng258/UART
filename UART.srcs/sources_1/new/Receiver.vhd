----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2023/02/09 20:46:27
-- Design Name: 
-- Module Name: Receiver - Behavioral
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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Receiver is
    Port (
        i_SysClk   :   in  std_logic;
        i_SysNrst  :   in  std_logic;
        i_BpsCnt   :   in  integer;     -- 接收波特率计数值参数
        i_Rx       :   in  std_logic;   -- 异步信号，和时间不同步
        i_EN       :   in  std_logic;   -- 接收使能0:禁用，1:启用 
        
        o_DataByte :   out std_logic_vector(7 downto 0);
        o_DataFlag :   out std_logic
    );
end Receiver;

architecture Behavioral of Receiver  is
    signal  c_BpsCnt    :   integer     ;    -- 来自外部，在这内部作为常量
    signal  r_BpsCnt    :   integer := 0;    -- 用来计数，同目标波特率一致
    
    signal  r_RxSync_1  :   std_logic   :=  '1';  -- 同步i_Rx信号
    signal  r_RxSYnc_2  :   std_logic   :=  '1';  -- 同步r_RxSync_1，打拍 
    signal  r_RxSync    :   std_logic   :=  '1';  -- 同步r_RxSync_1，打拍
    
    signal r_RxStartFlag:   std_logic   :=  '0';  -- 有数据 开始接收标志 置为1维持一个sysClk
    signal r_BitCnt     :   integer range 0 to 10           :=   0 ;  -- 数据位计数标志
    signal r_BitArray_10:   std_logic_vector(9 downto 0)   :=  "0000000000"; -- 10bit数据，存放接收的数据
    
    type    t_Fsm is (s_Idle, s_Start, s_Data, s_End);
    signal  s_RxFsm     :   t_Fsm := s_Idle;
begin
-- 组合逻辑
    c_BpsCnt <= i_BpsCnt - 1;
    
-- 时序逻辑
    sync_proc:process (i_SysClk, i_SysNrst, i_EN)
    begin
        if (i_SysNrst = '0' or i_EN = '0') then
            r_RxSync_1 <= '1';
            r_RxSYnc_2 <= '1';
            r_RxSync   <= '1';
        elsif (rising_edge(i_SysClk)) then
            r_RxSync_1 <= i_Rx;
            r_RxSYnc_2 <= r_RxSync_1;
            r_RxSync   <= r_RxSync_2;
        end if;
    end process sync_proc;
    
    rxFsm_proc:process (i_SysClk, i_SysNrst, i_EN)
    begin
        if (i_SysNrst = '0' or i_EN = '0') then
            s_RxFsm         <= s_Idle;
            r_RxStartFlag   <= '0';
            r_BitCnt        <=  0 ;
            r_BitArray_10   <= (others => '0');
        elsif (rising_edge(i_SysClk)) then
            case s_RxFsm is
                when s_Idle     =>      -- ** 空闲状态 Rx 引脚保持高电平1
                    -- OFL output function logic
                    if(r_RxStartFlag = '1') then
                        r_BitCnt <= 0;
                        r_RxStartFlag <= '0';
                    else
                        if (r_RxSync = '1' and  r_RxSync_2 = '0') then
                            r_RxStartFlag <= '1';
                        else
                            r_RxStartFlag <= '0';
                        end if;
                    end if;
                    if (r_BitCnt = 10) then
                        r_BitCnt <= 0;
                        r_BitArray_10 <= (others => '0');
                    else
                        r_BitCnt <= r_BitCnt;
                    end if;
                   -- 状态维持和转移
                    if (r_RxStartFlag = '1') then
                        -- NSL next state logic
                        s_RxFsm <= s_Start;
                    else
                        -- SM state memory
                        s_RxFsm <= s_Idle;
                    end if;
                when s_Start    =>      -- ** 启动状态，接收起始位，判断Rx引脚是否变成低0   bit 1
                    -- OFL
                    if (r_BpsCnt = c_BpsCnt / 2) then
                        r_BpsCnt <= 0;
                        if (i_Rx = '0') then
                            r_BitCnt      <=  1 ;
                            r_BitArray_10(9) <= i_Rx ;  -- 存数据位
                        else
                            r_BitCnt      <= 0;
                        end if;
                    else
                        r_BpsCnt <= r_BpsCnt + 1;
                    end if;
                    -- 状态维持和转移
                    if (r_BpsCnt = c_BpsCnt / 2) then
                        -- NSL
                        if (i_Rx = '0') then
                            s_RxFsm <= s_Data;
                        else
                            s_RxFsm <= s_Idle;
                        end if;
                    else
                        -- SM
                        s_RxFsm <= s_Start;
                    end if;
                when s_Data     =>      -- ** 收数据状态，接收8bit数据    bit(2-9)
                    -- OFL
                    if (r_BpsCnt = c_BpsCnt) then
                        r_BpsCnt <= 0;
                        r_BitCnt <= r_BitCnt + 1;
                        r_BitArray_10 <= i_Rx & r_BitArray_10(9 downto 1);  -- 存数据位
                    else
                        r_BpsCnt <= r_BpsCnt + 1;
                    end if;
                    -- 状态维持和转移
                    if (r_BpsCnt = c_BpsCnt and r_BitCnt = 8) then
                        -- NSL
                        s_RxFsm <= s_End;
                    else
                        -- SM
                        s_RxFsm <= s_Data;
                    end if;
                when s_End      =>      -- ** 结束状态，接收结束位，判断Rx引脚是否为高1
                    -- OFL
                    if (r_BpsCnt = c_BpsCnt) then
                        r_BpsCnt <= 0;
                        if (i_Rx = '1') then
                            r_BitCnt <= 10;
                            r_BitArray_10 <= i_Rx & r_BitArray_10(9 downto 1);  -- 存数据位
                        else
                            r_BitCnt <= 0 ;
                            r_BitArray_10 <= (others => '0');
                        end if;
                    else
                        r_BpsCnt <= r_BpsCnt + 1;
                    end if;
                    -- 状态维持和转移
                    if (r_BpsCnt = c_BpsCnt) then
                        -- NSL
                        s_RxFsm <= s_Idle;
                    else
                        -- SM
                        s_RxFsm <= s_End;
                    end if;
                    
                when others     =>
                    s_RxFsm <= s_Idle;
            end case;
        end if;
    end process rxFsm_proc;
    
    rxData_Proc:process (i_SysNrst, i_SysClk, i_EN)
    begin
        if (i_SysNrst = '0' or i_EN = '0') then
            o_DataFlag <= '0';
            o_DataByte <= (others => '0');
        elsif (rising_edge(i_SysClk)) then
            if (s_RxFsm = s_Idle and r_BitCnt = 10) then
                o_DataFlag <= '1';
                o_DataByte <= r_BitArray_10(8 downto 1);
            else
                o_DataFlag <= '0';
            end if;
        end if;
    end process rxData_Proc;
    
end Behavioral;
