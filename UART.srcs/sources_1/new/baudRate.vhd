----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2023/02/08 21:59:20
-- Design Name: 
-- Module Name: baudRate - Behavioral
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
use IEEE.numeric_std.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity baudRate is
    generic (
        CLK_xHz     :   integer :=   50000000;  -- ��ʵ����ʱ�ɴ˸���ʱ�Ӻ�Ŀ�겨��������
        BAUDRATE    :   integer :=   115200
    );
    port (
        o_bpsCnt  :   out integer     -- һ������/�����ڸ���ʱ����ָ��������ʱ��Ҫ��������
    );
end baudRate;

architecture Behavioral of baudRate is

begin
    o_bpsCnt <= CLK_xHz / BAUDRATE;
end Behavioral;
