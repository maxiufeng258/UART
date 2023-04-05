----------------------------------------------------------------------------------
-- Company: 
-- Engineer: �����
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
        i_BpsCnt   :   in  integer;     -- ���ղ����ʼ���ֵ����
        i_DataByte :   in  std_logic_vector(7 downto 0); -- Ҫ���͵������ֽ�
        i_TxFlag   :   in std_logic;    -- ���洫������ݸ�������
        i_EN       :   in  std_logic;
        
        o_Tx       :   out std_logic;
        o_TxIdleFlag:  out std_logic
    );
end Transmitter;

architecture Behavioral of Transmitter is
    signal  c_BpsCnt    :   integer;    -- ���Բ�����ģ�飬�����ڲ���Ϊ����
    signal  r_BpsCnt    :   integer :=  0;    -- ����������ͬĿ�겨����һ��
    
    signal r_BitCnt     :   integer range 0 to 10           :=   0 ;  -- ����λ������־
    signal r_BitArray_10:   std_logic_vector(9 downto 0)   :=  "1000000000"; -- 8bit���ݣ���Ž��յ�����

        
    type    t_Fsm is (s_Idle, s_Data, s_End);
    signal  s_TxFsm     :   t_Fsm   :=  s_Idle;
    
    signal r_Tx         :   std_logic   :=  '1';    -- ��Ϊ o_Tx�Ļ���
    signal r_TxIdleFlag :   std_logic   :=  '0';    -- ��Ϊ o_TxIdleFlag�Ļ��� 1����
    
    signal r_Continue   :   std_logic   :=  '0';
    
begin
-- ����߼�
    c_BpsCnt <= i_BpsCnt - 1;
    o_Tx     <= r_Tx;
    o_TxIdleFlag <= r_TxIdleFlag;
    
-- ʱ���߼�
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
                when s_Idle  =>     -- ** ����״̬
                    -- OFL
                    r_TxIdleFlag <= '1';
                    r_Continue   <= '0';
                    if (i_TxFlag = '1') then
                        r_BitArray_10(8 downto 1) <= i_DataByte;
                        r_Tx <= r_BitArray_10(r_BitCnt);
                        r_BitCnt <= 1;
                        r_TxIdleFlag  <= '0';
                    end if;
                    
                    -- ״̬ά�ֺ�ת��
                    if (i_TxFlag = '1') then
                        -- NSL
                        s_TxFsm <= s_Data;
                    else
                        -- SM
                        s_TxFsm <= s_Idle;
                    end if;
                when s_Data =>     -- ** ��������λ
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
                    
                    -- ״̬ά�ֺ�ת��
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
                when s_End   =>     -- ** ���ͽ���
                    -- OFL
                    if (r_BitCnt = 10) then
                        r_BitCnt <= 0;
                        r_TxIdleFlag <= '1';
                        r_BitArray_10 <= "1000000000";
                    end if;
                    
                    -- ״̬ά�ֺ�ת��
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
