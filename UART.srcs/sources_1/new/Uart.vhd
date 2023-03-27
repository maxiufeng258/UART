----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2023/02/11 12:47:59
-- Design Name: 
-- Module Name: Uart - Behavioral
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
--  ******* 一帧数据 如：9600 N 8 1 ********************************* --
--  ~~~~~~~\______X------X------X------X------X...........X~~~~~~~~~X--空闲或下一个数据起始
--     1      0     bit0   bit1   bit2   bit3      bit7        1
--   空闲    起始   【LSB     *    * 数据位   *    *    MSB】  空闲

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Uart is
    generic(
        CLK_xHz     :   integer := 50000000;  -- 在实例化时由此给定时钟和目标波特兰参数
        BAUDRATE    :   integer := 115200
    );
    port(
        -- 时钟和复位信号
        i_SysClk    :   in  std_logic;
        i_SysNrst   :   in  std_logic;
        
        -- Rx 相关
        i_Rx        :   in  std_logic;
        i_RxWorkEN  :   in  std_logic;  -- Receiver功能启用和禁用控制
        o_RxDataByte:   out std_logic_vector(7 downto 0);
        o_RxDataFlag:   out std_logic;
        -- Tx 相关
        i_TxDataByte:   in  std_logic_vector(7 downto 0);
        i_TxFlag    :   in  std_logic;
        i_TxWorkEN  :   in  std_logic;  -- Transmitter功能启用和禁用控制
        o_Tx        :   out std_logic;
        o_TxIdleFlag:   out std_logic
    );
end Uart;

architecture Behavioral of Uart is
-- 部件声明
    -- uart接收模块 Receiver
    component Receiver
        Port (
            i_SysClk   :   in  std_logic;
            i_SysNrst  :   in  std_logic;
            i_BpsCnt   :   in  integer;
            i_Rx       :   in  std_logic;   --异步信号，和时间不同步
            i_EN       :   in  std_logic;
        
            o_DataByte :   out std_logic_vector(7 downto 0);
            o_DataFlag :   out std_logic
        );
    end component;
    
    -- uart发送模块 Transmitter
    component Transmitter
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
    end component;

-- 内部信号寄存器
    signal c_BpsCnt :   integer := 0;
begin
-- 计算波特率计数上限
    c_BpsCnt <= CLK_xHz/BAUDRATE;


-- 实例化部件
    UartRx: Receiver
    Port map (
        i_SysClk    => i_SysClk,        
        i_SysNrst   => i_SysNrst,
        i_BpsCnt    => c_BpsCnt,
        i_Rx        => i_Rx,
        i_EN        => i_RxWorkEN,    
        
        o_DataByte  => o_RxDataByte ,
        o_DataFlag  => o_RxDataFlag  
    );
    
    UartTx: Transmitter
    Port map (
        i_SysClk   => i_SysCLk,
        i_SysNrst  => i_SysNrst,
        i_BpsCnt   => c_BpsCnt,
        i_DataByte => i_TxDataByte,
        i_TxFlag   => i_TxFlag,
        i_EN       => i_TxWorkEN,

        o_Tx       => o_Tx,
        o_TxIdleFlag=>o_TxIdleFlag
       );

end Behavioral;
