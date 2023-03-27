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
        i_BpsCnt   :   in  integer;     -- ���ղ����ʼ���ֵ����
        i_Rx       :   in  std_logic;   -- �첽�źţ���ʱ�䲻ͬ��
        i_EN       :   in  std_logic;   -- ����ʹ��0:���ã�1:���� 
        
        o_DataByte :   out std_logic_vector(7 downto 0);
        o_DataFlag :   out std_logic
    );
end Receiver;

architecture Behavioral of Receiver  is
    signal  c_BpsCnt    :   integer     ;    -- �����ⲿ�������ڲ���Ϊ����
    signal  r_BpsCnt    :   integer := 0;    -- ����������ͬĿ�겨����һ��
    
    signal  r_RxSync_1  :   std_logic   :=  '1';  -- ͬ��i_Rx�ź�
    signal  r_RxSYnc_2  :   std_logic   :=  '1';  -- ͬ��r_RxSync_1������ 
    signal  r_RxSync    :   std_logic   :=  '1';  -- ͬ��r_RxSync_1������
    
    signal r_RxStartFlag:   std_logic   :=  '0';  -- ������ ��ʼ���ձ�־ ��Ϊ1ά��һ��sysClk
    signal r_BitCnt     :   integer range 0 to 10           :=   0 ;  -- ����λ������־
    signal r_BitArray_10:   std_logic_vector(9 downto 0)   :=  "0000000000"; -- 10bit���ݣ���Ž��յ�����
    
    type    t_Fsm is (s_Idle, s_Start, s_Data, s_End);
    signal  s_RxFsm     :   t_Fsm := s_Idle;
begin
-- ����߼�
    c_BpsCnt <= i_BpsCnt - 1;
    
-- ʱ���߼�
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
                when s_Idle     =>      -- ** ����״̬ Rx ���ű��ָߵ�ƽ1
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
                   -- ״̬ά�ֺ�ת��
                    if (r_RxStartFlag = '1') then
                        -- NSL next state logic
                        s_RxFsm <= s_Start;
                    else
                        -- SM state memory
                        s_RxFsm <= s_Idle;
                    end if;
                when s_Start    =>      -- ** ����״̬��������ʼλ���ж�Rx�����Ƿ��ɵ�0   bit 1
                    -- OFL
                    if (r_BpsCnt = c_BpsCnt / 2) then
                        r_BpsCnt <= 0;
                        if (i_Rx = '0') then
                            r_BitCnt      <=  1 ;
                            r_BitArray_10(9) <= i_Rx ;  -- ������λ
                        else
                            r_BitCnt      <= 0;
                        end if;
                    else
                        r_BpsCnt <= r_BpsCnt + 1;
                    end if;
                    -- ״̬ά�ֺ�ת��
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
                when s_Data     =>      -- ** ������״̬������8bit����    bit(2-9)
                    -- OFL
                    if (r_BpsCnt = c_BpsCnt) then
                        r_BpsCnt <= 0;
                        r_BitCnt <= r_BitCnt + 1;
                        r_BitArray_10 <= i_Rx & r_BitArray_10(9 downto 1);  -- ������λ
                    else
                        r_BpsCnt <= r_BpsCnt + 1;
                    end if;
                    -- ״̬ά�ֺ�ת��
                    if (r_BpsCnt = c_BpsCnt and r_BitCnt = 8) then
                        -- NSL
                        s_RxFsm <= s_End;
                    else
                        -- SM
                        s_RxFsm <= s_Data;
                    end if;
                when s_End      =>      -- ** ����״̬�����ս���λ���ж�Rx�����Ƿ�Ϊ��1
                    -- OFL
                    if (r_BpsCnt = c_BpsCnt) then
                        r_BpsCnt <= 0;
                        if (i_Rx = '1') then
                            r_BitCnt <= 10;
                            r_BitArray_10 <= i_Rx & r_BitArray_10(9 downto 1);  -- ������λ
                        else
                            r_BitCnt <= 0 ;
                            r_BitArray_10 <= (others => '0');
                        end if;
                    else
                        r_BpsCnt <= r_BpsCnt + 1;
                    end if;
                    -- ״̬ά�ֺ�ת��
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
