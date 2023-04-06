----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2023/02/09 20:29:25
-- Design Name: 
-- Module Name: baudRate_tb - Behavioral
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

entity baudRate_tb is
--  Port ( );
end baudRate_tb;

architecture Behavioral of baudRate_tb is
    
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
    
    component Transmitter
    port(
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
    
    
    component Uart
        generic(
            CLK_xHz     :   integer;  -- ��ʵ����ʱ�ɴ˸���ʱ�Ӻ�Ŀ�겨��������
            BAUDRATE    :   integer
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
    end component;
    
    signal clk:std_logic;
    signal nrst:std_logic;
    signal rx_data: std_logic := '1';
    
    signal rxdata: std_logic_vector(7 downto 0);
    signal rxflag : std_logic;
    
    signal txdata : std_logic_vector(7 downto 0) := "00000000";
    signal txflag : std_logic;
    
    signal c_uartBaudCnt : time := 20* 434ns;
    
    signal rx_en : std_logic:='1';
    
    signal o_txPin: std_logic;
    signal r_txFlag:std_logic ;
    signal o_txIdleFlag : std_logic;
    signal r_DataByte: std_logic_vector(7 downto 0) := x"00";
    
    type t_Fsm is (s1,s2,s3);
    signal s_Fsm : t_Fsm := s1;
begin

    clk_proc :process
    begin
        clk <= '0';
        wait for 10ns;
        clk <= '1';
        wait for 10ns;
    end process clk_proc;

    process
    begin
        nrst <= '0';
        wait for 35ns;
        nrst <= '1';
        wait;
    end process;

    process
    begin
        wait for 13ns;
        rx_data <= '0'; --start
        wait for c_uartBaudCnt;
        rx_data <= '1';
        wait for c_uartBaudCnt;
        rx_data <= '0';
        wait for c_uartBaudCnt;
        rx_data <= '1';
        wait for c_uartBaudCnt;
        rx_data <= '0';
        wait for c_uartBaudCnt;
        rx_data <= '1';
        wait for c_uartBaudCnt;
        rx_data <= '0';
        wait for c_uartBaudCnt;
        rx_data <= '0';
        wait for c_uartBaudCnt;
        rx_data <= '0';
        wait for c_uartBaudCnt;
        rx_data <= '1'; --stop
        
        wait for 70ns;
        wait for c_uartBaudCnt;
        rx_en <= '1';
        --rx_data <= '1';
        wait for c_uartBaudCnt;
        rx_data <= '0'; --start
        wait for c_uartBaudCnt;
        rx_data <= '1';
        wait for c_uartBaudCnt;
        rx_data <= '1';
        wait for c_uartBaudCnt;
        rx_data <= '0';
        wait for c_uartBaudCnt;
        rx_data <= '1';
        wait for c_uartBaudCnt;
        rx_data <= '1';
        wait for c_uartBaudCnt;
        rx_data <= '1';
        wait for c_uartBaudCnt;
        rx_data <= '0';
        wait for c_uartBaudCnt;
        rx_data <= '0';
        wait for c_uartBaudCnt;
        rx_data <= '1'; --stop
        
        wait for c_uartBaudCnt;
        rx_data <= '0'; -- start
        wait for c_uartBaudCnt;
        rx_data <= '1';
        wait for c_uartBaudCnt;
        rx_data <= '0';
        wait for c_uartBaudCnt;
        rx_data <= '1';
        wait for c_uartBaudCnt;
        rx_data <= '0';
        wait for c_uartBaudCnt;
        rx_data <= '0';
        wait for c_uartBaudCnt;
        rx_data <= '1';
        wait for c_uartBaudCnt;
        rx_data <= '0';
        wait for c_uartBaudCnt;
        rx_data <= '1';
        wait for c_uartBaudCnt;
        rx_data <= '1'; --stop

        wait for c_uartBaudCnt;
        rx_data <= '0'; -- start
        wait for c_uartBaudCnt;
        rx_data <= '1';
        wait for c_uartBaudCnt;
        rx_data <= '1';
        wait for c_uartBaudCnt;
        rx_data <= '0';
        wait for c_uartBaudCnt;
        rx_data <= '1';
        wait for c_uartBaudCnt;
        rx_data <= '0';
        wait for c_uartBaudCnt;
        rx_data <= '1';
        wait for c_uartBaudCnt;
        rx_data <= '0';
        wait for c_uartBaudCnt;
        rx_data <= '1';
        wait for c_uartBaudCnt;
        rx_data <= '1'; --stop

        
        wait for 10us;
        wait for c_uartBaudCnt;
        rx_data <= '0'; -- start
        wait for c_uartBaudCnt;
        rx_data <= '1';
        wait for c_uartBaudCnt;
        rx_data <= '1';
        wait for c_uartBaudCnt;
        rx_data <= '0';
        wait for c_uartBaudCnt;
        rx_data <= '1';
        wait for c_uartBaudCnt;
        rx_data <= '0';
        wait for c_uartBaudCnt;
        rx_data <= '1';
        wait for c_uartBaudCnt;
        rx_data <= '1';
        wait for c_uartBaudCnt;
        rx_data <= '0';
        wait for c_uartBaudCnt;
        rx_data <= '1'; --stop
        
        wait for c_uartBaudCnt;
        rx_data <= '0'; -- start
        wait for c_uartBaudCnt;
        rx_data <= '1';
        wait for c_uartBaudCnt;
        rx_data <= '1';
        wait for c_uartBaudCnt;
        rx_data <= '0';
        wait for c_uartBaudCnt;
        rx_data <= '1';
        wait for c_uartBaudCnt;
        rx_data <= '0';
        wait for c_uartBaudCnt;
        rx_data <= '1';
        wait for c_uartBaudCnt;
        rx_data <= '0';
        wait for c_uartBaudCnt;
        rx_data <= '1';
        wait for c_uartBaudCnt;
        rx_data <= '1'; --stop
        
        wait for 30200ns;
        rx_en <= '0';
        wait;
    end process;
    
    process(clk)
    begin
        if (rising_edge(clk)) then
            case s_Fsm is
                when s1 =>
                txflag <= '0';
                    if (rxflag = '1') then
                        s_Fsm <= s2;
                    else
                        s_Fsm <= s1;
                    end if;
                when s2 =>
                    if (o_TxIdleFlag='1') then
                        txflag <= '1';
                        txdata <= rxdata;
                        s_Fsm <= s1;
                    else
                        txflag <= '0';
                        s_Fsm <= s2;
                    end if;
                when others =>
                    s_Fsm <= s1;
            end case;
        end if;
    end process;

--    process
--    begin
--        r_txFlag <= '0';
--        r_DataByte <= x"00";
--        wait for 100ns;
--        r_txFlag <= '1';
--        r_DataByte <= x"AC";
--        wait for 20ns;
--        r_txFlag <= '0';
--        wait for 5208*10*20ns;
--        wait for 30ns;
--        r_txFlag <= '1';
--        r_DataByte <= x"0F";
--        wait for 20ns;
--        r_txFlag <= '0';
--        wait;
--    end process;
    
--    Rx: Receiver
--    Port map (
--        i_SysClk => clk,        
--        i_SysNrst      => nrst,
--        i_BpsCnt   => 50000000/115200,
--        i_Rx    => rx_data,
--        i_EN    => '1', 
        
--        o_DataByte => rxdata  ,
--        o_DataFlag  => rxflag  
--    );

--    Tx: Transmitter
--    Port map(
--        i_SysClk   => clk,
--        i_SysNrst  => nrst,
--        i_BpsCnt   => 50000000/9600,   -- ���ղ����ʼ���ֵ����
--        i_DataByte => r_DataByte,   -- Ҫ���͵������ֽ�
--        i_TxFlag   => r_TxFlag,   -- ���洫������ݸ�������
--        i_EN       => '1',
        
--        o_Tx       => o_txPin,
--        o_TxIdleFlag => o_TxIdleFlag
--     );

        uart_tb:Uart
        generic map(
            CLK_xHz     => 50000000,  -- ��ʵ����ʱ�ɴ˸���ʱ�Ӻ�Ŀ�겨��������
            BAUDRATE    => 115200
        )
        port map(
            i_SysClk   => clk,
            i_SysNrst   => nrst,
        -- Rx ���
            i_Rx        => rx_data,
            i_RxWorkEN  => rx_en,  -- Receiver�������úͽ��ÿ���
            o_RxDataByte=>rxdata,
            o_RxDataFlag=>rxflag,
            -- Tx ���
            i_TxDataByte=> txdata,
            i_TxFlag    => txflag,
            i_TxWorkEN  =>  '1',  -- Transmitter�������úͽ��ÿ���
            o_Tx        => o_txPin,
            o_TxIdleFlag=> o_TxIdleFlag
        );

end Behavioral;
