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
--  ******* һ֡���� �磺9600 N 8 1 ********************************* --
--  ~~~~~~~\______X------X------X------X------X...........X~~~~~~~~~X--���л���һ��������ʼ
--     1      0     bit0   bit1   bit2   bit3      bit7        1
--   ����    ��ʼ   ��LSB     *    * ����λ   *    *    MSB��  ����

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
        CLK_xHz     :   integer := 50000000;  -- ��ʵ����ʱ�ɴ˸���ʱ�Ӻ�Ŀ�겨��������
        BAUDRATE    :   integer := 115200
    );
    port(
        -- ʱ�Ӻ͸�λ�ź�
        i_SysClk    :   in  std_logic;
        i_SysNrst   :   in  std_logic;
        
        -- Rx ���
        i_Rx        :   in  std_logic;
        i_RxWorkEN  :   in  std_logic;  -- Receiver�������úͽ��ÿ���
        o_RxDataByte:   out std_logic_vector(7 downto 0);
        o_RxDataFlag:   out std_logic;
        -- Tx ���
        i_TxDataByte:   in  std_logic_vector(7 downto 0);
        i_TxFlag    :   in  std_logic;
        i_TxWorkEN  :   in  std_logic;  -- Transmitter�������úͽ��ÿ���
        o_Tx        :   out std_logic;
        o_TxIdleFlag:   out std_logic
    );
end Uart;

architecture Behavioral of Uart is
-- ��������
    -- uart����ģ�� Receiver
    component Receiver
        Port (
            i_SysClk   :   in  std_logic;
            i_SysNrst  :   in  std_logic;
            i_BpsCnt   :   in  integer;
            i_Rx       :   in  std_logic;   --�첽�źţ���ʱ�䲻ͬ��
            i_EN       :   in  std_logic;
        
            o_DataByte :   out std_logic_vector(7 downto 0);
            o_DataFlag :   out std_logic
        );
    end component;
    
    -- uart����ģ�� Transmitter
    component Transmitter
        Port (
            i_SysClk   :   in  std_logic;
            i_SysNrst  :   in  std_logic;
            i_BpsCnt   :   in  integer;     -- ���ղ����ʼ���ֵ����
            i_DataByte :   in  std_logic_vector(7 downto 0); -- Ҫ���͵������ֽ�
            i_TxFlag   :   in std_logic;    -- ���洫������ݸ�������
            i_EN       :   in  std_logic;
        
            o_Tx       :   out std_logic;
            o_TxIdleFlag:  out std_logic
        );
    end component;

-- �ڲ��źżĴ���
    signal c_BpsCnt :   integer := 0;
begin
-- ���㲨���ʼ�������
    c_BpsCnt <= CLK_xHz/BAUDRATE;


-- ʵ��������
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
