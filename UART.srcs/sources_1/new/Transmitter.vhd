----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 马秀峰
-- 
-- Create Date: 2023/02/09 20:37:18
-- Design Name: 
-- Module Name: Transmitter - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Transmitter is
    Port (
        i_SysClk   :   in  std_logic;
        i_SysNrst  :   in  std_logic;
        i_BpsCnt   :   in  integer;     -- 接收波特率计数值参数
        i_DataByte :   in  std_logic_vector(7 downto 0); -- 要发送的数据字节
        i_TxFlag   :   in std_logic;    -- 伴随传入的数据给高脉冲
        i_EN       :   in  std_logic;
        
        o_Tx       :   out std_logic;
        o_TxIdleFlag:  out std_logic
    );
end Transmitter;

architecture Behavioral of Transmitter is
    signal  c_BpsCnt    :   integer;    -- 来自波特率模块，在这内部作为常量
    signal  r_BpsCnt    :   integer :=  0;    -- 用来计数，同目标波特率一致
    
    signal r_BitCnt     :   integer range 0 to 10           :=   0 ;  -- 数据位计数标志
    signal r_BitArray_10:   std_logic_vector(9 downto 0)   :=  "1000000000"; -- 8bit数据，存放接收的数据

        
    type    t_Fsm is (s_Idle, s_Data, s_End);
    signal  s_TxFsm     :   t_Fsm   :=  s_Idle;
    
    signal r_Tx         :   std_logic   :=  '1';    -- 作为 o_Tx的缓冲
    signal r_TxIdleFlag :   std_logic   :=  '0';    -- 作为 o_TxIdleFlag的缓冲 1空闲
    
    signal r_Continue   :   std_logic   :=  '0';
    
begin
-- 组合逻辑
    c_BpsCnt <= i_BpsCnt - 1;
    o_Tx     <= r_Tx;
    o_TxIdleFlag <= r_TxIdleFlag;
    
-- 时序逻辑
    txFsm_proc:process (i_SysClk, i_SysNrst, i_EN)
    begin
        if (i_SysNrst = '0' or i_EN = '0') then
            s_TxFsm       <= s_Idle;
            r_BitArray_10 <= "1000000000";
            --r_TxStartFlag <= '0';
            r_BitCnt      <=  0 ;
            r_BpsCnt      <=  0 ;
            r_Tx          <= '1';
            r_TxIdleFlag  <= '0';
            r_Continue    <= '0';
        elsif (rising_edge(i_SysClk)) then
            case s_TxFsm is
                when s_Idle  =>     -- ** 空闲状态
                    -- OFL
                    r_TxIdleFlag <= '1';
                    r_Continue   <= '0';
                    if (i_TxFlag = '1') then
                        r_BitArray_10(8 downto 1) <= i_DataByte;
                        r_Tx <= r_BitArray_10(r_BitCnt);
                        r_BitCnt <= 1;
                        r_TxIdleFlag  <= '0';
                    end if;
                    
                    -- 状态维持和转移
                    if (i_TxFlag = '1') then
                        -- NSL
                        s_TxFsm <= s_Data;
                    else
                        -- SM
                        s_TxFsm <= s_Idle;
                    end if;
                when s_Data =>     -- ** 发送数据位
                    -- OFL
                    r_Continue <= '0';
                    if (r_BpsCnt = c_BpsCnt) then
                        r_BpsCnt <= 0;
                        if (r_BitCnt = 10) then
                            --r_BitCnt <= 0;
                            if (i_TxFlag = '1' or r_Continue = '1') then
                                r_Continue <= '0';
                                r_BitArray_10(8 downto 1) <= i_DataByte;
                                r_Tx <= r_BitArray_10(0);
                                r_BitCnt <= 1;
                            end if;
                        else
                            r_BitCnt <= r_BitCnt + 1;
                            r_Tx <= r_BitArray_10(r_BitCnt);
                        end if;
                    else
                        r_BpsCnt <= r_BpsCnt + 1;
                        if (r_BitCnt = 10 and i_TxFlag = '1') then
                            r_BitArray_10(8 downto 1) <= i_DataByte;
                            r_Continue <= '1';
                        end if;
                    end if;
                    
                    -- 状态维持和转移
                    if (r_BpsCnt = c_BpsCnt and r_BitCnt = 10) then
                        -- NSL
                        if (r_Continue = '1' or i_TxFlag = '1') then
                            s_TxFsm <=s_Data;
                        else
                            s_TxFsm <= s_End;
                        end if;
                    else
                        -- SM
                        s_TxFsm <= s_Data;
                    end if;
                when s_End   =>     -- ** 发送结束
                    -- OFL
                    if (r_BitCnt = 10) then
                        r_BitCnt <= 0;
                        r_TxIdleFlag <= '1';
                        r_BitArray_10 <= "1000000000";
                    end if;
                    
                    -- 状态维持和转移
                    if( r_BitCnt = 10) then
                        -- NSL
                        s_TxFsm <= s_Idle;
                    else
                        -- SM
                        s_TxFsm <= s_End;
                    end if;
                when others  =>
                    s_TxFsm <= s_Idle;
            end case;
        end if;
    end process txFsm_proc;

end Behavioral;
