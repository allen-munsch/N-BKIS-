library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.nebkiso_pkg.all;
use work.nebkiso_types.all;
entity nebkiso_top is
  port (
    clk_in: in std_logic;
    ext_rst_n: in std_logic;
    watchdog_kick: out std_logic;
    watchdog_error: in std_logic;
    adc_spi_sclk: out std_logic;
    adc_spi_mosi: out std_logic;
    adc_spi_miso: in std_logic;
    adc_spi_cs_n: out std_logic_vector (7 downto 0);
    scl: inout std_logic_vector (3 downto 0);
    sda: inout std_logic_vector (3 downto 0);
    flow_pulse: in std_logic_vector (7 downto 0);
    emergency_stop_a: out std_logic;
    emergency_stop_b: out std_logic;
    ventilation_on_a: out std_logic;
    ventilation_on_b: out std_logic;
    chamber_shut_a: out std_logic_vector (NUM_CHAMBERS - 1 downto 0);
    chamber_shut_b: out std_logic_vector (NUM_CHAMBERS - 1 downto 0);
    operational_mode: in std_logic_vector (1 downto 0);
    self_test_req: in std_logic;
    error_reset: in std_logic;
    cal_mode: in std_logic;
    cal_data: in std_logic_vector (15 downto 0);
    cal_addr: in std_logic_vector (7 downto 0);
    cal_wr: in std_logic;
    voc_threshold: in std_logic_vector (11 downto 0);
    aq_threshold: in std_logic_vector (11 downto 0);
    press_threshold: in std_logic_vector (11 downto 0);
    temp_threshold: in std_logic_vector (11 downto 0);
    flow_threshold: in std_logic_vector (7 downto 0);
    uart_rx: in std_logic;
    uart_tx: out std_logic;
    system_status: out std_logic_vector (7 downto 0);
    error_code: out std_logic_vector (7 downto 0);
    heartbeat: out std_logic
  );
end nebkiso_top;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_controller_868 is
  port (
    clk : in std_logic;
    rst : in std_logic;
    rx : in std_logic;
    tx_data : in std_logic_vector (7 downto 0);
    tx_start : in std_logic;
    tx : out std_logic;
    tx_busy : out std_logic;
    rx_data : out std_logic_vector (7 downto 0);
    rx_done : out std_logic);
end entity uart_controller_868;

architecture rtl of uart_controller_868 is
  signal tx_state : std_logic_vector (1 downto 0);
  signal rx_state : std_logic_vector (1 downto 0);
  signal rx_clk_count : std_logic_vector (9 downto 0);
  signal rx_bit_index : std_logic_vector (2 downto 0);
  signal rx_buffer : std_logic_vector (7 downto 0);
  signal rx_sync : std_logic_vector (1 downto 0);
  signal tx_clk_count : std_logic_vector (9 downto 0);
  signal tx_bit_index : std_logic_vector (2 downto 0);
  signal tx_buffer : std_logic_vector (7 downto 0);
  signal n1187_o : std_logic;
  signal n1190_o : std_logic;
  signal n1193_o : std_logic_vector (1 downto 0);
  signal n1194_o : std_logic_vector (7 downto 0);
  signal n1196_o : std_logic;
  signal n1197_o : std_logic_vector (31 downto 0);
  signal n1199_o : std_logic;
  signal n1200_o : std_logic_vector (31 downto 0);
  signal n1202_o : std_logic_vector (31 downto 0);
  signal n1203_o : std_logic_vector (9 downto 0);
  signal n1205_o : std_logic_vector (1 downto 0);
  signal n1207_o : std_logic_vector (9 downto 0);
  signal n1209_o : std_logic;
  signal n1212_o : std_logic_vector (31 downto 0);
  signal n1214_o : std_logic;
  signal n1215_o : std_logic_vector (31 downto 0);
  signal n1217_o : std_logic;
  signal n1218_o : std_logic_vector (31 downto 0);
  signal n1220_o : std_logic_vector (31 downto 0);
  signal n1221_o : std_logic_vector (2 downto 0);
  signal n1223_o : std_logic_vector (1 downto 0);
  signal n1225_o : std_logic_vector (2 downto 0);
  signal n1226_o : std_logic_vector (31 downto 0);
  signal n1228_o : std_logic_vector (31 downto 0);
  signal n1229_o : std_logic_vector (9 downto 0);
  signal n1230_o : std_logic;
  signal n1232_o : std_logic_vector (9 downto 0);
  signal n1233_o : std_logic_vector (2 downto 0);
  signal n1235_o : std_logic;
  signal n1236_o : std_logic_vector (31 downto 0);
  signal n1238_o : std_logic;
  signal n1239_o : std_logic_vector (31 downto 0);
  signal n1241_o : std_logic_vector (31 downto 0);
  signal n1242_o : std_logic_vector (9 downto 0);
  signal n1244_o : std_logic_vector (1 downto 0);
  signal n1245_o : std_logic_vector (9 downto 0);
  signal n1247_o : std_logic;
  signal n1248_o : std_logic_vector (3 downto 0);
  signal n1253_o : std_logic;
  signal n1255_o : std_logic;
  signal n1257_o : std_logic_vector (1 downto 0);
  signal n1260_o : std_logic_vector (9 downto 0);
  signal n1263_o : std_logic_vector (2 downto 0);
  signal n1265_o : std_logic_vector (7 downto 0);
  signal n1285_q : std_logic;
  signal n1286_q : std_logic;
  signal n1287_q : std_logic_vector (1 downto 0);
  signal n1288_q : std_logic_vector (9 downto 0);
  signal n1289_q : std_logic_vector (2 downto 0);
  signal n1290_q : std_logic_vector (7 downto 0);
  signal n1292_o : std_logic;
  signal n1293_o : std_logic;
  signal n1294_o : std_logic_vector (1 downto 0);
  signal n1295_o : std_logic;
  signal n1296_o : std_logic;
  signal n1298_o : std_logic_vector (1 downto 0);
  signal n1300_o : std_logic;
  signal n1301_o : std_logic_vector (31 downto 0);
  signal n1303_o : std_logic;
  signal n1304_o : std_logic;
  signal n1305_o : std_logic;
  signal n1308_o : std_logic_vector (1 downto 0);
  signal n1310_o : std_logic_vector (9 downto 0);
  signal n1311_o : std_logic_vector (31 downto 0);
  signal n1313_o : std_logic_vector (31 downto 0);
  signal n1314_o : std_logic_vector (9 downto 0);
  signal n1315_o : std_logic_vector (1 downto 0);
  signal n1316_o : std_logic_vector (9 downto 0);
  signal n1318_o : std_logic;
  signal n1319_o : std_logic_vector (31 downto 0);
  signal n1321_o : std_logic;
  signal n1323_o : std_logic;
  signal n1325_o : std_logic_vector (31 downto 0);
  signal n1327_o : std_logic;
  signal n1328_o : std_logic_vector (31 downto 0);
  signal n1330_o : std_logic_vector (31 downto 0);
  signal n1331_o : std_logic_vector (2 downto 0);
  signal n1333_o : std_logic_vector (1 downto 0);
  signal n1335_o : std_logic_vector (2 downto 0);
  signal n1336_o : std_logic_vector (31 downto 0);
  signal n1338_o : std_logic_vector (31 downto 0);
  signal n1339_o : std_logic_vector (9 downto 0);
  signal n1340_o : std_logic;
  signal n1342_o : std_logic_vector (9 downto 0);
  signal n1343_o : std_logic_vector (2 downto 0);
  signal n1344_o : std_logic_vector (7 downto 0);
  signal n1346_o : std_logic;
  signal n1347_o : std_logic_vector (31 downto 0);
  signal n1349_o : std_logic;
  signal n1350_o : std_logic;
  signal n1351_o : std_logic_vector (7 downto 0);
  signal n1354_o : std_logic;
  signal n1355_o : std_logic_vector (31 downto 0);
  signal n1357_o : std_logic_vector (31 downto 0);
  signal n1358_o : std_logic_vector (9 downto 0);
  signal n1359_o : std_logic;
  signal n1361_o : std_logic;
  signal n1363_o : std_logic_vector (1 downto 0);
  signal n1365_o : std_logic_vector (9 downto 0);
  signal n1367_o : std_logic;
  signal n1368_o : std_logic_vector (3 downto 0);
  signal n1370_o : std_logic_vector (7 downto 0);
  signal n1373_o : std_logic;
  signal n1376_o : std_logic_vector (1 downto 0);
  signal n1379_o : std_logic_vector (9 downto 0);
  signal n1382_o : std_logic_vector (2 downto 0);
  signal n1384_o : std_logic_vector (7 downto 0);
  signal n1407_q : std_logic_vector (7 downto 0);
  signal n1408_q : std_logic;
  signal n1409_q : std_logic_vector (1 downto 0);
  signal n1410_q : std_logic_vector (9 downto 0);
  signal n1411_q : std_logic_vector (2 downto 0);
  signal n1412_q : std_logic_vector (7 downto 0);
  signal n1413_q : std_logic_vector (1 downto 0);
  signal n1414_o : std_logic;
  signal n1415_o : std_logic;
  signal n1416_o : std_logic;
  signal n1417_o : std_logic;
  signal n1418_o : std_logic;
  signal n1419_o : std_logic;
  signal n1420_o : std_logic;
  signal n1421_o : std_logic;
  signal n1422_o : std_logic_vector (1 downto 0);
  signal n1423_o : std_logic;
  signal n1424_o : std_logic_vector (1 downto 0);
  signal n1425_o : std_logic;
  signal n1426_o : std_logic;
  signal n1427_o : std_logic;
  signal n1428_o : std_logic;
  signal n1429_o : std_logic;
  signal n1430_o : std_logic;
  signal n1431_o : std_logic;
  signal n1432_o : std_logic;
  signal n1433_o : std_logic;
  signal n1434_o : std_logic;
  signal n1435_o : std_logic;
  signal n1436_o : std_logic;
  signal n1437_o : std_logic;
  signal n1438_o : std_logic;
  signal n1439_o : std_logic;
  signal n1440_o : std_logic;
  signal n1441_o : std_logic;
  signal n1442_o : std_logic;
  signal n1443_o : std_logic;
  signal n1444_o : std_logic;
  signal n1445_o : std_logic;
  signal n1446_o : std_logic;
  signal n1447_o : std_logic;
  signal n1448_o : std_logic;
  signal n1449_o : std_logic;
  signal n1450_o : std_logic;
  signal n1451_o : std_logic;
  signal n1452_o : std_logic;
  signal n1453_o : std_logic;
  signal n1454_o : std_logic;
  signal n1455_o : std_logic;
  signal n1456_o : std_logic;
  signal n1457_o : std_logic;
  signal n1458_o : std_logic;
  signal n1459_o : std_logic;
  signal n1460_o : std_logic;
  signal n1461_o : std_logic;
  signal n1462_o : std_logic_vector (7 downto 0);
begin
  tx <= n1285_q;
  tx_busy <= n1286_q;
  rx_data <= n1407_q;
  rx_done <= n1408_q;
  -- ../src/hdl/interfaces/uart_controller.vhd:27:12
  tx_state <= n1287_q; -- (signal)
  -- ../src/hdl/interfaces/uart_controller.vhd:28:12
  rx_state <= n1409_q; -- (signal)
  -- ../src/hdl/interfaces/uart_controller.vhd:31:12
  rx_clk_count <= n1410_q; -- (signal)
  -- ../src/hdl/interfaces/uart_controller.vhd:32:12
  rx_bit_index <= n1411_q; -- (signal)
  -- ../src/hdl/interfaces/uart_controller.vhd:33:12
  rx_buffer <= n1412_q; -- (signal)
  -- ../src/hdl/interfaces/uart_controller.vhd:34:12
  rx_sync <= n1413_q; -- (signal)
  -- ../src/hdl/interfaces/uart_controller.vhd:37:12
  tx_clk_count <= n1288_q; -- (signal)
  -- ../src/hdl/interfaces/uart_controller.vhd:38:12
  tx_bit_index <= n1289_q; -- (signal)
  -- ../src/hdl/interfaces/uart_controller.vhd:39:12
  tx_buffer <= n1290_q; -- (signal)
  -- ../src/hdl/interfaces/uart_controller.vhd:53:15
  n1187_o <= '1' when rising_edge (clk) else '0';
  -- ../src/hdl/interfaces/uart_controller.vhd:61:21
  n1190_o <= '0' when tx_start = '0' else '1';
  -- ../src/hdl/interfaces/uart_controller.vhd:61:21
  n1193_o <= tx_state when tx_start = '0' else "01";
  -- ../src/hdl/interfaces/uart_controller.vhd:61:21
  n1194_o <= tx_buffer when tx_start = '0' else tx_data;
  -- ../src/hdl/interfaces/uart_controller.vhd:55:17
  n1196_o <= '1' when tx_state = "00" else '0';
  -- ../src/hdl/interfaces/uart_controller.vhd:70:37
  n1197_o <= "0000000000000000000000" & tx_clk_count;  --  uext
  -- ../src/hdl/interfaces/uart_controller.vhd:70:37
  n1199_o <= '1' when n1197_o = "00000000000000000000001101100011" else '0';
  -- ../src/hdl/interfaces/uart_controller.vhd:74:54
  n1200_o <= "0000000000000000000000" & tx_clk_count;  --  uext
  -- ../src/hdl/interfaces/uart_controller.vhd:74:54
  n1202_o <= std_logic_vector (unsigned (n1200_o) + unsigned'("00000000000000000000000000000001"));
  -- ../src/hdl/interfaces/uart_controller.vhd:74:41
  n1203_o <= n1202_o (9 downto 0);  --  trunc
  -- ../src/hdl/interfaces/uart_controller.vhd:70:21
  n1205_o <= tx_state when n1199_o = '0' else "10";
  -- ../src/hdl/interfaces/uart_controller.vhd:70:21
  n1207_o <= n1203_o when n1199_o = '0' else "0000000000";
  -- ../src/hdl/interfaces/uart_controller.vhd:67:17
  n1209_o <= '1' when tx_state = "01" else '0';
  -- ../src/hdl/interfaces/uart_controller.vhd:80:37
  n1212_o <= "0000000000000000000000" & tx_clk_count;  --  uext
  -- ../src/hdl/interfaces/uart_controller.vhd:80:37
  n1214_o <= '1' when n1212_o = "00000000000000000000001101100011" else '0';
  -- ../src/hdl/interfaces/uart_controller.vhd:83:41
  n1215_o <= "00000000000000000000000000000" & tx_bit_index;  --  uext
  -- ../src/hdl/interfaces/uart_controller.vhd:83:41
  n1217_o <= '1' when n1215_o = "00000000000000000000000000000111" else '0';
  -- ../src/hdl/interfaces/uart_controller.vhd:87:58
  n1218_o <= "00000000000000000000000000000" & tx_bit_index;  --  uext
  -- ../src/hdl/interfaces/uart_controller.vhd:87:58
  n1220_o <= std_logic_vector (unsigned (n1218_o) + unsigned'("00000000000000000000000000000001"));
  -- ../src/hdl/interfaces/uart_controller.vhd:87:45
  n1221_o <= n1220_o (2 downto 0);  --  trunc
  -- ../src/hdl/interfaces/uart_controller.vhd:80:21
  n1223_o <= tx_state when n1230_o = '0' else "11";
  -- ../src/hdl/interfaces/uart_controller.vhd:83:25
  n1225_o <= n1221_o when n1217_o = '0' else "000";
  -- ../src/hdl/interfaces/uart_controller.vhd:90:54
  n1226_o <= "0000000000000000000000" & tx_clk_count;  --  uext
  -- ../src/hdl/interfaces/uart_controller.vhd:90:54
  n1228_o <= std_logic_vector (unsigned (n1226_o) + unsigned'("00000000000000000000000000000001"));
  -- ../src/hdl/interfaces/uart_controller.vhd:90:41
  n1229_o <= n1228_o (9 downto 0);  --  trunc
  -- ../src/hdl/interfaces/uart_controller.vhd:80:21
  n1230_o <= n1214_o and n1217_o;
  -- ../src/hdl/interfaces/uart_controller.vhd:80:21
  n1232_o <= n1229_o when n1214_o = '0' else "0000000000";
  -- ../src/hdl/interfaces/uart_controller.vhd:80:21
  n1233_o <= tx_bit_index when n1214_o = '0' else n1225_o;
  -- ../src/hdl/interfaces/uart_controller.vhd:77:17
  n1235_o <= '1' when tx_state = "10" else '0';
  -- ../src/hdl/interfaces/uart_controller.vhd:96:37
  n1236_o <= "0000000000000000000000" & tx_clk_count;  --  uext
  -- ../src/hdl/interfaces/uart_controller.vhd:96:37
  n1238_o <= '1' when n1236_o = "00000000000000000000001101100011" else '0';
  -- ../src/hdl/interfaces/uart_controller.vhd:99:54
  n1239_o <= "0000000000000000000000" & tx_clk_count;  --  uext
  -- ../src/hdl/interfaces/uart_controller.vhd:99:54
  n1241_o <= std_logic_vector (unsigned (n1239_o) + unsigned'("00000000000000000000000000000001"));
  -- ../src/hdl/interfaces/uart_controller.vhd:99:41
  n1242_o <= n1241_o (9 downto 0);  --  trunc
  -- ../src/hdl/interfaces/uart_controller.vhd:96:21
  n1244_o <= tx_state when n1238_o = '0' else "00";
  -- ../src/hdl/interfaces/uart_controller.vhd:96:21
  n1245_o <= n1242_o when n1238_o = '0' else tx_clk_count;
  -- ../src/hdl/interfaces/uart_controller.vhd:93:17
  n1247_o <= '1' when tx_state = "11" else '0';
  n1248_o <= n1247_o & n1235_o & n1209_o & n1196_o;
  -- ../src/hdl/interfaces/uart_controller.vhd:54:13
  with n1248_o select n1253_o <=
    '1' when "1000",
    n1427_o when "0100",
    '0' when "0010",
    '1' when "0001",
    'X' when others;
  -- ../src/hdl/interfaces/uart_controller.vhd:54:13
  with n1248_o select n1255_o <=
    n1286_q when "1000",
    n1286_q when "0100",
    n1286_q when "0010",
    n1190_o when "0001",
    'X' when others;
  -- ../src/hdl/interfaces/uart_controller.vhd:54:13
  with n1248_o select n1257_o <=
    n1244_o when "1000",
    n1223_o when "0100",
    n1205_o when "0010",
    n1193_o when "0001",
    "XX" when others;
  -- ../src/hdl/interfaces/uart_controller.vhd:54:13
  with n1248_o select n1260_o <=
    n1245_o when "1000",
    n1232_o when "0100",
    n1207_o when "0010",
    "0000000000" when "0001",
    (9 downto 0 => 'X') when others;
  -- ../src/hdl/interfaces/uart_controller.vhd:54:13
  with n1248_o select n1263_o <=
    tx_bit_index when "1000",
    n1233_o when "0100",
    tx_bit_index when "0010",
    "000" when "0001",
    "XXX" when others;
  -- ../src/hdl/interfaces/uart_controller.vhd:54:13
  with n1248_o select n1265_o <=
    tx_buffer when "1000",
    tx_buffer when "0100",
    tx_buffer when "0010",
    n1194_o when "0001",
    "XXXXXXXX" when others;
  -- ../src/hdl/interfaces/uart_controller.vhd:53:9
  process (clk, rst)
  begin
    if rst = '1' then
      n1285_q <= '1';
    elsif rising_edge (clk) then
      n1285_q <= n1253_o;
    end if;
  end process;
  -- ../src/hdl/interfaces/uart_controller.vhd:53:9
  process (clk, rst)
  begin
    if rst = '1' then
      n1286_q <= '0';
    elsif rising_edge (clk) then
      n1286_q <= n1255_o;
    end if;
  end process;
  -- ../src/hdl/interfaces/uart_controller.vhd:53:9
  process (clk, rst)
  begin
    if rst = '1' then
      n1287_q <= "00";
    elsif rising_edge (clk) then
      n1287_q <= n1257_o;
    end if;
  end process;
  -- ../src/hdl/interfaces/uart_controller.vhd:53:9
  process (clk, rst)
  begin
    if rst = '1' then
      n1288_q <= "0000000000";
    elsif rising_edge (clk) then
      n1288_q <= n1260_o;
    end if;
  end process;
  -- ../src/hdl/interfaces/uart_controller.vhd:53:9
  process (clk, rst)
  begin
    if rst = '1' then
      n1289_q <= "000";
    elsif rising_edge (clk) then
      n1289_q <= n1263_o;
    end if;
  end process;
  -- ../src/hdl/interfaces/uart_controller.vhd:53:9
  process (clk, rst)
  begin
    if rst = '1' then
      n1290_q <= "00000000";
    elsif rising_edge (clk) then
      n1290_q <= n1265_o;
    end if;
  end process;
  -- ../src/hdl/interfaces/uart_controller.vhd:117:15
  n1292_o <= '1' when rising_edge (clk) else '0';
  -- ../src/hdl/interfaces/uart_controller.vhd:119:31
  n1293_o <= rx_sync (0);
  -- ../src/hdl/interfaces/uart_controller.vhd:119:35
  n1294_o <= n1293_o & rx;
  -- ../src/hdl/interfaces/uart_controller.vhd:127:31
  n1295_o <= rx_sync (1);
  -- ../src/hdl/interfaces/uart_controller.vhd:127:35
  n1296_o <= not n1295_o;
  -- ../src/hdl/interfaces/uart_controller.vhd:127:21
  n1298_o <= rx_state when n1296_o = '0' else "01";
  -- ../src/hdl/interfaces/uart_controller.vhd:123:17
  n1300_o <= '1' when rx_state = "00" else '0';
  -- ../src/hdl/interfaces/uart_controller.vhd:132:37
  n1301_o <= "0000000000000000000000" & rx_clk_count;  --  uext
  -- ../src/hdl/interfaces/uart_controller.vhd:132:37
  n1303_o <= '1' when n1301_o = "00000000000000000000000110110010" else '0';
  -- ../src/hdl/interfaces/uart_controller.vhd:133:35
  n1304_o <= rx_sync (1);
  -- ../src/hdl/interfaces/uart_controller.vhd:133:39
  n1305_o <= not n1304_o;
  -- ../src/hdl/interfaces/uart_controller.vhd:133:25
  n1308_o <= "00" when n1305_o = '0' else "10";
  -- ../src/hdl/interfaces/uart_controller.vhd:133:25
  n1310_o <= rx_clk_count when n1305_o = '0' else "0000000000";
  -- ../src/hdl/interfaces/uart_controller.vhd:140:54
  n1311_o <= "0000000000000000000000" & rx_clk_count;  --  uext
  -- ../src/hdl/interfaces/uart_controller.vhd:140:54
  n1313_o <= std_logic_vector (unsigned (n1311_o) + unsigned'("00000000000000000000000000000001"));
  -- ../src/hdl/interfaces/uart_controller.vhd:140:41
  n1314_o <= n1313_o (9 downto 0);  --  trunc
  -- ../src/hdl/interfaces/uart_controller.vhd:132:21
  n1315_o <= rx_state when n1303_o = '0' else n1308_o;
  -- ../src/hdl/interfaces/uart_controller.vhd:132:21
  n1316_o <= n1314_o when n1303_o = '0' else n1310_o;
  -- ../src/hdl/interfaces/uart_controller.vhd:131:17
  n1318_o <= '1' when rx_state = "01" else '0';
  -- ../src/hdl/interfaces/uart_controller.vhd:144:37
  n1319_o <= "0000000000000000000000" & rx_clk_count;  --  uext
  -- ../src/hdl/interfaces/uart_controller.vhd:144:37
  n1321_o <= '1' when n1319_o = "00000000000000000000001101100011" else '0';
  -- ../src/hdl/interfaces/uart_controller.vhd:146:59
  n1323_o <= rx_sync (1);
  -- ../src/hdl/interfaces/uart_controller.vhd:148:41
  n1325_o <= "00000000000000000000000000000" & rx_bit_index;  --  uext
  -- ../src/hdl/interfaces/uart_controller.vhd:148:41
  n1327_o <= '1' when n1325_o = "00000000000000000000000000000111" else '0';
  -- ../src/hdl/interfaces/uart_controller.vhd:152:58
  n1328_o <= "00000000000000000000000000000" & rx_bit_index;  --  uext
  -- ../src/hdl/interfaces/uart_controller.vhd:152:58
  n1330_o <= std_logic_vector (unsigned (n1328_o) + unsigned'("00000000000000000000000000000001"));
  -- ../src/hdl/interfaces/uart_controller.vhd:152:45
  n1331_o <= n1330_o (2 downto 0);  --  trunc
  -- ../src/hdl/interfaces/uart_controller.vhd:144:21
  n1333_o <= rx_state when n1340_o = '0' else "11";
  -- ../src/hdl/interfaces/uart_controller.vhd:148:25
  n1335_o <= n1331_o when n1327_o = '0' else "000";
  -- ../src/hdl/interfaces/uart_controller.vhd:155:54
  n1336_o <= "0000000000000000000000" & rx_clk_count;  --  uext
  -- ../src/hdl/interfaces/uart_controller.vhd:155:54
  n1338_o <= std_logic_vector (unsigned (n1336_o) + unsigned'("00000000000000000000000000000001"));
  -- ../src/hdl/interfaces/uart_controller.vhd:155:41
  n1339_o <= n1338_o (9 downto 0);  --  trunc
  -- ../src/hdl/interfaces/uart_controller.vhd:144:21
  n1340_o <= n1321_o and n1327_o;
  -- ../src/hdl/interfaces/uart_controller.vhd:144:21
  n1342_o <= n1339_o when n1321_o = '0' else "0000000000";
  -- ../src/hdl/interfaces/uart_controller.vhd:144:21
  n1343_o <= rx_bit_index when n1321_o = '0' else n1335_o;
  -- ../src/hdl/interfaces/uart_controller.vhd:144:21
  n1344_o <= rx_buffer when n1321_o = '0' else n1462_o;
  -- ../src/hdl/interfaces/uart_controller.vhd:143:17
  n1346_o <= '1' when rx_state = "10" else '0';
  -- ../src/hdl/interfaces/uart_controller.vhd:159:37
  n1347_o <= "0000000000000000000000" & rx_clk_count;  --  uext
  -- ../src/hdl/interfaces/uart_controller.vhd:159:37
  n1349_o <= '1' when n1347_o = "00000000000000000000001101100011" else '0';
  -- ../src/hdl/interfaces/uart_controller.vhd:160:35
  n1350_o <= rx_sync (1);
  -- ../src/hdl/interfaces/uart_controller.vhd:159:21
  n1351_o <= n1407_q when n1359_o = '0' else rx_buffer;
  -- ../src/hdl/interfaces/uart_controller.vhd:160:25
  n1354_o <= '0' when n1350_o = '0' else '1';
  -- ../src/hdl/interfaces/uart_controller.vhd:167:54
  n1355_o <= "0000000000000000000000" & rx_clk_count;  --  uext
  -- ../src/hdl/interfaces/uart_controller.vhd:167:54
  n1357_o <= std_logic_vector (unsigned (n1355_o) + unsigned'("00000000000000000000000000000001"));
  -- ../src/hdl/interfaces/uart_controller.vhd:167:41
  n1358_o <= n1357_o (9 downto 0);  --  trunc
  -- ../src/hdl/interfaces/uart_controller.vhd:159:21
  n1359_o <= n1349_o and n1350_o;
  -- ../src/hdl/interfaces/uart_controller.vhd:159:21
  n1361_o <= '0' when n1349_o = '0' else n1354_o;
  -- ../src/hdl/interfaces/uart_controller.vhd:159:21
  n1363_o <= rx_state when n1349_o = '0' else "00";
  -- ../src/hdl/interfaces/uart_controller.vhd:159:21
  n1365_o <= n1358_o when n1349_o = '0' else "0000000000";
  -- ../src/hdl/interfaces/uart_controller.vhd:158:17
  n1367_o <= '1' when rx_state = "11" else '0';
  n1368_o <= n1367_o & n1346_o & n1318_o & n1300_o;
  -- ../src/hdl/interfaces/uart_controller.vhd:122:13
  with n1368_o select n1370_o <=
    n1351_o when "1000",
    n1407_q when "0100",
    n1407_q when "0010",
    n1407_q when "0001",
    "XXXXXXXX" when others;
  -- ../src/hdl/interfaces/uart_controller.vhd:122:13
  with n1368_o select n1373_o <=
    n1361_o when "1000",
    '0' when "0100",
    '0' when "0010",
    '0' when "0001",
    'X' when others;
  -- ../src/hdl/interfaces/uart_controller.vhd:122:13
  with n1368_o select n1376_o <=
    n1363_o when "1000",
    n1333_o when "0100",
    n1315_o when "0010",
    n1298_o when "0001",
    "XX" when others;
  -- ../src/hdl/interfaces/uart_controller.vhd:122:13
  with n1368_o select n1379_o <=
    n1365_o when "1000",
    n1342_o when "0100",
    n1316_o when "0010",
    "0000000000" when "0001",
    (9 downto 0 => 'X') when others;
  -- ../src/hdl/interfaces/uart_controller.vhd:122:13
  with n1368_o select n1382_o <=
    rx_bit_index when "1000",
    n1343_o when "0100",
    rx_bit_index when "0010",
    "000" when "0001",
    "XXX" when others;
  -- ../src/hdl/interfaces/uart_controller.vhd:122:13
  with n1368_o select n1384_o <=
    rx_buffer when "1000",
    n1344_o when "0100",
    rx_buffer when "0010",
    rx_buffer when "0001",
    "XXXXXXXX" when others;
  -- ../src/hdl/interfaces/uart_controller.vhd:117:9
  process (clk, rst)
  begin
    if rst = '1' then
      n1407_q <= "00000000";
    elsif rising_edge (clk) then
      n1407_q <= n1370_o;
    end if;
  end process;
  -- ../src/hdl/interfaces/uart_controller.vhd:117:9
  process (clk, rst)
  begin
    if rst = '1' then
      n1408_q <= '0';
    elsif rising_edge (clk) then
      n1408_q <= n1373_o;
    end if;
  end process;
  -- ../src/hdl/interfaces/uart_controller.vhd:117:9
  process (clk, rst)
  begin
    if rst = '1' then
      n1409_q <= "00";
    elsif rising_edge (clk) then
      n1409_q <= n1376_o;
    end if;
  end process;
  -- ../src/hdl/interfaces/uart_controller.vhd:117:9
  process (clk, rst)
  begin
    if rst = '1' then
      n1410_q <= "0000000000";
    elsif rising_edge (clk) then
      n1410_q <= n1379_o;
    end if;
  end process;
  -- ../src/hdl/interfaces/uart_controller.vhd:117:9
  process (clk, rst)
  begin
    if rst = '1' then
      n1411_q <= "000";
    elsif rising_edge (clk) then
      n1411_q <= n1382_o;
    end if;
  end process;
  -- ../src/hdl/interfaces/uart_controller.vhd:117:9
  process (clk, rst)
  begin
    if rst = '1' then
      n1412_q <= "00000000";
    elsif rising_edge (clk) then
      n1412_q <= n1384_o;
    end if;
  end process;
  -- ../src/hdl/interfaces/uart_controller.vhd:117:9
  process (clk, rst)
  begin
    if rst = '1' then
      n1413_q <= "11";
    elsif rising_edge (clk) then
      n1413_q <= n1294_o;
    end if;
  end process;
  -- ../src/hdl/interfaces/uart_controller.vhd:21:9
  n1414_o <= tx_buffer (0);
  -- ../src/hdl/interfaces/uart_controller.vhd:20:9
  n1415_o <= tx_buffer (1);
  -- ../src/hdl/interfaces/uart_controller.vhd:19:9
  n1416_o <= tx_buffer (2);
  -- ../src/hdl/interfaces/uart_controller.vhd:15:9
  n1417_o <= tx_buffer (3);
  n1418_o <= tx_buffer (4);
  n1419_o <= tx_buffer (5);
  -- ../src/hdl/interfaces/uart_controller.vhd:106:5
  n1420_o <= tx_buffer (6);
  n1421_o <= tx_buffer (7);
  -- ../src/hdl/interfaces/uart_controller.vhd:78:36
  n1422_o <= tx_bit_index (1 downto 0);
  -- ../src/hdl/interfaces/uart_controller.vhd:78:36
  with n1422_o select n1423_o <=
    n1414_o when "00",
    n1415_o when "01",
    n1416_o when "10",
    n1417_o when "11",
    'X' when others;
  -- ../src/hdl/interfaces/uart_controller.vhd:78:36
  n1424_o <= tx_bit_index (1 downto 0);
  -- ../src/hdl/interfaces/uart_controller.vhd:78:36
  with n1424_o select n1425_o <=
    n1418_o when "00",
    n1419_o when "01",
    n1420_o when "10",
    n1421_o when "11",
    'X' when others;
  -- ../src/hdl/interfaces/uart_controller.vhd:78:36
  n1426_o <= tx_bit_index (2);
  -- ../src/hdl/interfaces/uart_controller.vhd:78:36
  n1427_o <= n1423_o when n1426_o = '0' else n1425_o;
  -- ../src/hdl/interfaces/uart_controller.vhd:146:25
  n1428_o <= rx_bit_index (2);
  -- ../src/hdl/interfaces/uart_controller.vhd:146:25
  n1429_o <= not n1428_o;
  -- ../src/hdl/interfaces/uart_controller.vhd:146:25
  n1430_o <= rx_bit_index (1);
  -- ../src/hdl/interfaces/uart_controller.vhd:146:25
  n1431_o <= not n1430_o;
  -- ../src/hdl/interfaces/uart_controller.vhd:146:25
  n1432_o <= n1429_o and n1431_o;
  -- ../src/hdl/interfaces/uart_controller.vhd:146:25
  n1433_o <= n1429_o and n1430_o;
  -- ../src/hdl/interfaces/uart_controller.vhd:146:25
  n1434_o <= n1428_o and n1431_o;
  -- ../src/hdl/interfaces/uart_controller.vhd:146:25
  n1435_o <= n1428_o and n1430_o;
  -- ../src/hdl/interfaces/uart_controller.vhd:146:25
  n1436_o <= rx_bit_index (0);
  -- ../src/hdl/interfaces/uart_controller.vhd:146:25
  n1437_o <= not n1436_o;
  -- ../src/hdl/interfaces/uart_controller.vhd:146:25
  n1438_o <= n1432_o and n1437_o;
  -- ../src/hdl/interfaces/uart_controller.vhd:146:25
  n1439_o <= n1432_o and n1436_o;
  -- ../src/hdl/interfaces/uart_controller.vhd:146:25
  n1440_o <= n1433_o and n1437_o;
  -- ../src/hdl/interfaces/uart_controller.vhd:146:25
  n1441_o <= n1433_o and n1436_o;
  -- ../src/hdl/interfaces/uart_controller.vhd:146:25
  n1442_o <= n1434_o and n1437_o;
  -- ../src/hdl/interfaces/uart_controller.vhd:146:25
  n1443_o <= n1434_o and n1436_o;
  -- ../src/hdl/interfaces/uart_controller.vhd:146:25
  n1444_o <= n1435_o and n1437_o;
  -- ../src/hdl/interfaces/uart_controller.vhd:146:25
  n1445_o <= n1435_o and n1436_o;
  n1446_o <= rx_buffer (0);
  -- ../src/hdl/interfaces/uart_controller.vhd:146:25
  n1447_o <= n1446_o when n1438_o = '0' else n1323_o;
  n1448_o <= rx_buffer (1);
  -- ../src/hdl/interfaces/uart_controller.vhd:146:25
  n1449_o <= n1448_o when n1439_o = '0' else n1323_o;
  n1450_o <= rx_buffer (2);
  -- ../src/hdl/interfaces/uart_controller.vhd:146:25
  n1451_o <= n1450_o when n1440_o = '0' else n1323_o;
  n1452_o <= rx_buffer (3);
  -- ../src/hdl/interfaces/uart_controller.vhd:146:25
  n1453_o <= n1452_o when n1441_o = '0' else n1323_o;
  n1454_o <= rx_buffer (4);
  -- ../src/hdl/interfaces/uart_controller.vhd:146:25
  n1455_o <= n1454_o when n1442_o = '0' else n1323_o;
  n1456_o <= rx_buffer (5);
  -- ../src/hdl/interfaces/uart_controller.vhd:146:25
  n1457_o <= n1456_o when n1443_o = '0' else n1323_o;
  n1458_o <= rx_buffer (6);
  -- ../src/hdl/interfaces/uart_controller.vhd:146:25
  n1459_o <= n1458_o when n1444_o = '0' else n1323_o;
  n1460_o <= rx_buffer (7);
  -- ../src/hdl/interfaces/uart_controller.vhd:146:25
  n1461_o <= n1460_o when n1445_o = '0' else n1323_o;
  n1462_o <= n1461_o & n1459_o & n1457_o & n1455_o & n1453_o & n1451_o & n1449_o & n1447_o;
end rtl;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity safety_monitor is
  port (
    clk : in std_logic;
    rst : in std_logic;
    voc_levels : in std_logic_vector (11 downto 0);
    air_quality : in std_logic_vector (11 downto 0);
    pressure_levels : in std_logic_vector (11 downto 0);
    temperature : in std_logic_vector (11 downto 0);
    flow_sensors : in std_logic_vector (7 downto 0);
    voc_threshold : in std_logic_vector (11 downto 0);
    aq_threshold : in std_logic_vector (11 downto 0);
    press_threshold : in std_logic_vector (11 downto 0);
    temp_threshold : in std_logic_vector (11 downto 0);
    flow_threshold : in std_logic_vector (7 downto 0);
    emergency_stop : out std_logic;
    ventilation_on : out std_logic;
    chamber_shutdown : out std_logic_vector (149 downto 0);
    safety_status : out std_logic_vector (7 downto 0);
    error_code : out std_logic_vector (7 downto 0);
    error_location : out std_logic_vector (7 downto 0));
end entity safety_monitor;

architecture rtl of safety_monitor is
  signal current_state : std_logic_vector (2 downto 0);
  signal violation_counter : std_logic_vector (3 downto 0);
  signal persistent_violation : std_logic;
  signal emergency_stop_int : std_logic;
  signal ventilation_on_int : std_logic;
  signal n1064_o : std_logic;
  signal n1065_o : std_logic;
  signal n1067_o : std_logic_vector (3 downto 0);
  signal n1069_o : std_logic_vector (7 downto 0);
  signal n1071_o : std_logic_vector (7 downto 0);
  signal n1073_o : std_logic_vector (3 downto 0);
  signal n1075_o : std_logic;
  signal n1077_o : std_logic;
  signal n1078_o : std_logic;
  signal n1080_o : std_logic_vector (3 downto 0);
  signal n1082_o : std_logic_vector (7 downto 0);
  signal n1084_o : std_logic_vector (7 downto 0);
  signal n1085_o : std_logic_vector (3 downto 0);
  signal n1087_o : std_logic;
  signal n1089_o : std_logic;
  signal n1090_o : std_logic;
  signal n1092_o : std_logic_vector (149 downto 0);
  signal n1094_o : std_logic_vector (7 downto 0);
  signal n1096_o : std_logic_vector (7 downto 0);
  signal n1098_o : std_logic;
  signal n1100_o : std_logic;
  signal n1101_o : std_logic;
  signal n1103_o : std_logic_vector (149 downto 0);
  signal n1105_o : std_logic_vector (7 downto 0);
  signal n1107_o : std_logic_vector (7 downto 0);
  signal n1109_o : std_logic;
  signal n1111_o : std_logic;
  signal n1112_o : std_logic;
  signal n1114_o : std_logic_vector (7 downto 0);
  signal n1116_o : std_logic_vector (7 downto 0);
  signal n1118_o : std_logic;
  signal n1119_o : std_logic_vector (4 downto 0);
  signal n1120_o : std_logic_vector (149 downto 0);
  signal n1121_o : std_logic_vector (7 downto 0);
  signal n1122_o : std_logic_vector (7 downto 0);
  signal n1129_o : std_logic_vector (2 downto 0);
  signal n1130_o : std_logic_vector (3 downto 0);
  signal n1131_o : std_logic;
  signal n1132_o : std_logic;
  signal n1134_o : std_logic;
  signal n1138_o : std_logic;
  signal n1139_o : std_logic_vector (1 downto 0);
  signal n1140_o : std_logic_vector (2 downto 0);
  signal n1142_o : std_logic_vector (7 downto 0);
  signal n1170_q : std_logic_vector (149 downto 0);
  signal n1171_o : std_logic;
  signal n1172_o : std_logic_vector (7 downto 0);
  signal n1173_q : std_logic_vector (7 downto 0);
  signal n1174_q : std_logic_vector (7 downto 0);
  signal n1175_q : std_logic_vector (7 downto 0);
  signal n1176_q : std_logic_vector (2 downto 0);
  signal n1177_q : std_logic_vector (3 downto 0);
  signal n1178_o : std_logic;
  signal n1179_q : std_logic;
  signal n1180_q : std_logic;
  signal n1181_q : std_logic;
begin
  emergency_stop <= emergency_stop_int;
  ventilation_on <= ventilation_on_int;
  chamber_shutdown <= n1170_q;
  safety_status <= n1173_q;
  error_code <= n1174_q;
  error_location <= n1175_q;
  -- ../src/hdl/safety/safety_monitor.vhd:41:12
  current_state <= n1176_q; -- (signal)
  -- ../src/hdl/safety/safety_monitor.vhd:42:12
  violation_counter <= n1177_q; -- (signal)
  -- ../src/hdl/safety/safety_monitor.vhd:43:12
  persistent_violation <= n1179_q; -- (signal)
  -- ../src/hdl/safety/safety_monitor.vhd:46:12
  emergency_stop_int <= n1180_q; -- (signal)
  -- ../src/hdl/safety/safety_monitor.vhd:47:12
  ventilation_on_int <= n1181_q; -- (signal)
  -- ../src/hdl/safety/safety_monitor.vhd:61:15
  n1064_o <= '1' when rising_edge (clk) else '0';
  -- ../src/hdl/safety/safety_monitor.vhd:64:45
  n1065_o <= '1' when unsigned (voc_levels) > unsigned (voc_threshold) else '0';
  -- ../src/hdl/safety/safety_monitor.vhd:66:64
  n1067_o <= std_logic_vector (unsigned (violation_counter) + unsigned'("0001"));
  -- ../src/hdl/safety/safety_monitor.vhd:64:21
  n1069_o <= n1174_q when n1065_o = '0' else "00000001";
  -- ../src/hdl/safety/safety_monitor.vhd:64:21
  n1071_o <= n1175_q when n1065_o = '0' else "00000000";
  -- ../src/hdl/safety/safety_monitor.vhd:64:21
  n1073_o <= "0000" when n1065_o = '0' else n1067_o;
  -- ../src/hdl/safety/safety_monitor.vhd:64:21
  n1075_o <= ventilation_on_int when n1065_o = '0' else '1';
  -- ../src/hdl/safety/safety_monitor.vhd:63:17
  n1077_o <= '1' when current_state = "000" else '0';
  -- ../src/hdl/safety/safety_monitor.vhd:75:46
  n1078_o <= '1' when unsigned (air_quality) > unsigned (aq_threshold) else '0';
  -- ../src/hdl/safety/safety_monitor.vhd:77:64
  n1080_o <= std_logic_vector (unsigned (violation_counter) + unsigned'("0001"));
  -- ../src/hdl/safety/safety_monitor.vhd:75:21
  n1082_o <= n1174_q when n1078_o = '0' else "00000010";
  -- ../src/hdl/safety/safety_monitor.vhd:75:21
  n1084_o <= n1175_q when n1078_o = '0' else "00000001";
  -- ../src/hdl/safety/safety_monitor.vhd:75:21
  n1085_o <= violation_counter when n1078_o = '0' else n1080_o;
  -- ../src/hdl/safety/safety_monitor.vhd:75:21
  n1087_o <= ventilation_on_int when n1078_o = '0' else '1';
  -- ../src/hdl/safety/safety_monitor.vhd:74:17
  n1089_o <= '1' when current_state = "001" else '0';
  -- ../src/hdl/safety/safety_monitor.vhd:84:50
  n1090_o <= '1' when unsigned (pressure_levels) > unsigned (press_threshold) else '0';
  -- ../src/hdl/safety/safety_monitor.vhd:84:21
  n1092_o <= n1170_q when n1090_o = '0' else "111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111";
  -- ../src/hdl/safety/safety_monitor.vhd:84:21
  n1094_o <= n1174_q when n1090_o = '0' else "00000011";
  -- ../src/hdl/safety/safety_monitor.vhd:84:21
  n1096_o <= n1175_q when n1090_o = '0' else "00000010";
  -- ../src/hdl/safety/safety_monitor.vhd:84:21
  n1098_o <= emergency_stop_int when n1090_o = '0' else '1';
  -- ../src/hdl/safety/safety_monitor.vhd:83:17
  n1100_o <= '1' when current_state = "010" else '0';
  -- ../src/hdl/safety/safety_monitor.vhd:93:46
  n1101_o <= '1' when unsigned (temperature) > unsigned (temp_threshold) else '0';
  -- ../src/hdl/safety/safety_monitor.vhd:93:21
  n1103_o <= n1170_q when n1101_o = '0' else "111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111";
  -- ../src/hdl/safety/safety_monitor.vhd:93:21
  n1105_o <= n1174_q when n1101_o = '0' else "00000100";
  -- ../src/hdl/safety/safety_monitor.vhd:93:21
  n1107_o <= n1175_q when n1101_o = '0' else "00000011";
  -- ../src/hdl/safety/safety_monitor.vhd:93:21
  n1109_o <= emergency_stop_int when n1101_o = '0' else '1';
  -- ../src/hdl/safety/safety_monitor.vhd:92:17
  n1111_o <= '1' when current_state = "011" else '0';
  -- ../src/hdl/safety/safety_monitor.vhd:102:47
  n1112_o <= '1' when unsigned (flow_sensors) < unsigned (flow_threshold) else '0';
  -- ../src/hdl/safety/safety_monitor.vhd:102:21
  n1114_o <= n1174_q when n1112_o = '0' else "00000101";
  -- ../src/hdl/safety/safety_monitor.vhd:102:21
  n1116_o <= n1175_q when n1112_o = '0' else "00000100";
  -- ../src/hdl/safety/safety_monitor.vhd:101:17
  n1118_o <= '1' when current_state = "100" else '0';
  n1119_o <= n1118_o & n1111_o & n1100_o & n1089_o & n1077_o;
  -- ../src/hdl/safety/safety_monitor.vhd:62:13
  with n1119_o select n1120_o <=
    n1170_q when "10000",
    n1103_o when "01000",
    n1092_o when "00100",
    n1170_q when "00010",
    n1170_q when "00001",
    n1170_q when others;
  -- ../src/hdl/safety/safety_monitor.vhd:62:13
  with n1119_o select n1121_o <=
    n1114_o when "10000",
    n1105_o when "01000",
    n1094_o when "00100",
    n1082_o when "00010",
    n1069_o when "00001",
    n1174_q when others;
  -- ../src/hdl/safety/safety_monitor.vhd:62:13
  with n1119_o select n1122_o <=
    n1116_o when "10000",
    n1107_o when "01000",
    n1096_o when "00100",
    n1084_o when "00010",
    n1071_o when "00001",
    n1175_q when others;
  -- ../src/hdl/safety/safety_monitor.vhd:62:13
  with n1119_o select n1129_o <=
    "000" when "10000",
    "100" when "01000",
    "011" when "00100",
    "010" when "00010",
    "001" when "00001",
    "000" when others;
  -- ../src/hdl/safety/safety_monitor.vhd:62:13
  with n1119_o select n1130_o <=
    violation_counter when "10000",
    violation_counter when "01000",
    violation_counter when "00100",
    n1085_o when "00010",
    n1073_o when "00001",
    violation_counter when others;
  -- ../src/hdl/safety/safety_monitor.vhd:62:13
  with n1119_o select n1131_o <=
    emergency_stop_int when "10000",
    n1109_o when "01000",
    n1098_o when "00100",
    emergency_stop_int when "00010",
    emergency_stop_int when "00001",
    emergency_stop_int when others;
  -- ../src/hdl/safety/safety_monitor.vhd:62:13
  with n1119_o select n1132_o <=
    ventilation_on_int when "10000",
    ventilation_on_int when "01000",
    ventilation_on_int when "00100",
    n1087_o when "00010",
    n1075_o when "00001",
    ventilation_on_int when others;
  -- ../src/hdl/safety/safety_monitor.vhd:113:34
  n1134_o <= '1' when unsigned (violation_counter) > unsigned'("1000") else '0';
  -- ../src/hdl/safety/safety_monitor.vhd:113:13
  n1138_o <= n1131_o when n1134_o = '0' else '1';
  -- ../src/hdl/safety/safety_monitor.vhd:119:51
  n1139_o <= persistent_violation & emergency_stop_int;
  -- ../src/hdl/safety/safety_monitor.vhd:120:47
  n1140_o <= n1139_o & ventilation_on_int;
  -- ../src/hdl/safety/safety_monitor.vhd:121:47
  n1142_o <= n1140_o & "00000";
  -- ../src/hdl/safety/safety_monitor.vhd:61:9
  process (clk, rst)
  begin
    if rst = '1' then
      n1170_q <= "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
    elsif rising_edge (clk) then
      n1170_q <= n1120_o;
    end if;
  end process;
  -- ../src/hdl/safety/safety_monitor.vhd:49:5
  n1171_o <= not rst;
  -- ../src/hdl/safety/safety_monitor.vhd:49:5
  n1172_o <= n1173_q when n1171_o = '0' else n1142_o;
  -- ../src/hdl/safety/safety_monitor.vhd:61:9
  process (clk)
  begin
    if rising_edge (clk) then
      n1173_q <= n1172_o;
    end if;
  end process;
  -- ../src/hdl/safety/safety_monitor.vhd:61:9
  process (clk, rst)
  begin
    if rst = '1' then
      n1174_q <= "00000000";
    elsif rising_edge (clk) then
      n1174_q <= n1121_o;
    end if;
  end process;
  -- ../src/hdl/safety/safety_monitor.vhd:61:9
  process (clk, rst)
  begin
    if rst = '1' then
      n1175_q <= "00000000";
    elsif rising_edge (clk) then
      n1175_q <= n1122_o;
    end if;
  end process;
  -- ../src/hdl/safety/safety_monitor.vhd:61:9
  process (clk, rst)
  begin
    if rst = '1' then
      n1176_q <= "000";
    elsif rising_edge (clk) then
      n1176_q <= n1129_o;
    end if;
  end process;
  -- ../src/hdl/safety/safety_monitor.vhd:61:9
  process (clk, rst)
  begin
    if rst = '1' then
      n1177_q <= "0000";
    elsif rising_edge (clk) then
      n1177_q <= n1130_o;
    end if;
  end process;
  -- ../src/hdl/safety/safety_monitor.vhd:113:34
  n1178_o <= persistent_violation when n1134_o = '0' else '1';
  -- ../src/hdl/safety/safety_monitor.vhd:61:9
  process (clk, rst)
  begin
    if rst = '1' then
      n1179_q <= '0';
    elsif rising_edge (clk) then
      n1179_q <= n1178_o;
    end if;
  end process;
  -- ../src/hdl/safety/safety_monitor.vhd:61:9
  process (clk, rst)
  begin
    if rst = '1' then
      n1180_q <= '0';
    elsif rising_edge (clk) then
      n1180_q <= n1138_o;
    end if;
  end process;
  -- ../src/hdl/safety/safety_monitor.vhd:61:9
  process (clk, rst)
  begin
    if rst = '1' then
      n1181_q <= '0';
    elsif rising_edge (clk) then
      n1181_q <= n1132_o;
    end if;
  end process;
end rtl;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sensor_hub is
  port (
    clk : in std_logic;
    rst : in std_logic;
    adc_spi_miso : in std_logic;
    cal_mode : in std_logic;
    cal_data : in std_logic_vector (15 downto 0);
    cal_addr : in std_logic_vector (7 downto 0);
    cal_wr : in std_logic;
    scl : inout std_logic_vector (3 downto 0);
    sda : inout std_logic_vector (3 downto 0);
    adc_spi_sclk : out std_logic;
    adc_spi_mosi : out std_logic;
    adc_spi_cs_n : out std_logic_vector (7 downto 0);
    voc_data : out std_logic_vector (11 downto 0);
    aq_data : out std_logic_vector (11 downto 0);
    pressure_data : out std_logic_vector (11 downto 0);
    temp_data : out std_logic_vector (11 downto 0);
    flow_data : out std_logic_vector (7 downto 0);
    sensor_status : out std_logic_vector (7 downto 0);
    error_flags : out std_logic_vector (7 downto 0));
end entity sensor_hub;

architecture rtl of sensor_hub is
  signal n245_o : std_logic_vector (3 downto 0);
  signal n245_oport : std_logic_vector (3 downto 0);
  signal n246_o : std_logic_vector (3 downto 0);
  signal n246_oport : std_logic_vector (3 downto 0);
  signal voc_buffer : std_logic_vector (95 downto 0);
  signal aq_buffer : std_logic_vector (95 downto 0);
  signal pressure_buffer : std_logic_vector (95 downto 0);
  signal temp_buffer : std_logic_vector (95 downto 0);
  signal voc_data_internal : std_logic_vector (11 downto 0);
  signal aq_data_internal : std_logic_vector (11 downto 0);
  signal cal_storage : std_logic_vector (63 downto 0);
  signal current_state : std_logic_vector (2 downto 0);
  signal buffer_index : std_logic_vector (2 downto 0);
  signal spi_active : std_logic;
  signal spi_done : std_logic;
  signal spi_counter : std_logic_vector (4 downto 0);
  signal spi_data_out : std_logic_vector (15 downto 0);
  signal spi_data_in : std_logic_vector (15 downto 0);
  signal sample_timeout : std_logic_vector (15 downto 0);
  signal adc_valid : std_logic;
  signal cs_control : std_logic_vector (7 downto 0);
  signal n276_o : std_logic;
  signal n277_o : std_logic;
  signal n279_o : std_logic;
  signal n281_o : std_logic_vector (2 downto 0);
  signal n283_o : std_logic_vector (2 downto 0);
  signal n285_o : std_logic_vector (7 downto 0);
  signal n288_o : std_logic;
  signal n290_o : std_logic;
  signal n293_o : std_logic_vector (2 downto 0);
  signal n295_o : std_logic_vector (11 downto 0);
  signal n297_o : std_logic_vector (95 downto 0);
  signal n299_o : std_logic_vector (2 downto 0);
  signal n301_o : std_logic;
  signal n304_o : std_logic_vector (2 downto 0);
  signal n306_o : std_logic_vector (11 downto 0);
  signal n308_o : std_logic_vector (95 downto 0);
  signal n310_o : std_logic_vector (2 downto 0);
  signal n312_o : std_logic;
  signal n315_o : std_logic_vector (2 downto 0);
  signal n317_o : std_logic_vector (11 downto 0);
  signal n319_o : std_logic_vector (95 downto 0);
  signal n321_o : std_logic_vector (2 downto 0);
  signal n323_o : std_logic;
  signal n326_o : std_logic_vector (2 downto 0);
  signal n328_o : std_logic_vector (11 downto 0);
  signal n330_o : std_logic_vector (95 downto 0);
  signal n332_o : std_logic_vector (2 downto 0);
  signal n338_o : std_logic;
  signal n339_o : std_logic_vector (11 downto 0);
  signal n340_o : std_logic_vector (7 downto 0);
  signal n341_o : std_logic_vector (19 downto 0);
  signal n342_o : std_logic_vector (19 downto 0);
  signal n343_o : std_logic_vector (19 downto 0);
  signal n345_o : std_logic_vector (19 downto 0);
  signal n347_o : std_logic_vector (11 downto 0);
  signal n348_o : std_logic_vector (7 downto 0);
  signal n349_o : std_logic_vector (19 downto 0);
  signal n350_o : std_logic_vector (19 downto 0);
  signal n351_o : std_logic_vector (19 downto 0);
  signal n352_o : std_logic_vector (19 downto 0);
  signal n353_o : std_logic_vector (11 downto 0);
  signal n354_o : std_logic_vector (7 downto 0);
  signal n355_o : std_logic_vector (19 downto 0);
  signal n356_o : std_logic_vector (19 downto 0);
  signal n357_o : std_logic_vector (19 downto 0);
  signal n358_o : std_logic_vector (19 downto 0);
  signal n359_o : std_logic_vector (11 downto 0);
  signal n360_o : std_logic_vector (7 downto 0);
  signal n361_o : std_logic_vector (19 downto 0);
  signal n362_o : std_logic_vector (19 downto 0);
  signal n363_o : std_logic_vector (19 downto 0);
  signal n364_o : std_logic_vector (19 downto 0);
  signal n365_o : std_logic_vector (11 downto 0);
  signal n366_o : std_logic_vector (7 downto 0);
  signal n367_o : std_logic_vector (19 downto 0);
  signal n368_o : std_logic_vector (19 downto 0);
  signal n369_o : std_logic_vector (19 downto 0);
  signal n370_o : std_logic_vector (19 downto 0);
  signal n371_o : std_logic_vector (11 downto 0);
  signal n372_o : std_logic_vector (7 downto 0);
  signal n373_o : std_logic_vector (19 downto 0);
  signal n374_o : std_logic_vector (19 downto 0);
  signal n375_o : std_logic_vector (19 downto 0);
  signal n376_o : std_logic_vector (19 downto 0);
  signal n377_o : std_logic_vector (11 downto 0);
  signal n378_o : std_logic_vector (7 downto 0);
  signal n379_o : std_logic_vector (19 downto 0);
  signal n380_o : std_logic_vector (19 downto 0);
  signal n381_o : std_logic_vector (19 downto 0);
  signal n382_o : std_logic_vector (19 downto 0);
  signal n383_o : std_logic_vector (11 downto 0);
  signal n384_o : std_logic_vector (7 downto 0);
  signal n385_o : std_logic_vector (19 downto 0);
  signal n386_o : std_logic_vector (19 downto 0);
  signal n387_o : std_logic_vector (19 downto 0);
  signal n388_o : std_logic_vector (19 downto 0);
  signal n389_o : std_logic_vector (16 downto 0);
  signal n390_o : std_logic_vector (11 downto 0);
  signal n391_o : std_logic_vector (11 downto 0);
  signal n392_o : std_logic_vector (7 downto 0);
  signal n393_o : std_logic_vector (19 downto 0);
  signal n394_o : std_logic_vector (19 downto 0);
  signal n395_o : std_logic_vector (19 downto 0);
  signal n397_o : std_logic_vector (19 downto 0);
  signal n399_o : std_logic_vector (11 downto 0);
  signal n400_o : std_logic_vector (7 downto 0);
  signal n401_o : std_logic_vector (19 downto 0);
  signal n402_o : std_logic_vector (19 downto 0);
  signal n403_o : std_logic_vector (19 downto 0);
  signal n404_o : std_logic_vector (19 downto 0);
  signal n405_o : std_logic_vector (11 downto 0);
  signal n406_o : std_logic_vector (7 downto 0);
  signal n407_o : std_logic_vector (19 downto 0);
  signal n408_o : std_logic_vector (19 downto 0);
  signal n409_o : std_logic_vector (19 downto 0);
  signal n410_o : std_logic_vector (19 downto 0);
  signal n411_o : std_logic_vector (11 downto 0);
  signal n412_o : std_logic_vector (7 downto 0);
  signal n413_o : std_logic_vector (19 downto 0);
  signal n414_o : std_logic_vector (19 downto 0);
  signal n415_o : std_logic_vector (19 downto 0);
  signal n416_o : std_logic_vector (19 downto 0);
  signal n417_o : std_logic_vector (11 downto 0);
  signal n418_o : std_logic_vector (7 downto 0);
  signal n419_o : std_logic_vector (19 downto 0);
  signal n420_o : std_logic_vector (19 downto 0);
  signal n421_o : std_logic_vector (19 downto 0);
  signal n422_o : std_logic_vector (19 downto 0);
  signal n423_o : std_logic_vector (11 downto 0);
  signal n424_o : std_logic_vector (7 downto 0);
  signal n425_o : std_logic_vector (19 downto 0);
  signal n426_o : std_logic_vector (19 downto 0);
  signal n427_o : std_logic_vector (19 downto 0);
  signal n428_o : std_logic_vector (19 downto 0);
  signal n429_o : std_logic_vector (11 downto 0);
  signal n430_o : std_logic_vector (7 downto 0);
  signal n431_o : std_logic_vector (19 downto 0);
  signal n432_o : std_logic_vector (19 downto 0);
  signal n433_o : std_logic_vector (19 downto 0);
  signal n434_o : std_logic_vector (19 downto 0);
  signal n435_o : std_logic_vector (11 downto 0);
  signal n436_o : std_logic_vector (7 downto 0);
  signal n437_o : std_logic_vector (19 downto 0);
  signal n438_o : std_logic_vector (19 downto 0);
  signal n439_o : std_logic_vector (19 downto 0);
  signal n440_o : std_logic_vector (19 downto 0);
  signal n441_o : std_logic_vector (16 downto 0);
  signal n442_o : std_logic_vector (11 downto 0);
  signal n443_o : std_logic_vector (11 downto 0);
  signal n444_o : std_logic_vector (7 downto 0);
  signal n445_o : std_logic_vector (19 downto 0);
  signal n446_o : std_logic_vector (19 downto 0);
  signal n447_o : std_logic_vector (19 downto 0);
  signal n449_o : std_logic_vector (19 downto 0);
  signal n451_o : std_logic_vector (11 downto 0);
  signal n452_o : std_logic_vector (7 downto 0);
  signal n453_o : std_logic_vector (19 downto 0);
  signal n454_o : std_logic_vector (19 downto 0);
  signal n455_o : std_logic_vector (19 downto 0);
  signal n456_o : std_logic_vector (19 downto 0);
  signal n457_o : std_logic_vector (11 downto 0);
  signal n458_o : std_logic_vector (7 downto 0);
  signal n459_o : std_logic_vector (19 downto 0);
  signal n460_o : std_logic_vector (19 downto 0);
  signal n461_o : std_logic_vector (19 downto 0);
  signal n462_o : std_logic_vector (19 downto 0);
  signal n463_o : std_logic_vector (11 downto 0);
  signal n464_o : std_logic_vector (7 downto 0);
  signal n465_o : std_logic_vector (19 downto 0);
  signal n466_o : std_logic_vector (19 downto 0);
  signal n467_o : std_logic_vector (19 downto 0);
  signal n468_o : std_logic_vector (19 downto 0);
  signal n469_o : std_logic_vector (11 downto 0);
  signal n470_o : std_logic_vector (7 downto 0);
  signal n471_o : std_logic_vector (19 downto 0);
  signal n472_o : std_logic_vector (19 downto 0);
  signal n473_o : std_logic_vector (19 downto 0);
  signal n474_o : std_logic_vector (19 downto 0);
  signal n475_o : std_logic_vector (11 downto 0);
  signal n476_o : std_logic_vector (7 downto 0);
  signal n477_o : std_logic_vector (19 downto 0);
  signal n478_o : std_logic_vector (19 downto 0);
  signal n479_o : std_logic_vector (19 downto 0);
  signal n480_o : std_logic_vector (19 downto 0);
  signal n481_o : std_logic_vector (11 downto 0);
  signal n482_o : std_logic_vector (7 downto 0);
  signal n483_o : std_logic_vector (19 downto 0);
  signal n484_o : std_logic_vector (19 downto 0);
  signal n485_o : std_logic_vector (19 downto 0);
  signal n486_o : std_logic_vector (19 downto 0);
  signal n487_o : std_logic_vector (11 downto 0);
  signal n488_o : std_logic_vector (7 downto 0);
  signal n489_o : std_logic_vector (19 downto 0);
  signal n490_o : std_logic_vector (19 downto 0);
  signal n491_o : std_logic_vector (19 downto 0);
  signal n492_o : std_logic_vector (19 downto 0);
  signal n493_o : std_logic_vector (16 downto 0);
  signal n494_o : std_logic_vector (11 downto 0);
  signal n495_o : std_logic_vector (11 downto 0);
  signal n496_o : std_logic_vector (7 downto 0);
  signal n497_o : std_logic_vector (19 downto 0);
  signal n498_o : std_logic_vector (19 downto 0);
  signal n499_o : std_logic_vector (19 downto 0);
  signal n501_o : std_logic_vector (19 downto 0);
  signal n503_o : std_logic_vector (11 downto 0);
  signal n504_o : std_logic_vector (7 downto 0);
  signal n505_o : std_logic_vector (19 downto 0);
  signal n506_o : std_logic_vector (19 downto 0);
  signal n507_o : std_logic_vector (19 downto 0);
  signal n508_o : std_logic_vector (19 downto 0);
  signal n509_o : std_logic_vector (11 downto 0);
  signal n510_o : std_logic_vector (7 downto 0);
  signal n511_o : std_logic_vector (19 downto 0);
  signal n512_o : std_logic_vector (19 downto 0);
  signal n513_o : std_logic_vector (19 downto 0);
  signal n514_o : std_logic_vector (19 downto 0);
  signal n515_o : std_logic_vector (11 downto 0);
  signal n516_o : std_logic_vector (7 downto 0);
  signal n517_o : std_logic_vector (19 downto 0);
  signal n518_o : std_logic_vector (19 downto 0);
  signal n519_o : std_logic_vector (19 downto 0);
  signal n520_o : std_logic_vector (19 downto 0);
  signal n521_o : std_logic_vector (11 downto 0);
  signal n522_o : std_logic_vector (7 downto 0);
  signal n523_o : std_logic_vector (19 downto 0);
  signal n524_o : std_logic_vector (19 downto 0);
  signal n525_o : std_logic_vector (19 downto 0);
  signal n526_o : std_logic_vector (19 downto 0);
  signal n527_o : std_logic_vector (11 downto 0);
  signal n528_o : std_logic_vector (7 downto 0);
  signal n529_o : std_logic_vector (19 downto 0);
  signal n530_o : std_logic_vector (19 downto 0);
  signal n531_o : std_logic_vector (19 downto 0);
  signal n532_o : std_logic_vector (19 downto 0);
  signal n533_o : std_logic_vector (11 downto 0);
  signal n534_o : std_logic_vector (7 downto 0);
  signal n535_o : std_logic_vector (19 downto 0);
  signal n536_o : std_logic_vector (19 downto 0);
  signal n537_o : std_logic_vector (19 downto 0);
  signal n538_o : std_logic_vector (19 downto 0);
  signal n539_o : std_logic_vector (11 downto 0);
  signal n540_o : std_logic_vector (7 downto 0);
  signal n541_o : std_logic_vector (19 downto 0);
  signal n542_o : std_logic_vector (19 downto 0);
  signal n543_o : std_logic_vector (19 downto 0);
  signal n544_o : std_logic_vector (19 downto 0);
  signal n545_o : std_logic_vector (16 downto 0);
  signal n546_o : std_logic_vector (11 downto 0);
  signal n548_o : std_logic;
  signal n550_o : std_logic_vector (2 downto 0);
  signal n552_o : std_logic_vector (2 downto 0);
  signal n554_o : std_logic;
  signal n555_o : std_logic_vector (5 downto 0);
  signal n557_o : std_logic_vector (11 downto 0);
  signal n559_o : std_logic_vector (11 downto 0);
  signal n561_o : std_logic_vector (95 downto 0);
  signal n563_o : std_logic_vector (95 downto 0);
  signal n565_o : std_logic_vector (95 downto 0);
  signal n567_o : std_logic_vector (95 downto 0);
  signal n569_o : std_logic_vector (11 downto 0);
  signal n571_o : std_logic_vector (11 downto 0);
  signal n575_o : std_logic_vector (2 downto 0);
  signal n577_o : std_logic_vector (2 downto 0);
  signal n592_o : std_logic_vector (11 downto 0);
  signal n594_o : std_logic_vector (11 downto 0);
  signal n597_o : std_logic_vector (95 downto 0);
  signal n598_o : std_logic_vector (95 downto 0);
  signal n599_o : std_logic_vector (95 downto 0);
  signal n600_o : std_logic_vector (95 downto 0);
  signal n601_o : std_logic_vector (11 downto 0);
  signal n602_o : std_logic_vector (11 downto 0);
  signal n605_o : std_logic_vector (2 downto 0);
  signal n609_o : std_logic_vector (2 downto 0);
  signal n634_o : std_logic_vector (11 downto 0);
  signal n635_q : std_logic_vector (11 downto 0);
  signal n636_o : std_logic_vector (11 downto 0);
  signal n637_q : std_logic_vector (11 downto 0);
  signal n638_q : std_logic_vector (11 downto 0);
  signal n639_q : std_logic_vector (11 downto 0);
  signal n640_o : std_logic_vector (7 downto 0);
  signal n641_q : std_logic_vector (7 downto 0);
  signal n642_q : std_logic_vector (95 downto 0) := "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
  signal n643_q : std_logic_vector (95 downto 0) := "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
  signal n644_q : std_logic_vector (95 downto 0) := "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
  signal n645_q : std_logic_vector (95 downto 0) := "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
  signal n646_q : std_logic_vector (11 downto 0);
  signal n647_q : std_logic_vector (11 downto 0);
  signal n648_o : std_logic;
  signal n649_o : std_logic;
  signal n650_o : std_logic;
  signal n652_q : std_logic_vector (2 downto 0);
  signal n655_q : std_logic_vector (2 downto 0) := "000";
  signal n660_o : std_logic;
  signal n667_o : std_logic;
  signal n669_o : std_logic;
  signal n670_o : std_logic;
  signal n672_o : std_logic;
  signal n673_o : std_logic;
  signal n675_o : std_logic;
  signal n676_o : std_logic;
  signal n677_o : std_logic;
  signal n679_o : std_logic;
  signal n681_o : std_logic_vector (4 downto 0);
  signal n682_o : std_logic;
  signal n683_o : std_logic;
  signal n684_o : std_logic;
  signal n685_o : std_logic_vector (14 downto 0);
  signal n687_o : std_logic_vector (15 downto 0);
  signal n688_o : std_logic_vector (14 downto 0);
  signal n689_o : std_logic_vector (15 downto 0);
  signal n692_o : std_logic;
  signal n693_o : std_logic;
  signal n694_o : std_logic_vector (15 downto 0);
  signal n695_o : std_logic_vector (15 downto 0);
  signal n697_o : std_logic;
  signal n698_o : std_logic;
  signal n700_o : std_logic;
  signal n703_o : std_logic;
  signal n704_o : std_logic_vector (4 downto 0);
  signal n705_o : std_logic;
  signal n706_o : std_logic_vector (15 downto 0);
  signal n709_o : std_logic;
  signal n710_o : std_logic;
  signal n711_o : std_logic;
  signal n712_o : std_logic;
  signal n714_o : std_logic;
  signal n715_o : std_logic;
  signal n716_o : std_logic;
  signal n717_o : std_logic;
  signal n719_o : std_logic;
  signal n720_o : std_logic;
  signal n721_o : std_logic;
  signal n723_o : std_logic;
  signal n725_o : std_logic;
  signal n727_o : std_logic_vector (4 downto 0);
  signal n729_o : std_logic_vector (15 downto 0);
  signal n730_o : std_logic_vector (15 downto 0);
  signal n732_o : std_logic;
  signal n734_o : std_logic;
  signal n736_o : std_logic;
  signal n738_o : std_logic;
  signal n740_o : std_logic;
  signal n742_o : std_logic_vector (4 downto 0);
  signal n743_o : std_logic_vector (15 downto 0);
  signal n744_o : std_logic_vector (15 downto 0);
  signal n746_o : std_logic;
  signal n749_o : std_logic;
  signal n751_o : std_logic;
  signal n753_o : std_logic;
  signal n755_o : std_logic;
  signal n757_o : std_logic_vector (4 downto 0);
  signal n758_o : std_logic_vector (15 downto 0);
  signal n759_o : std_logic_vector (15 downto 0);
  signal n761_o : std_logic;
  signal n771_q : std_logic;
  signal n772_q : std_logic;
  signal n773_q : std_logic := '0';
  signal n774_q : std_logic := '0';
  signal n775_q : std_logic_vector (4 downto 0) := "00000";
  signal n776_q : std_logic_vector (15 downto 0);
  signal n777_q : std_logic_vector (15 downto 0);
  signal n778_q : std_logic := '0';
  signal n780_o : std_logic;
  signal n782_o : std_logic;
  signal n787_o : std_logic;
  signal n788_o : std_logic;
  signal n790_o : std_logic;
  signal n795_o : std_logic;
  signal n796_o : std_logic;
  signal n803_o : std_logic;
  signal n805_o : std_logic;
  signal n806_o : std_logic;
  signal n808_o : std_logic;
  signal n809_o : std_logic;
  signal n811_o : std_logic;
  signal n812_o : std_logic;
  signal n813_o : std_logic;
  signal n815_o : std_logic_vector (15 downto 0);
  signal n817_o : std_logic;
  signal n819_o : std_logic;
  signal n820_o : std_logic;
  signal n822_o : std_logic;
  signal n824_o : std_logic_vector (15 downto 0);
  signal n826_o : std_logic;
  signal n828_o : std_logic_vector (15 downto 0);
  signal n829_o : std_logic_vector (1 downto 0);
  signal n831_o : std_logic_vector (1 downto 0);
  signal n833_o : std_logic_vector (5 downto 0);
  signal n834_o : std_logic_vector (5 downto 0);
  signal n835_o : std_logic_vector (1 downto 0);
  signal n837_o : std_logic_vector (1 downto 0);
  signal n839_o : std_logic_vector (4 downto 0);
  signal n840_o : std_logic_vector (4 downto 0);
  signal n842_o : std_logic;
  signal n844_o : std_logic_vector (15 downto 0);
  signal n845_o : std_logic_vector (7 downto 0);
  signal n847_o : std_logic_vector (7 downto 0);
  signal n851_q : std_logic_vector (7 downto 0);
  signal n852_q : std_logic_vector (7 downto 0);
  signal n853_q : std_logic_vector (15 downto 0) := "0000000000000000";
  signal n856_o : std_logic;
  signal n858_o : std_logic;
  signal n860_o : std_logic;
  signal n862_o : std_logic;
  signal n863_o : std_logic_vector (3 downto 0);
  signal n869_o : std_logic_vector (7 downto 0);
  signal n871_o : std_logic_vector (7 downto 0);
  signal n873_o : std_logic;
  signal n874_o : std_logic;
  signal n875_o : std_logic;
  signal n876_o : std_logic;
  signal n877_o : std_logic;
  signal n878_o : std_logic;
  signal n879_o : std_logic;
  signal n880_o : std_logic;
  signal n881_o : std_logic;
  signal n882_o : std_logic;
  signal n883_o : std_logic;
  signal n884_o : std_logic;
  signal n885_o : std_logic;
  signal n886_o : std_logic;
  signal n887_o : std_logic;
  signal n888_o : std_logic;
  signal n889_o : std_logic;
  signal n890_o : std_logic;
  signal n891_o : std_logic_vector (11 downto 0);
  signal n892_o : std_logic_vector (11 downto 0);
  signal n893_o : std_logic_vector (11 downto 0);
  signal n894_o : std_logic_vector (11 downto 0);
  signal n895_o : std_logic_vector (11 downto 0);
  signal n896_o : std_logic_vector (11 downto 0);
  signal n897_o : std_logic_vector (11 downto 0);
  signal n898_o : std_logic_vector (11 downto 0);
  signal n899_o : std_logic_vector (11 downto 0);
  signal n900_o : std_logic_vector (11 downto 0);
  signal n901_o : std_logic_vector (11 downto 0);
  signal n902_o : std_logic_vector (11 downto 0);
  signal n903_o : std_logic_vector (11 downto 0);
  signal n904_o : std_logic_vector (11 downto 0);
  signal n905_o : std_logic_vector (11 downto 0);
  signal n906_o : std_logic_vector (11 downto 0);
  signal n907_o : std_logic_vector (95 downto 0);
  signal n908_o : std_logic;
  signal n909_o : std_logic;
  signal n910_o : std_logic;
  signal n911_o : std_logic;
  signal n912_o : std_logic;
  signal n913_o : std_logic;
  signal n914_o : std_logic;
  signal n915_o : std_logic;
  signal n916_o : std_logic;
  signal n917_o : std_logic;
  signal n918_o : std_logic;
  signal n919_o : std_logic;
  signal n920_o : std_logic;
  signal n921_o : std_logic;
  signal n922_o : std_logic;
  signal n923_o : std_logic;
  signal n924_o : std_logic;
  signal n925_o : std_logic;
  signal n926_o : std_logic_vector (11 downto 0);
  signal n927_o : std_logic_vector (11 downto 0);
  signal n928_o : std_logic_vector (11 downto 0);
  signal n929_o : std_logic_vector (11 downto 0);
  signal n930_o : std_logic_vector (11 downto 0);
  signal n931_o : std_logic_vector (11 downto 0);
  signal n932_o : std_logic_vector (11 downto 0);
  signal n933_o : std_logic_vector (11 downto 0);
  signal n934_o : std_logic_vector (11 downto 0);
  signal n935_o : std_logic_vector (11 downto 0);
  signal n936_o : std_logic_vector (11 downto 0);
  signal n937_o : std_logic_vector (11 downto 0);
  signal n938_o : std_logic_vector (11 downto 0);
  signal n939_o : std_logic_vector (11 downto 0);
  signal n940_o : std_logic_vector (11 downto 0);
  signal n941_o : std_logic_vector (11 downto 0);
  signal n942_o : std_logic_vector (95 downto 0);
  signal n943_o : std_logic;
  signal n944_o : std_logic;
  signal n945_o : std_logic;
  signal n946_o : std_logic;
  signal n947_o : std_logic;
  signal n948_o : std_logic;
  signal n949_o : std_logic;
  signal n950_o : std_logic;
  signal n951_o : std_logic;
  signal n952_o : std_logic;
  signal n953_o : std_logic;
  signal n954_o : std_logic;
  signal n955_o : std_logic;
  signal n956_o : std_logic;
  signal n957_o : std_logic;
  signal n958_o : std_logic;
  signal n959_o : std_logic;
  signal n960_o : std_logic;
  signal n961_o : std_logic_vector (11 downto 0);
  signal n962_o : std_logic_vector (11 downto 0);
  signal n963_o : std_logic_vector (11 downto 0);
  signal n964_o : std_logic_vector (11 downto 0);
  signal n965_o : std_logic_vector (11 downto 0);
  signal n966_o : std_logic_vector (11 downto 0);
  signal n967_o : std_logic_vector (11 downto 0);
  signal n968_o : std_logic_vector (11 downto 0);
  signal n969_o : std_logic_vector (11 downto 0);
  signal n970_o : std_logic_vector (11 downto 0);
  signal n971_o : std_logic_vector (11 downto 0);
  signal n972_o : std_logic_vector (11 downto 0);
  signal n973_o : std_logic_vector (11 downto 0);
  signal n974_o : std_logic_vector (11 downto 0);
  signal n975_o : std_logic_vector (11 downto 0);
  signal n976_o : std_logic_vector (11 downto 0);
  signal n977_o : std_logic_vector (95 downto 0);
  signal n978_o : std_logic;
  signal n979_o : std_logic;
  signal n980_o : std_logic;
  signal n981_o : std_logic;
  signal n982_o : std_logic;
  signal n983_o : std_logic;
  signal n984_o : std_logic;
  signal n985_o : std_logic;
  signal n986_o : std_logic;
  signal n987_o : std_logic;
  signal n988_o : std_logic;
  signal n989_o : std_logic;
  signal n990_o : std_logic;
  signal n991_o : std_logic;
  signal n992_o : std_logic;
  signal n993_o : std_logic;
  signal n994_o : std_logic;
  signal n995_o : std_logic;
  signal n996_o : std_logic_vector (11 downto 0);
  signal n997_o : std_logic_vector (11 downto 0);
  signal n998_o : std_logic_vector (11 downto 0);
  signal n999_o : std_logic_vector (11 downto 0);
  signal n1000_o : std_logic_vector (11 downto 0);
  signal n1001_o : std_logic_vector (11 downto 0);
  signal n1002_o : std_logic_vector (11 downto 0);
  signal n1003_o : std_logic_vector (11 downto 0);
  signal n1004_o : std_logic_vector (11 downto 0);
  signal n1005_o : std_logic_vector (11 downto 0);
  signal n1006_o : std_logic_vector (11 downto 0);
  signal n1007_o : std_logic_vector (11 downto 0);
  signal n1008_o : std_logic_vector (11 downto 0);
  signal n1009_o : std_logic_vector (11 downto 0);
  signal n1010_o : std_logic_vector (11 downto 0);
  signal n1011_o : std_logic_vector (11 downto 0);
  signal n1012_o : std_logic_vector (95 downto 0);
  signal n1013_o : std_logic;
  signal n1014_o : std_logic;
  signal n1015_o : std_logic;
  signal n1016_o : std_logic;
  signal n1017_o : std_logic;
  signal n1018_o : std_logic;
  signal n1019_o : std_logic;
  signal n1020_o : std_logic;
  signal n1021_o : std_logic;
  signal n1022_o : std_logic;
  signal n1023_o : std_logic;
  signal n1024_o : std_logic;
  signal n1025_o : std_logic;
  signal n1026_o : std_logic;
  signal n1027_o : std_logic;
  signal n1028_o : std_logic;
  signal n1029_o : std_logic;
  signal n1030_o : std_logic;
  signal n1031_o : std_logic_vector (7 downto 0);
  signal n1032_o : std_logic;
  signal n1033_o : std_logic_vector (7 downto 0);
  signal n1034_o : std_logic_vector (7 downto 0);
  signal n1035_o : std_logic;
  signal n1036_o : std_logic_vector (7 downto 0);
  signal n1037_o : std_logic_vector (7 downto 0);
  signal n1038_o : std_logic;
  signal n1039_o : std_logic_vector (7 downto 0);
  signal n1040_o : std_logic_vector (7 downto 0);
  signal n1041_o : std_logic;
  signal n1042_o : std_logic_vector (7 downto 0);
  signal n1043_o : std_logic_vector (7 downto 0);
  signal n1044_o : std_logic;
  signal n1045_o : std_logic_vector (7 downto 0);
  signal n1046_o : std_logic_vector (7 downto 0);
  signal n1047_o : std_logic;
  signal n1048_o : std_logic_vector (7 downto 0);
  signal n1049_o : std_logic_vector (7 downto 0);
  signal n1050_o : std_logic;
  signal n1051_o : std_logic_vector (7 downto 0);
  signal n1052_o : std_logic_vector (7 downto 0);
  signal n1053_o : std_logic;
  signal n1054_o : std_logic_vector (7 downto 0);
  signal n1055_o : std_logic_vector (63 downto 0);
begin
  scl <= n245_oport;
  sda <= n246_oport;
  adc_spi_sclk <= n771_q;
  adc_spi_mosi <= n772_q;
  adc_spi_cs_n <= cs_control;
  voc_data <= n635_q;
  aq_data <= n637_q;
  pressure_data <= n638_q;
  temp_data <= n639_q;
  flow_data <= n641_q;
  sensor_status <= n851_q;
  error_flags <= n852_q;
  -- ../src/hdl/sensors/sensor_hub.vhd:13:9
  n245_oport <= "ZZZZ"; -- (inout - port)
  n245_o <= scl; -- (inout - read)
  -- ../src/hdl/sensors/sensor_hub.vhd:14:9
  n246_oport <= "ZZZZ"; -- (inout - port)
  n246_o <= sda; -- (inout - read)
  -- ../src/hdl/sensors/sensor_hub.vhd:53:12
  voc_buffer <= n642_q; -- (isignal)
  -- ../src/hdl/sensors/sensor_hub.vhd:54:12
  aq_buffer <= n643_q; -- (isignal)
  -- ../src/hdl/sensors/sensor_hub.vhd:55:12
  pressure_buffer <= n644_q; -- (isignal)
  -- ../src/hdl/sensors/sensor_hub.vhd:56:12
  temp_buffer <= n645_q; -- (isignal)
  -- ../src/hdl/sensors/sensor_hub.vhd:57:12
  voc_data_internal <= n646_q; -- (signal)
  -- ../src/hdl/sensors/sensor_hub.vhd:58:12
  aq_data_internal <= n647_q; -- (signal)
  -- ../src/hdl/sensors/sensor_hub.vhd:62:12
  cal_storage <= n1055_o; -- (isignal)
  -- ../src/hdl/sensors/sensor_hub.vhd:73:12
  current_state <= n652_q; -- (signal)
  -- ../src/hdl/sensors/sensor_hub.vhd:75:12
  buffer_index <= n655_q; -- (isignal)
  -- ../src/hdl/sensors/sensor_hub.vhd:78:12
  spi_active <= n773_q; -- (isignal)
  -- ../src/hdl/sensors/sensor_hub.vhd:79:12
  spi_done <= n774_q; -- (isignal)
  -- ../src/hdl/sensors/sensor_hub.vhd:80:12
  spi_counter <= n775_q; -- (isignal)
  -- ../src/hdl/sensors/sensor_hub.vhd:81:12
  spi_data_out <= n776_q; -- (signal)
  -- ../src/hdl/sensors/sensor_hub.vhd:82:12
  spi_data_in <= n777_q; -- (signal)
  -- ../src/hdl/sensors/sensor_hub.vhd:88:12
  sample_timeout <= n853_q; -- (isignal)
  -- ../src/hdl/sensors/sensor_hub.vhd:89:12
  adc_valid <= n778_q; -- (isignal)
  -- ../src/hdl/sensors/sensor_hub.vhd:101:12
  cs_control <= n871_o; -- (signal)
  -- ../src/hdl/sensors/sensor_hub.vhd:111:12
  n276_o <= '1' when rising_edge (clk) else '0';
  -- ../src/hdl/sensors/sensor_hub.vhd:127:35
  n277_o <= cal_mode and cal_wr;
  -- ../src/hdl/sensors/sensor_hub.vhd:128:43
  n279_o <= '1' when unsigned (cal_addr) < unsigned'("00001000") else '0';
  -- ../src/hdl/sensors/sensor_hub.vhd:129:36
  n281_o <= cal_addr (2 downto 0);  --  trunc
  -- ../src/hdl/sensors/sensor_hub.vhd:129:36
  n283_o <= std_logic_vector (unsigned'("111") - unsigned (n281_o));
  -- ../src/hdl/sensors/sensor_hub.vhd:129:89
  n285_o <= cal_data (7 downto 0);
  -- ../src/hdl/sensors/sensor_hub.vhd:127:17
  n288_o <= n277_o and n279_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:135:21
  n290_o <= '1' when current_state = "000" else '0';
  -- ../src/hdl/sensors/sensor_hub.vhd:142:39
  n293_o <= std_logic_vector (unsigned'("111") - unsigned (buffer_index));
  -- ../src/hdl/sensors/sensor_hub.vhd:142:89
  n295_o <= spi_data_in (11 downto 0);
  -- ../src/hdl/sensors/sensor_hub.vhd:141:25
  n297_o <= voc_buffer when adc_valid = '0' else n907_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:141:25
  n299_o <= current_state when adc_valid = '0' else "010";
  -- ../src/hdl/sensors/sensor_hub.vhd:140:21
  n301_o <= '1' when current_state = "001" else '0';
  -- ../src/hdl/sensors/sensor_hub.vhd:148:38
  n304_o <= std_logic_vector (unsigned'("111") - unsigned (buffer_index));
  -- ../src/hdl/sensors/sensor_hub.vhd:148:88
  n306_o <= spi_data_in (11 downto 0);
  -- ../src/hdl/sensors/sensor_hub.vhd:147:25
  n308_o <= aq_buffer when adc_valid = '0' else n942_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:147:25
  n310_o <= current_state when adc_valid = '0' else "011";
  -- ../src/hdl/sensors/sensor_hub.vhd:146:21
  n312_o <= '1' when current_state = "010" else '0';
  -- ../src/hdl/sensors/sensor_hub.vhd:154:44
  n315_o <= std_logic_vector (unsigned'("111") - unsigned (buffer_index));
  -- ../src/hdl/sensors/sensor_hub.vhd:154:94
  n317_o <= spi_data_in (11 downto 0);
  -- ../src/hdl/sensors/sensor_hub.vhd:153:25
  n319_o <= pressure_buffer when adc_valid = '0' else n977_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:153:25
  n321_o <= current_state when adc_valid = '0' else "100";
  -- ../src/hdl/sensors/sensor_hub.vhd:152:21
  n323_o <= '1' when current_state = "011" else '0';
  -- ../src/hdl/sensors/sensor_hub.vhd:160:40
  n326_o <= std_logic_vector (unsigned'("111") - unsigned (buffer_index));
  -- ../src/hdl/sensors/sensor_hub.vhd:160:90
  n328_o <= spi_data_in (11 downto 0);
  -- ../src/hdl/sensors/sensor_hub.vhd:159:25
  n330_o <= temp_buffer when adc_valid = '0' else n1012_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:159:25
  n332_o <= current_state when adc_valid = '0' else "101";
  -- ../src/hdl/sensors/sensor_hub.vhd:158:21
  n338_o <= '1' when current_state = "100" else '0';
  -- ../src/hdl/sensors/sensor_hub.vhd:170:61
  n339_o <= voc_buffer (95 downto 84);
  -- ../src/hdl/sensors/sensor_hub.vhd:170:78
  n340_o <= cal_storage (63 downto 56);
  -- ../src/hdl/sensors/sensor_hub.vhd:170:65
  n341_o <= "00000000" & n339_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:170:65
  n342_o <= "000000000000" & n340_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:170:65
  n343_o <= std_logic_vector (resize (signed (n341_o) * signed (n342_o), 20));
  -- ../src/hdl/sensors/sensor_hub.vhd:170:48
  n345_o <= std_logic_vector (unsigned'("00000000000000000000") + unsigned (n343_o));
  -- ../src/hdl/sensors/sensor_hub.vhd:170:61
  n347_o <= voc_buffer (83 downto 72);
  -- ../src/hdl/sensors/sensor_hub.vhd:170:78
  n348_o <= cal_storage (63 downto 56);
  -- ../src/hdl/sensors/sensor_hub.vhd:170:65
  n349_o <= "00000000" & n347_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:170:65
  n350_o <= "000000000000" & n348_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:170:65
  n351_o <= std_logic_vector (resize (signed (n349_o) * signed (n350_o), 20));
  -- ../src/hdl/sensors/sensor_hub.vhd:170:48
  n352_o <= std_logic_vector (unsigned (n345_o) + unsigned (n351_o));
  -- ../src/hdl/sensors/sensor_hub.vhd:170:61
  n353_o <= voc_buffer (71 downto 60);
  -- ../src/hdl/sensors/sensor_hub.vhd:170:78
  n354_o <= cal_storage (63 downto 56);
  -- ../src/hdl/sensors/sensor_hub.vhd:170:65
  n355_o <= "00000000" & n353_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:170:65
  n356_o <= "000000000000" & n354_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:170:65
  n357_o <= std_logic_vector (resize (signed (n355_o) * signed (n356_o), 20));
  -- ../src/hdl/sensors/sensor_hub.vhd:170:48
  n358_o <= std_logic_vector (unsigned (n352_o) + unsigned (n357_o));
  -- ../src/hdl/sensors/sensor_hub.vhd:170:61
  n359_o <= voc_buffer (59 downto 48);
  -- ../src/hdl/sensors/sensor_hub.vhd:170:78
  n360_o <= cal_storage (63 downto 56);
  -- ../src/hdl/sensors/sensor_hub.vhd:170:65
  n361_o <= "00000000" & n359_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:170:65
  n362_o <= "000000000000" & n360_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:170:65
  n363_o <= std_logic_vector (resize (signed (n361_o) * signed (n362_o), 20));
  -- ../src/hdl/sensors/sensor_hub.vhd:170:48
  n364_o <= std_logic_vector (unsigned (n358_o) + unsigned (n363_o));
  -- ../src/hdl/sensors/sensor_hub.vhd:170:61
  n365_o <= voc_buffer (47 downto 36);
  -- ../src/hdl/sensors/sensor_hub.vhd:170:78
  n366_o <= cal_storage (63 downto 56);
  -- ../src/hdl/sensors/sensor_hub.vhd:170:65
  n367_o <= "00000000" & n365_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:170:65
  n368_o <= "000000000000" & n366_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:170:65
  n369_o <= std_logic_vector (resize (signed (n367_o) * signed (n368_o), 20));
  -- ../src/hdl/sensors/sensor_hub.vhd:170:48
  n370_o <= std_logic_vector (unsigned (n364_o) + unsigned (n369_o));
  -- ../src/hdl/sensors/sensor_hub.vhd:170:61
  n371_o <= voc_buffer (35 downto 24);
  -- ../src/hdl/sensors/sensor_hub.vhd:170:78
  n372_o <= cal_storage (63 downto 56);
  -- ../src/hdl/sensors/sensor_hub.vhd:170:65
  n373_o <= "00000000" & n371_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:170:65
  n374_o <= "000000000000" & n372_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:170:65
  n375_o <= std_logic_vector (resize (signed (n373_o) * signed (n374_o), 20));
  -- ../src/hdl/sensors/sensor_hub.vhd:170:48
  n376_o <= std_logic_vector (unsigned (n370_o) + unsigned (n375_o));
  -- ../src/hdl/sensors/sensor_hub.vhd:170:61
  n377_o <= voc_buffer (23 downto 12);
  -- ../src/hdl/sensors/sensor_hub.vhd:170:78
  n378_o <= cal_storage (63 downto 56);
  -- ../src/hdl/sensors/sensor_hub.vhd:170:65
  n379_o <= "00000000" & n377_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:170:65
  n380_o <= "000000000000" & n378_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:170:65
  n381_o <= std_logic_vector (resize (signed (n379_o) * signed (n380_o), 20));
  -- ../src/hdl/sensors/sensor_hub.vhd:170:48
  n382_o <= std_logic_vector (unsigned (n376_o) + unsigned (n381_o));
  -- ../src/hdl/sensors/sensor_hub.vhd:170:61
  n383_o <= voc_buffer (11 downto 0);
  -- ../src/hdl/sensors/sensor_hub.vhd:170:78
  n384_o <= cal_storage (63 downto 56);
  -- ../src/hdl/sensors/sensor_hub.vhd:170:65
  n385_o <= "00000000" & n383_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:170:65
  n386_o <= "000000000000" & n384_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:170:65
  n387_o <= std_logic_vector (resize (signed (n385_o) * signed (n386_o), 20));
  -- ../src/hdl/sensors/sensor_hub.vhd:170:48
  n388_o <= std_logic_vector (unsigned (n382_o) + unsigned (n387_o));
  -- ../src/hdl/sensors/sensor_hub.vhd:172:77
  n389_o <= n388_o (19 downto 3);
  -- ../src/hdl/sensors/sensor_hub.vhd:172:63
  n390_o <= n389_o (11 downto 0);  --  trunc
  -- ../src/hdl/sensors/sensor_hub.vhd:177:60
  n391_o <= aq_buffer (95 downto 84);
  -- ../src/hdl/sensors/sensor_hub.vhd:177:77
  n392_o <= cal_storage (55 downto 48);
  -- ../src/hdl/sensors/sensor_hub.vhd:177:64
  n393_o <= "00000000" & n391_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:177:64
  n394_o <= "000000000000" & n392_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:177:64
  n395_o <= std_logic_vector (resize (signed (n393_o) * signed (n394_o), 20));
  -- ../src/hdl/sensors/sensor_hub.vhd:177:48
  n397_o <= std_logic_vector (unsigned'("00000000000000000000") + unsigned (n395_o));
  -- ../src/hdl/sensors/sensor_hub.vhd:177:60
  n399_o <= aq_buffer (83 downto 72);
  -- ../src/hdl/sensors/sensor_hub.vhd:177:77
  n400_o <= cal_storage (55 downto 48);
  -- ../src/hdl/sensors/sensor_hub.vhd:177:64
  n401_o <= "00000000" & n399_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:177:64
  n402_o <= "000000000000" & n400_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:177:64
  n403_o <= std_logic_vector (resize (signed (n401_o) * signed (n402_o), 20));
  -- ../src/hdl/sensors/sensor_hub.vhd:177:48
  n404_o <= std_logic_vector (unsigned (n397_o) + unsigned (n403_o));
  -- ../src/hdl/sensors/sensor_hub.vhd:177:60
  n405_o <= aq_buffer (71 downto 60);
  -- ../src/hdl/sensors/sensor_hub.vhd:177:77
  n406_o <= cal_storage (55 downto 48);
  -- ../src/hdl/sensors/sensor_hub.vhd:177:64
  n407_o <= "00000000" & n405_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:177:64
  n408_o <= "000000000000" & n406_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:177:64
  n409_o <= std_logic_vector (resize (signed (n407_o) * signed (n408_o), 20));
  -- ../src/hdl/sensors/sensor_hub.vhd:177:48
  n410_o <= std_logic_vector (unsigned (n404_o) + unsigned (n409_o));
  -- ../src/hdl/sensors/sensor_hub.vhd:177:60
  n411_o <= aq_buffer (59 downto 48);
  -- ../src/hdl/sensors/sensor_hub.vhd:177:77
  n412_o <= cal_storage (55 downto 48);
  -- ../src/hdl/sensors/sensor_hub.vhd:177:64
  n413_o <= "00000000" & n411_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:177:64
  n414_o <= "000000000000" & n412_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:177:64
  n415_o <= std_logic_vector (resize (signed (n413_o) * signed (n414_o), 20));
  -- ../src/hdl/sensors/sensor_hub.vhd:177:48
  n416_o <= std_logic_vector (unsigned (n410_o) + unsigned (n415_o));
  -- ../src/hdl/sensors/sensor_hub.vhd:177:60
  n417_o <= aq_buffer (47 downto 36);
  -- ../src/hdl/sensors/sensor_hub.vhd:177:77
  n418_o <= cal_storage (55 downto 48);
  -- ../src/hdl/sensors/sensor_hub.vhd:177:64
  n419_o <= "00000000" & n417_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:177:64
  n420_o <= "000000000000" & n418_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:177:64
  n421_o <= std_logic_vector (resize (signed (n419_o) * signed (n420_o), 20));
  -- ../src/hdl/sensors/sensor_hub.vhd:177:48
  n422_o <= std_logic_vector (unsigned (n416_o) + unsigned (n421_o));
  -- ../src/hdl/sensors/sensor_hub.vhd:177:60
  n423_o <= aq_buffer (35 downto 24);
  -- ../src/hdl/sensors/sensor_hub.vhd:177:77
  n424_o <= cal_storage (55 downto 48);
  -- ../src/hdl/sensors/sensor_hub.vhd:177:64
  n425_o <= "00000000" & n423_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:177:64
  n426_o <= "000000000000" & n424_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:177:64
  n427_o <= std_logic_vector (resize (signed (n425_o) * signed (n426_o), 20));
  -- ../src/hdl/sensors/sensor_hub.vhd:177:48
  n428_o <= std_logic_vector (unsigned (n422_o) + unsigned (n427_o));
  -- ../src/hdl/sensors/sensor_hub.vhd:177:60
  n429_o <= aq_buffer (23 downto 12);
  -- ../src/hdl/sensors/sensor_hub.vhd:177:77
  n430_o <= cal_storage (55 downto 48);
  -- ../src/hdl/sensors/sensor_hub.vhd:177:64
  n431_o <= "00000000" & n429_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:177:64
  n432_o <= "000000000000" & n430_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:177:64
  n433_o <= std_logic_vector (resize (signed (n431_o) * signed (n432_o), 20));
  -- ../src/hdl/sensors/sensor_hub.vhd:177:48
  n434_o <= std_logic_vector (unsigned (n428_o) + unsigned (n433_o));
  -- ../src/hdl/sensors/sensor_hub.vhd:177:60
  n435_o <= aq_buffer (11 downto 0);
  -- ../src/hdl/sensors/sensor_hub.vhd:177:77
  n436_o <= cal_storage (55 downto 48);
  -- ../src/hdl/sensors/sensor_hub.vhd:177:64
  n437_o <= "00000000" & n435_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:177:64
  n438_o <= "000000000000" & n436_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:177:64
  n439_o <= std_logic_vector (resize (signed (n437_o) * signed (n438_o), 20));
  -- ../src/hdl/sensors/sensor_hub.vhd:177:48
  n440_o <= std_logic_vector (unsigned (n434_o) + unsigned (n439_o));
  -- ../src/hdl/sensors/sensor_hub.vhd:179:76
  n441_o <= n440_o (19 downto 3);
  -- ../src/hdl/sensors/sensor_hub.vhd:179:62
  n442_o <= n441_o (11 downto 0);  --  trunc
  -- ../src/hdl/sensors/sensor_hub.vhd:184:66
  n443_o <= pressure_buffer (95 downto 84);
  -- ../src/hdl/sensors/sensor_hub.vhd:184:83
  n444_o <= cal_storage (47 downto 40);
  -- ../src/hdl/sensors/sensor_hub.vhd:184:70
  n445_o <= "00000000" & n443_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:184:70
  n446_o <= "000000000000" & n444_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:184:70
  n447_o <= std_logic_vector (resize (signed (n445_o) * signed (n446_o), 20));
  -- ../src/hdl/sensors/sensor_hub.vhd:184:48
  n449_o <= std_logic_vector (unsigned'("00000000000000000000") + unsigned (n447_o));
  -- ../src/hdl/sensors/sensor_hub.vhd:184:66
  n451_o <= pressure_buffer (83 downto 72);
  -- ../src/hdl/sensors/sensor_hub.vhd:184:83
  n452_o <= cal_storage (47 downto 40);
  -- ../src/hdl/sensors/sensor_hub.vhd:184:70
  n453_o <= "00000000" & n451_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:184:70
  n454_o <= "000000000000" & n452_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:184:70
  n455_o <= std_logic_vector (resize (signed (n453_o) * signed (n454_o), 20));
  -- ../src/hdl/sensors/sensor_hub.vhd:184:48
  n456_o <= std_logic_vector (unsigned (n449_o) + unsigned (n455_o));
  -- ../src/hdl/sensors/sensor_hub.vhd:184:66
  n457_o <= pressure_buffer (71 downto 60);
  -- ../src/hdl/sensors/sensor_hub.vhd:184:83
  n458_o <= cal_storage (47 downto 40);
  -- ../src/hdl/sensors/sensor_hub.vhd:184:70
  n459_o <= "00000000" & n457_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:184:70
  n460_o <= "000000000000" & n458_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:184:70
  n461_o <= std_logic_vector (resize (signed (n459_o) * signed (n460_o), 20));
  -- ../src/hdl/sensors/sensor_hub.vhd:184:48
  n462_o <= std_logic_vector (unsigned (n456_o) + unsigned (n461_o));
  -- ../src/hdl/sensors/sensor_hub.vhd:184:66
  n463_o <= pressure_buffer (59 downto 48);
  -- ../src/hdl/sensors/sensor_hub.vhd:184:83
  n464_o <= cal_storage (47 downto 40);
  -- ../src/hdl/sensors/sensor_hub.vhd:184:70
  n465_o <= "00000000" & n463_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:184:70
  n466_o <= "000000000000" & n464_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:184:70
  n467_o <= std_logic_vector (resize (signed (n465_o) * signed (n466_o), 20));
  -- ../src/hdl/sensors/sensor_hub.vhd:184:48
  n468_o <= std_logic_vector (unsigned (n462_o) + unsigned (n467_o));
  -- ../src/hdl/sensors/sensor_hub.vhd:184:66
  n469_o <= pressure_buffer (47 downto 36);
  -- ../src/hdl/sensors/sensor_hub.vhd:184:83
  n470_o <= cal_storage (47 downto 40);
  -- ../src/hdl/sensors/sensor_hub.vhd:184:70
  n471_o <= "00000000" & n469_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:184:70
  n472_o <= "000000000000" & n470_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:184:70
  n473_o <= std_logic_vector (resize (signed (n471_o) * signed (n472_o), 20));
  -- ../src/hdl/sensors/sensor_hub.vhd:184:48
  n474_o <= std_logic_vector (unsigned (n468_o) + unsigned (n473_o));
  -- ../src/hdl/sensors/sensor_hub.vhd:184:66
  n475_o <= pressure_buffer (35 downto 24);
  -- ../src/hdl/sensors/sensor_hub.vhd:184:83
  n476_o <= cal_storage (47 downto 40);
  -- ../src/hdl/sensors/sensor_hub.vhd:184:70
  n477_o <= "00000000" & n475_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:184:70
  n478_o <= "000000000000" & n476_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:184:70
  n479_o <= std_logic_vector (resize (signed (n477_o) * signed (n478_o), 20));
  -- ../src/hdl/sensors/sensor_hub.vhd:184:48
  n480_o <= std_logic_vector (unsigned (n474_o) + unsigned (n479_o));
  -- ../src/hdl/sensors/sensor_hub.vhd:184:66
  n481_o <= pressure_buffer (23 downto 12);
  -- ../src/hdl/sensors/sensor_hub.vhd:184:83
  n482_o <= cal_storage (47 downto 40);
  -- ../src/hdl/sensors/sensor_hub.vhd:184:70
  n483_o <= "00000000" & n481_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:184:70
  n484_o <= "000000000000" & n482_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:184:70
  n485_o <= std_logic_vector (resize (signed (n483_o) * signed (n484_o), 20));
  -- ../src/hdl/sensors/sensor_hub.vhd:184:48
  n486_o <= std_logic_vector (unsigned (n480_o) + unsigned (n485_o));
  -- ../src/hdl/sensors/sensor_hub.vhd:184:66
  n487_o <= pressure_buffer (11 downto 0);
  -- ../src/hdl/sensors/sensor_hub.vhd:184:83
  n488_o <= cal_storage (47 downto 40);
  -- ../src/hdl/sensors/sensor_hub.vhd:184:70
  n489_o <= "00000000" & n487_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:184:70
  n490_o <= "000000000000" & n488_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:184:70
  n491_o <= std_logic_vector (resize (signed (n489_o) * signed (n490_o), 20));
  -- ../src/hdl/sensors/sensor_hub.vhd:184:48
  n492_o <= std_logic_vector (unsigned (n486_o) + unsigned (n491_o));
  -- ../src/hdl/sensors/sensor_hub.vhd:186:73
  n493_o <= n492_o (19 downto 3);
  -- ../src/hdl/sensors/sensor_hub.vhd:186:59
  n494_o <= n493_o (11 downto 0);  --  trunc
  -- ../src/hdl/sensors/sensor_hub.vhd:191:62
  n495_o <= temp_buffer (95 downto 84);
  -- ../src/hdl/sensors/sensor_hub.vhd:191:79
  n496_o <= cal_storage (39 downto 32);
  -- ../src/hdl/sensors/sensor_hub.vhd:191:66
  n497_o <= "00000000" & n495_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:191:66
  n498_o <= "000000000000" & n496_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:191:66
  n499_o <= std_logic_vector (resize (signed (n497_o) * signed (n498_o), 20));
  -- ../src/hdl/sensors/sensor_hub.vhd:191:48
  n501_o <= std_logic_vector (unsigned'("00000000000000000000") + unsigned (n499_o));
  -- ../src/hdl/sensors/sensor_hub.vhd:191:62
  n503_o <= temp_buffer (83 downto 72);
  -- ../src/hdl/sensors/sensor_hub.vhd:191:79
  n504_o <= cal_storage (39 downto 32);
  -- ../src/hdl/sensors/sensor_hub.vhd:191:66
  n505_o <= "00000000" & n503_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:191:66
  n506_o <= "000000000000" & n504_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:191:66
  n507_o <= std_logic_vector (resize (signed (n505_o) * signed (n506_o), 20));
  -- ../src/hdl/sensors/sensor_hub.vhd:191:48
  n508_o <= std_logic_vector (unsigned (n501_o) + unsigned (n507_o));
  -- ../src/hdl/sensors/sensor_hub.vhd:191:62
  n509_o <= temp_buffer (71 downto 60);
  -- ../src/hdl/sensors/sensor_hub.vhd:191:79
  n510_o <= cal_storage (39 downto 32);
  -- ../src/hdl/sensors/sensor_hub.vhd:191:66
  n511_o <= "00000000" & n509_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:191:66
  n512_o <= "000000000000" & n510_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:191:66
  n513_o <= std_logic_vector (resize (signed (n511_o) * signed (n512_o), 20));
  -- ../src/hdl/sensors/sensor_hub.vhd:191:48
  n514_o <= std_logic_vector (unsigned (n508_o) + unsigned (n513_o));
  -- ../src/hdl/sensors/sensor_hub.vhd:191:62
  n515_o <= temp_buffer (59 downto 48);
  -- ../src/hdl/sensors/sensor_hub.vhd:191:79
  n516_o <= cal_storage (39 downto 32);
  -- ../src/hdl/sensors/sensor_hub.vhd:191:66
  n517_o <= "00000000" & n515_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:191:66
  n518_o <= "000000000000" & n516_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:191:66
  n519_o <= std_logic_vector (resize (signed (n517_o) * signed (n518_o), 20));
  -- ../src/hdl/sensors/sensor_hub.vhd:191:48
  n520_o <= std_logic_vector (unsigned (n514_o) + unsigned (n519_o));
  -- ../src/hdl/sensors/sensor_hub.vhd:191:62
  n521_o <= temp_buffer (47 downto 36);
  -- ../src/hdl/sensors/sensor_hub.vhd:191:79
  n522_o <= cal_storage (39 downto 32);
  -- ../src/hdl/sensors/sensor_hub.vhd:191:66
  n523_o <= "00000000" & n521_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:191:66
  n524_o <= "000000000000" & n522_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:191:66
  n525_o <= std_logic_vector (resize (signed (n523_o) * signed (n524_o), 20));
  -- ../src/hdl/sensors/sensor_hub.vhd:191:48
  n526_o <= std_logic_vector (unsigned (n520_o) + unsigned (n525_o));
  -- ../src/hdl/sensors/sensor_hub.vhd:191:62
  n527_o <= temp_buffer (35 downto 24);
  -- ../src/hdl/sensors/sensor_hub.vhd:191:79
  n528_o <= cal_storage (39 downto 32);
  -- ../src/hdl/sensors/sensor_hub.vhd:191:66
  n529_o <= "00000000" & n527_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:191:66
  n530_o <= "000000000000" & n528_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:191:66
  n531_o <= std_logic_vector (resize (signed (n529_o) * signed (n530_o), 20));
  -- ../src/hdl/sensors/sensor_hub.vhd:191:48
  n532_o <= std_logic_vector (unsigned (n526_o) + unsigned (n531_o));
  -- ../src/hdl/sensors/sensor_hub.vhd:191:62
  n533_o <= temp_buffer (23 downto 12);
  -- ../src/hdl/sensors/sensor_hub.vhd:191:79
  n534_o <= cal_storage (39 downto 32);
  -- ../src/hdl/sensors/sensor_hub.vhd:191:66
  n535_o <= "00000000" & n533_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:191:66
  n536_o <= "000000000000" & n534_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:191:66
  n537_o <= std_logic_vector (resize (signed (n535_o) * signed (n536_o), 20));
  -- ../src/hdl/sensors/sensor_hub.vhd:191:48
  n538_o <= std_logic_vector (unsigned (n532_o) + unsigned (n537_o));
  -- ../src/hdl/sensors/sensor_hub.vhd:191:62
  n539_o <= temp_buffer (11 downto 0);
  -- ../src/hdl/sensors/sensor_hub.vhd:191:79
  n540_o <= cal_storage (39 downto 32);
  -- ../src/hdl/sensors/sensor_hub.vhd:191:66
  n541_o <= "00000000" & n539_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:191:66
  n542_o <= "000000000000" & n540_o;  --  uext
  -- ../src/hdl/sensors/sensor_hub.vhd:191:66
  n543_o <= std_logic_vector (resize (signed (n541_o) * signed (n542_o), 20));
  -- ../src/hdl/sensors/sensor_hub.vhd:191:48
  n544_o <= std_logic_vector (unsigned (n538_o) + unsigned (n543_o));
  -- ../src/hdl/sensors/sensor_hub.vhd:193:69
  n545_o <= n544_o (19 downto 3);
  -- ../src/hdl/sensors/sensor_hub.vhd:193:55
  n546_o <= n545_o (11 downto 0);  --  trunc
  -- ../src/hdl/sensors/sensor_hub.vhd:196:41
  n548_o <= '1' when buffer_index = "111" else '0';
  -- ../src/hdl/sensors/sensor_hub.vhd:199:58
  n550_o <= std_logic_vector (unsigned (buffer_index) + unsigned'("001"));
  -- ../src/hdl/sensors/sensor_hub.vhd:196:25
  n552_o <= n550_o when n548_o = '0' else "000";
  -- ../src/hdl/sensors/sensor_hub.vhd:166:21
  n554_o <= '1' when current_state = "101" else '0';
  n555_o <= n554_o & n338_o & n323_o & n312_o & n301_o & n290_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:134:17
  with n555_o select n557_o <=
    n494_o when "100000",
    n638_q when "010000",
    n638_q when "001000",
    n638_q when "000100",
    n638_q when "000010",
    n638_q when "000001",
    (11 downto 0 => 'X') when others;
  -- ../src/hdl/sensors/sensor_hub.vhd:134:17
  with n555_o select n559_o <=
    n546_o when "100000",
    n639_q when "010000",
    n639_q when "001000",
    n639_q when "000100",
    n639_q when "000010",
    n639_q when "000001",
    (11 downto 0 => 'X') when others;
  -- ../src/hdl/sensors/sensor_hub.vhd:134:17
  with n555_o select n561_o <=
    voc_buffer when "100000",
    voc_buffer when "010000",
    voc_buffer when "001000",
    voc_buffer when "000100",
    n297_o when "000010",
    voc_buffer when "000001",
    (95 downto 0 => 'X') when others;
  -- ../src/hdl/sensors/sensor_hub.vhd:134:17
  with n555_o select n563_o <=
    aq_buffer when "100000",
    aq_buffer when "010000",
    aq_buffer when "001000",
    n308_o when "000100",
    aq_buffer when "000010",
    aq_buffer when "000001",
    (95 downto 0 => 'X') when others;
  -- ../src/hdl/sensors/sensor_hub.vhd:134:17
  with n555_o select n565_o <=
    pressure_buffer when "100000",
    pressure_buffer when "010000",
    n319_o when "001000",
    pressure_buffer when "000100",
    pressure_buffer when "000010",
    pressure_buffer when "000001",
    (95 downto 0 => 'X') when others;
  -- ../src/hdl/sensors/sensor_hub.vhd:134:17
  with n555_o select n567_o <=
    temp_buffer when "100000",
    n330_o when "010000",
    temp_buffer when "001000",
    temp_buffer when "000100",
    temp_buffer when "000010",
    temp_buffer when "000001",
    (95 downto 0 => 'X') when others;
  -- ../src/hdl/sensors/sensor_hub.vhd:134:17
  with n555_o select n569_o <=
    n390_o when "100000",
    voc_data_internal when "010000",
    voc_data_internal when "001000",
    voc_data_internal when "000100",
    voc_data_internal when "000010",
    voc_data_internal when "000001",
    (11 downto 0 => 'X') when others;
  -- ../src/hdl/sensors/sensor_hub.vhd:134:17
  with n555_o select n571_o <=
    n442_o when "100000",
    aq_data_internal when "010000",
    aq_data_internal when "001000",
    aq_data_internal when "000100",
    aq_data_internal when "000010",
    aq_data_internal when "000001",
    (11 downto 0 => 'X') when others;
  -- ../src/hdl/sensors/sensor_hub.vhd:134:17
  with n555_o select n575_o <=
    "000" when "100000",
    n332_o when "010000",
    n321_o when "001000",
    n310_o when "000100",
    n299_o when "000010",
    "001" when "000001",
    "XXX" when others;
  -- ../src/hdl/sensors/sensor_hub.vhd:134:17
  with n555_o select n577_o <=
    n552_o when "100000",
    buffer_index when "010000",
    buffer_index when "001000",
    buffer_index when "000100",
    buffer_index when "000010",
    buffer_index when "000001",
    "XXX" when others;
  -- ../src/hdl/sensors/sensor_hub.vhd:112:13
  n592_o <= n557_o when rst = '0' else "000000000000";
  -- ../src/hdl/sensors/sensor_hub.vhd:112:13
  n594_o <= n559_o when rst = '0' else "000000000000";
  -- ../src/hdl/sensors/sensor_hub.vhd:112:13
  n597_o <= n561_o when rst = '0' else voc_buffer;
  -- ../src/hdl/sensors/sensor_hub.vhd:112:13
  n598_o <= n563_o when rst = '0' else aq_buffer;
  -- ../src/hdl/sensors/sensor_hub.vhd:112:13
  n599_o <= n565_o when rst = '0' else pressure_buffer;
  -- ../src/hdl/sensors/sensor_hub.vhd:112:13
  n600_o <= n567_o when rst = '0' else temp_buffer;
  -- ../src/hdl/sensors/sensor_hub.vhd:112:13
  n601_o <= n569_o when rst = '0' else voc_data_internal;
  -- ../src/hdl/sensors/sensor_hub.vhd:112:13
  n602_o <= n571_o when rst = '0' else aq_data_internal;
  -- ../src/hdl/sensors/sensor_hub.vhd:112:13
  n605_o <= n575_o when rst = '0' else "000";
  -- ../src/hdl/sensors/sensor_hub.vhd:112:13
  n609_o <= n577_o when rst = '0' else "000";
  -- ../src/hdl/sensors/sensor_hub.vhd:6:8
  n634_o <= n635_q when rst = '0' else "000000000000";
  -- ../src/hdl/sensors/sensor_hub.vhd:111:9
  process (clk)
  begin
    if rising_edge (clk) then
      n635_q <= n634_o;
    end if;
  end process;
  -- ../src/hdl/sensors/sensor_hub.vhd:6:8
  n636_o <= n637_q when rst = '0' else "000000000000";
  -- ../src/hdl/sensors/sensor_hub.vhd:111:9
  process (clk)
  begin
    if rising_edge (clk) then
      n637_q <= n636_o;
    end if;
  end process;
  -- ../src/hdl/sensors/sensor_hub.vhd:111:9
  process (clk)
  begin
    if rising_edge (clk) then
      n638_q <= n592_o;
    end if;
  end process;
  -- ../src/hdl/sensors/sensor_hub.vhd:111:9
  process (clk)
  begin
    if rising_edge (clk) then
      n639_q <= n594_o;
    end if;
  end process;
  -- ../src/hdl/sensors/sensor_hub.vhd:6:8
  n640_o <= n641_q when rst = '0' else "00000000";
  -- ../src/hdl/sensors/sensor_hub.vhd:111:9
  process (clk)
  begin
    if rising_edge (clk) then
      n641_q <= n640_o;
    end if;
  end process;
  -- ../src/hdl/sensors/sensor_hub.vhd:111:9
  process (clk)
  begin
    if rising_edge (clk) then
      n642_q <= n597_o;
    end if;
  end process;
  -- ../src/hdl/sensors/sensor_hub.vhd:111:9
  process (clk)
  begin
    if rising_edge (clk) then
      n643_q <= n598_o;
    end if;
  end process;
  -- ../src/hdl/sensors/sensor_hub.vhd:111:9
  process (clk)
  begin
    if rising_edge (clk) then
      n644_q <= n599_o;
    end if;
  end process;
  -- ../src/hdl/sensors/sensor_hub.vhd:111:9
  process (clk)
  begin
    if rising_edge (clk) then
      n645_q <= n600_o;
    end if;
  end process;
  -- ../src/hdl/sensors/sensor_hub.vhd:111:9
  process (clk)
  begin
    if rising_edge (clk) then
      n646_q <= n601_o;
    end if;
  end process;
  -- ../src/hdl/sensors/sensor_hub.vhd:111:9
  process (clk)
  begin
    if rising_edge (clk) then
      n647_q <= n602_o;
    end if;
  end process;
  -- ../src/hdl/sensors/sensor_hub.vhd:112:13
  n648_o <= not rst;
  -- ../src/hdl/sensors/sensor_hub.vhd:112:13
  n649_o <= n648_o and n288_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:112:13
  n650_o <= n276_o and n649_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:111:9
  process (clk)
  begin
    if rising_edge (clk) then
      n652_q <= n605_o;
    end if;
  end process;
  -- ../src/hdl/sensors/sensor_hub.vhd:111:9
  process (clk)
  begin
    if rising_edge (clk) then
      n655_q <= n609_o;
    end if;
  end process;
  -- ../src/hdl/sensors/sensor_hub.vhd:212:12
  n660_o <= '1' when rising_edge (clk) else '0';
  -- ../src/hdl/sensors/sensor_hub.vhd:94:22
  n667_o <= '1' when current_state = "001" else '0';
  -- ../src/hdl/sensors/sensor_hub.vhd:95:22
  n669_o <= '1' when current_state = "010" else '0';
  -- ../src/hdl/sensors/sensor_hub.vhd:94:35
  n670_o <= n667_o or n669_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:96:22
  n672_o <= '1' when current_state = "011" else '0';
  -- ../src/hdl/sensors/sensor_hub.vhd:95:34
  n673_o <= n670_o or n672_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:97:22
  n675_o <= '1' when current_state = "100" else '0';
  -- ../src/hdl/sensors/sensor_hub.vhd:96:40
  n676_o <= n673_o or n675_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:227:35
  n677_o <= not spi_active;
  -- ../src/hdl/sensors/sensor_hub.vhd:233:40
  n679_o <= '1' when unsigned (spi_counter) < unsigned'("10000") else '0';
  -- ../src/hdl/sensors/sensor_hub.vhd:234:56
  n681_o <= std_logic_vector (unsigned (spi_counter) + unsigned'("00001"));
  -- ../src/hdl/sensors/sensor_hub.vhd:237:43
  n682_o <= spi_counter (0);
  -- ../src/hdl/sensors/sensor_hub.vhd:237:47
  n683_o <= not n682_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:240:61
  n684_o <= spi_data_out (15);
  -- ../src/hdl/sensors/sensor_hub.vhd:241:61
  n685_o <= spi_data_out (14 downto 0);
  -- ../src/hdl/sensors/sensor_hub.vhd:241:75
  n687_o <= n685_o & '0';
  -- ../src/hdl/sensors/sensor_hub.vhd:245:59
  n688_o <= spi_data_in (14 downto 0);
  -- ../src/hdl/sensors/sensor_hub.vhd:245:73
  n689_o <= n688_o & adc_spi_miso;
  -- ../src/hdl/sensors/sensor_hub.vhd:237:29
  n692_o <= '1' when n683_o = '0' else '0';
  -- ../src/hdl/sensors/sensor_hub.vhd:231:21
  n693_o <= n772_q when n711_o = '0' else n684_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:231:21
  n694_o <= spi_data_out when n716_o = '0' else n687_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:237:29
  n695_o <= n689_o when n683_o = '0' else spi_data_in;
  -- ../src/hdl/sensors/sensor_hub.vhd:233:25
  n697_o <= '1' when n679_o = '0' else n692_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:233:25
  n698_o <= n679_o and n683_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:233:25
  n700_o <= '0' when n679_o = '0' else spi_active;
  -- ../src/hdl/sensors/sensor_hub.vhd:233:25
  n703_o <= '1' when n679_o = '0' else '0';
  -- ../src/hdl/sensors/sensor_hub.vhd:231:21
  n704_o <= spi_counter when n715_o = '0' else n681_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:233:25
  n705_o <= n679_o and n683_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:231:21
  n706_o <= spi_data_in when n717_o = '0' else n695_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:233:25
  n709_o <= '1' when n679_o = '0' else '0';
  -- ../src/hdl/sensors/sensor_hub.vhd:231:21
  n710_o <= n771_q when spi_active = '0' else n697_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:231:21
  n711_o <= spi_active and n698_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:231:21
  n712_o <= spi_active when spi_active = '0' else n700_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:231:21
  n714_o <= '0' when spi_active = '0' else n703_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:231:21
  n715_o <= spi_active and n679_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:231:21
  n716_o <= spi_active and n705_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:231:21
  n717_o <= spi_active and n679_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:231:21
  n719_o <= '0' when spi_active = '0' else n709_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:227:21
  n720_o <= n710_o when n677_o = '0' else n771_q;
  -- ../src/hdl/sensors/sensor_hub.vhd:227:21
  n721_o <= n693_o when n677_o = '0' else n772_q;
  -- ../src/hdl/sensors/sensor_hub.vhd:227:21
  n723_o <= n712_o when n677_o = '0' else '1';
  -- ../src/hdl/sensors/sensor_hub.vhd:227:21
  n725_o <= n714_o when n677_o = '0' else '0';
  -- ../src/hdl/sensors/sensor_hub.vhd:227:21
  n727_o <= n704_o when n677_o = '0' else "00000";
  -- ../src/hdl/sensors/sensor_hub.vhd:227:21
  n729_o <= n694_o when n677_o = '0' else "0000000000000000";
  -- ../src/hdl/sensors/sensor_hub.vhd:227:21
  n730_o <= n706_o when n677_o = '0' else spi_data_in;
  -- ../src/hdl/sensors/sensor_hub.vhd:227:21
  n732_o <= n719_o when n677_o = '0' else '0';
  -- ../src/hdl/sensors/sensor_hub.vhd:225:17
  n734_o <= '1' when n676_o = '0' else n720_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:225:17
  n736_o <= '0' when n676_o = '0' else n721_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:225:17
  n738_o <= '0' when n676_o = '0' else n723_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:225:17
  n740_o <= '0' when n676_o = '0' else n725_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:225:17
  n742_o <= spi_counter when n676_o = '0' else n727_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:225:17
  n743_o <= spi_data_out when n676_o = '0' else n729_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:225:17
  n744_o <= spi_data_in when n676_o = '0' else n730_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:225:17
  n746_o <= '0' when n676_o = '0' else n732_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:213:13
  n749_o <= n734_o when rst = '0' else '1';
  -- ../src/hdl/sensors/sensor_hub.vhd:213:13
  n751_o <= n736_o when rst = '0' else '0';
  -- ../src/hdl/sensors/sensor_hub.vhd:213:13
  n753_o <= n738_o when rst = '0' else '0';
  -- ../src/hdl/sensors/sensor_hub.vhd:213:13
  n755_o <= n740_o when rst = '0' else '0';
  -- ../src/hdl/sensors/sensor_hub.vhd:213:13
  n757_o <= n742_o when rst = '0' else "00000";
  -- ../src/hdl/sensors/sensor_hub.vhd:213:13
  n758_o <= n743_o when rst = '0' else spi_data_out;
  -- ../src/hdl/sensors/sensor_hub.vhd:213:13
  n759_o <= n744_o when rst = '0' else spi_data_in;
  -- ../src/hdl/sensors/sensor_hub.vhd:213:13
  n761_o <= n746_o when rst = '0' else '0';
  -- ../src/hdl/sensors/sensor_hub.vhd:212:9
  process (clk)
  begin
    if rising_edge (clk) then
      n771_q <= n749_o;
    end if;
  end process;
  -- ../src/hdl/sensors/sensor_hub.vhd:212:9
  process (clk)
  begin
    if rising_edge (clk) then
      n772_q <= n751_o;
    end if;
  end process;
  -- ../src/hdl/sensors/sensor_hub.vhd:212:9
  process (clk)
  begin
    if rising_edge (clk) then
      n773_q <= n753_o;
    end if;
  end process;
  -- ../src/hdl/sensors/sensor_hub.vhd:212:9
  process (clk)
  begin
    if rising_edge (clk) then
      n774_q <= n755_o;
    end if;
  end process;
  -- ../src/hdl/sensors/sensor_hub.vhd:212:9
  process (clk)
  begin
    if rising_edge (clk) then
      n775_q <= n757_o;
    end if;
  end process;
  -- ../src/hdl/sensors/sensor_hub.vhd:212:9
  process (clk)
  begin
    if rising_edge (clk) then
      n776_q <= n758_o;
    end if;
  end process;
  -- ../src/hdl/sensors/sensor_hub.vhd:212:9
  process (clk)
  begin
    if rising_edge (clk) then
      n777_q <= n759_o;
    end if;
  end process;
  -- ../src/hdl/sensors/sensor_hub.vhd:212:9
  process (clk)
  begin
    if rising_edge (clk) then
      n778_q <= n761_o;
    end if;
  end process;
  -- ../src/hdl/sensors/sensor_hub.vhd:268:12
  n780_o <= '1' when rising_edge (clk) else '0';
  -- ../src/hdl/sensors/sensor_hub.vhd:275:48
  n782_o <= '1' when unsigned (voc_data_internal) > unsigned'("100000000000") else '0';
  -- ../src/hdl/sensors/sensor_hub.vhd:275:17
  n787_o <= '0' when n782_o = '0' else '1';
  -- ../src/hdl/sensors/sensor_hub.vhd:275:17
  n788_o <= '0' when n782_o = '0' else '1';
  -- ../src/hdl/sensors/sensor_hub.vhd:283:47
  n790_o <= '1' when unsigned (aq_data_internal) > unsigned'("100000000000") else '0';
  -- ../src/hdl/sensors/sensor_hub.vhd:283:17
  n795_o <= '0' when n790_o = '0' else '1';
  -- ../src/hdl/sensors/sensor_hub.vhd:283:17
  n796_o <= '0' when n790_o = '0' else '1';
  -- ../src/hdl/sensors/sensor_hub.vhd:94:22
  n803_o <= '1' when current_state = "001" else '0';
  -- ../src/hdl/sensors/sensor_hub.vhd:95:22
  n805_o <= '1' when current_state = "010" else '0';
  -- ../src/hdl/sensors/sensor_hub.vhd:94:35
  n806_o <= n803_o or n805_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:96:22
  n808_o <= '1' when current_state = "011" else '0';
  -- ../src/hdl/sensors/sensor_hub.vhd:95:34
  n809_o <= n806_o or n808_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:97:22
  n811_o <= '1' when current_state = "100" else '0';
  -- ../src/hdl/sensors/sensor_hub.vhd:96:40
  n812_o <= n809_o or n811_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:293:33
  n813_o <= not spi_done;
  -- ../src/hdl/sensors/sensor_hub.vhd:294:58
  n815_o <= std_logic_vector (unsigned (sample_timeout) + unsigned'("0000000000000001"));
  -- ../src/hdl/sensors/sensor_hub.vhd:295:43
  n817_o <= '1' when sample_timeout = "1111111111111111" else '0';
  n819_o <= n852_q (7);
  -- ../src/hdl/sensors/sensor_hub.vhd:292:17
  n820_o <= n819_o when n826_o = '0' else '1';
  -- ../src/hdl/sensors/sensor_hub.vhd:293:21
  n822_o <= n813_o and n817_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:293:21
  n824_o <= "0000000000000000" when n813_o = '0' else n815_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:292:17
  n826_o <= n812_o and n822_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:292:17
  n828_o <= "0000000000000000" when n812_o = '0' else n824_o;
  n829_o <= n795_o & n787_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:269:13
  n831_o <= n829_o when rst = '0' else "00";
  n833_o <= n851_q (7 downto 2);
  -- ../src/hdl/sensors/sensor_hub.vhd:269:13
  n834_o <= n833_o when rst = '0' else "000000";
  n835_o <= n796_o & n788_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:269:13
  n837_o <= n835_o when rst = '0' else "00";
  n839_o <= n852_q (6 downto 2);
  -- ../src/hdl/sensors/sensor_hub.vhd:269:13
  n840_o <= n839_o when rst = '0' else "00000";
  -- ../src/hdl/sensors/sensor_hub.vhd:269:13
  n842_o <= n820_o when rst = '0' else '0';
  -- ../src/hdl/sensors/sensor_hub.vhd:269:13
  n844_o <= n828_o when rst = '0' else "0000000000000000";
  n845_o <= n834_o & n831_o;
  n847_o <= n842_o & n840_o & n837_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:268:9
  process (clk)
  begin
    if rising_edge (clk) then
      n851_q <= n845_o;
    end if;
  end process;
  -- ../src/hdl/sensors/sensor_hub.vhd:268:9
  process (clk)
  begin
    if rising_edge (clk) then
      n852_q <= n847_o;
    end if;
  end process;
  -- ../src/hdl/sensors/sensor_hub.vhd:268:9
  process (clk)
  begin
    if rising_edge (clk) then
      n853_q <= n844_o;
    end if;
  end process;
  -- ../src/hdl/sensors/sensor_hub.vhd:316:17
  n856_o <= '1' when current_state = "001" else '0';
  -- ../src/hdl/sensors/sensor_hub.vhd:318:17
  n858_o <= '1' when current_state = "010" else '0';
  -- ../src/hdl/sensors/sensor_hub.vhd:320:17
  n860_o <= '1' when current_state = "011" else '0';
  -- ../src/hdl/sensors/sensor_hub.vhd:322:17
  n862_o <= '1' when current_state = "100" else '0';
  n863_o <= n862_o & n860_o & n858_o & n856_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:315:13
  with n863_o select n869_o <=
    "11110111" when "1000",
    "11111011" when "0100",
    "11111101" when "0010",
    "11111110" when "0001",
    "11111111" when others;
  -- ../src/hdl/sensors/sensor_hub.vhd:312:9
  n871_o <= n869_o when rst = '0' else "11111111";
  -- ../src/hdl/sensors/sensor_hub.vhd:142:29
  n873_o <= n293_o (2);
  -- ../src/hdl/sensors/sensor_hub.vhd:142:29
  n874_o <= not n873_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:142:29
  n875_o <= n293_o (1);
  -- ../src/hdl/sensors/sensor_hub.vhd:142:29
  n876_o <= not n875_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:142:29
  n877_o <= n874_o and n876_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:142:29
  n878_o <= n874_o and n875_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:142:29
  n879_o <= n873_o and n876_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:142:29
  n880_o <= n873_o and n875_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:142:29
  n881_o <= n293_o (0);
  -- ../src/hdl/sensors/sensor_hub.vhd:142:29
  n882_o <= not n881_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:142:29
  n883_o <= n877_o and n882_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:142:29
  n884_o <= n877_o and n881_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:142:29
  n885_o <= n878_o and n882_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:142:29
  n886_o <= n878_o and n881_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:142:29
  n887_o <= n879_o and n882_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:142:29
  n888_o <= n879_o and n881_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:142:29
  n889_o <= n880_o and n882_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:142:29
  n890_o <= n880_o and n881_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:92:14
  n891_o <= voc_buffer (11 downto 0);
  -- ../src/hdl/sensors/sensor_hub.vhd:142:29
  n892_o <= n891_o when n883_o = '0' else n295_o;
  n893_o <= voc_buffer (23 downto 12);
  -- ../src/hdl/sensors/sensor_hub.vhd:142:29
  n894_o <= n893_o when n884_o = '0' else n295_o;
  n895_o <= voc_buffer (35 downto 24);
  -- ../src/hdl/sensors/sensor_hub.vhd:142:29
  n896_o <= n895_o when n885_o = '0' else n295_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:92:14
  n897_o <= voc_buffer (47 downto 36);
  -- ../src/hdl/sensors/sensor_hub.vhd:142:29
  n898_o <= n897_o when n886_o = '0' else n295_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:92:14
  n899_o <= voc_buffer (59 downto 48);
  -- ../src/hdl/sensors/sensor_hub.vhd:142:29
  n900_o <= n899_o when n887_o = '0' else n295_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:111:9
  n901_o <= voc_buffer (71 downto 60);
  -- ../src/hdl/sensors/sensor_hub.vhd:142:29
  n902_o <= n901_o when n888_o = '0' else n295_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:111:9
  n903_o <= voc_buffer (83 downto 72);
  -- ../src/hdl/sensors/sensor_hub.vhd:142:29
  n904_o <= n903_o when n889_o = '0' else n295_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:6:8
  n905_o <= voc_buffer (95 downto 84);
  -- ../src/hdl/sensors/sensor_hub.vhd:142:29
  n906_o <= n905_o when n890_o = '0' else n295_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:111:9
  n907_o <= n906_o & n904_o & n902_o & n900_o & n898_o & n896_o & n894_o & n892_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:148:29
  n908_o <= n304_o (2);
  -- ../src/hdl/sensors/sensor_hub.vhd:148:29
  n909_o <= not n908_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:148:29
  n910_o <= n304_o (1);
  -- ../src/hdl/sensors/sensor_hub.vhd:148:29
  n911_o <= not n910_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:148:29
  n912_o <= n909_o and n911_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:148:29
  n913_o <= n909_o and n910_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:148:29
  n914_o <= n908_o and n911_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:148:29
  n915_o <= n908_o and n910_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:148:29
  n916_o <= n304_o (0);
  -- ../src/hdl/sensors/sensor_hub.vhd:148:29
  n917_o <= not n916_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:148:29
  n918_o <= n912_o and n917_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:148:29
  n919_o <= n912_o and n916_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:148:29
  n920_o <= n913_o and n917_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:148:29
  n921_o <= n913_o and n916_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:148:29
  n922_o <= n914_o and n917_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:148:29
  n923_o <= n914_o and n916_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:148:29
  n924_o <= n915_o and n917_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:148:29
  n925_o <= n915_o and n916_o;
  n926_o <= aq_buffer (11 downto 0);
  -- ../src/hdl/sensors/sensor_hub.vhd:148:29
  n927_o <= n926_o when n918_o = '0' else n306_o;
  n928_o <= aq_buffer (23 downto 12);
  -- ../src/hdl/sensors/sensor_hub.vhd:148:29
  n929_o <= n928_o when n919_o = '0' else n306_o;
  n930_o <= aq_buffer (35 downto 24);
  -- ../src/hdl/sensors/sensor_hub.vhd:148:29
  n931_o <= n930_o when n920_o = '0' else n306_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:159:25
  n932_o <= aq_buffer (47 downto 36);
  -- ../src/hdl/sensors/sensor_hub.vhd:148:29
  n933_o <= n932_o when n921_o = '0' else n306_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:159:25
  n934_o <= aq_buffer (59 downto 48);
  -- ../src/hdl/sensors/sensor_hub.vhd:148:29
  n935_o <= n934_o when n922_o = '0' else n306_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:160:41
  n936_o <= aq_buffer (71 downto 60);
  -- ../src/hdl/sensors/sensor_hub.vhd:148:29
  n937_o <= n936_o when n923_o = '0' else n306_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:148:39
  n938_o <= aq_buffer (83 downto 72);
  -- ../src/hdl/sensors/sensor_hub.vhd:148:29
  n939_o <= n938_o when n924_o = '0' else n306_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:129:37
  n940_o <= aq_buffer (95 downto 84);
  -- ../src/hdl/sensors/sensor_hub.vhd:148:29
  n941_o <= n940_o when n925_o = '0' else n306_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:109:18
  n942_o <= n941_o & n939_o & n937_o & n935_o & n933_o & n931_o & n929_o & n927_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:154:29
  n943_o <= n315_o (2);
  -- ../src/hdl/sensors/sensor_hub.vhd:154:29
  n944_o <= not n943_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:154:29
  n945_o <= n315_o (1);
  -- ../src/hdl/sensors/sensor_hub.vhd:154:29
  n946_o <= not n945_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:154:29
  n947_o <= n944_o and n946_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:154:29
  n948_o <= n944_o and n945_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:154:29
  n949_o <= n943_o and n946_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:154:29
  n950_o <= n943_o and n945_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:154:29
  n951_o <= n315_o (0);
  -- ../src/hdl/sensors/sensor_hub.vhd:154:29
  n952_o <= not n951_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:154:29
  n953_o <= n947_o and n952_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:154:29
  n954_o <= n947_o and n951_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:154:29
  n955_o <= n948_o and n952_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:154:29
  n956_o <= n948_o and n951_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:154:29
  n957_o <= n949_o and n952_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:154:29
  n958_o <= n949_o and n951_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:154:29
  n959_o <= n950_o and n952_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:154:29
  n960_o <= n950_o and n951_o;
  n961_o <= pressure_buffer (11 downto 0);
  -- ../src/hdl/sensors/sensor_hub.vhd:154:29
  n962_o <= n961_o when n953_o = '0' else n317_o;
  n963_o <= pressure_buffer (23 downto 12);
  -- ../src/hdl/sensors/sensor_hub.vhd:154:29
  n964_o <= n963_o when n954_o = '0' else n317_o;
  n965_o <= pressure_buffer (35 downto 24);
  -- ../src/hdl/sensors/sensor_hub.vhd:154:29
  n966_o <= n965_o when n955_o = '0' else n317_o;
  n967_o <= pressure_buffer (47 downto 36);
  -- ../src/hdl/sensors/sensor_hub.vhd:154:29
  n968_o <= n967_o when n956_o = '0' else n317_o;
  n969_o <= pressure_buffer (59 downto 48);
  -- ../src/hdl/sensors/sensor_hub.vhd:154:29
  n970_o <= n969_o when n957_o = '0' else n317_o;
  n971_o <= pressure_buffer (71 downto 60);
  -- ../src/hdl/sensors/sensor_hub.vhd:154:29
  n972_o <= n971_o when n958_o = '0' else n317_o;
  n973_o <= pressure_buffer (83 downto 72);
  -- ../src/hdl/sensors/sensor_hub.vhd:154:29
  n974_o <= n973_o when n959_o = '0' else n317_o;
  n975_o <= pressure_buffer (95 downto 84);
  -- ../src/hdl/sensors/sensor_hub.vhd:154:29
  n976_o <= n975_o when n960_o = '0' else n317_o;
  n977_o <= n976_o & n974_o & n972_o & n970_o & n968_o & n966_o & n964_o & n962_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:160:29
  n978_o <= n326_o (2);
  -- ../src/hdl/sensors/sensor_hub.vhd:160:29
  n979_o <= not n978_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:160:29
  n980_o <= n326_o (1);
  -- ../src/hdl/sensors/sensor_hub.vhd:160:29
  n981_o <= not n980_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:160:29
  n982_o <= n979_o and n981_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:160:29
  n983_o <= n979_o and n980_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:160:29
  n984_o <= n978_o and n981_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:160:29
  n985_o <= n978_o and n980_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:160:29
  n986_o <= n326_o (0);
  -- ../src/hdl/sensors/sensor_hub.vhd:160:29
  n987_o <= not n986_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:160:29
  n988_o <= n982_o and n987_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:160:29
  n989_o <= n982_o and n986_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:160:29
  n990_o <= n983_o and n987_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:160:29
  n991_o <= n983_o and n986_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:160:29
  n992_o <= n984_o and n987_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:160:29
  n993_o <= n984_o and n986_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:160:29
  n994_o <= n985_o and n987_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:160:29
  n995_o <= n985_o and n986_o;
  n996_o <= temp_buffer (11 downto 0);
  -- ../src/hdl/sensors/sensor_hub.vhd:160:29
  n997_o <= n996_o when n988_o = '0' else n328_o;
  n998_o <= temp_buffer (23 downto 12);
  -- ../src/hdl/sensors/sensor_hub.vhd:160:29
  n999_o <= n998_o when n989_o = '0' else n328_o;
  n1000_o <= temp_buffer (35 downto 24);
  -- ../src/hdl/sensors/sensor_hub.vhd:160:29
  n1001_o <= n1000_o when n990_o = '0' else n328_o;
  n1002_o <= temp_buffer (47 downto 36);
  -- ../src/hdl/sensors/sensor_hub.vhd:160:29
  n1003_o <= n1002_o when n991_o = '0' else n328_o;
  n1004_o <= temp_buffer (59 downto 48);
  -- ../src/hdl/sensors/sensor_hub.vhd:160:29
  n1005_o <= n1004_o when n992_o = '0' else n328_o;
  n1006_o <= temp_buffer (71 downto 60);
  -- ../src/hdl/sensors/sensor_hub.vhd:160:29
  n1007_o <= n1006_o when n993_o = '0' else n328_o;
  n1008_o <= temp_buffer (83 downto 72);
  -- ../src/hdl/sensors/sensor_hub.vhd:160:29
  n1009_o <= n1008_o when n994_o = '0' else n328_o;
  n1010_o <= temp_buffer (95 downto 84);
  -- ../src/hdl/sensors/sensor_hub.vhd:160:29
  n1011_o <= n1010_o when n995_o = '0' else n328_o;
  n1012_o <= n1011_o & n1009_o & n1007_o & n1005_o & n1003_o & n1001_o & n999_o & n997_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:129:25
  n1013_o <= n283_o (2);
  -- ../src/hdl/sensors/sensor_hub.vhd:129:25
  n1014_o <= not n1013_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:129:25
  n1015_o <= n283_o (1);
  -- ../src/hdl/sensors/sensor_hub.vhd:129:25
  n1016_o <= not n1015_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:129:25
  n1017_o <= n1014_o and n1016_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:129:25
  n1018_o <= n1014_o and n1015_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:129:25
  n1019_o <= n1013_o and n1016_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:129:25
  n1020_o <= n1013_o and n1015_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:129:25
  n1021_o <= n283_o (0);
  -- ../src/hdl/sensors/sensor_hub.vhd:129:25
  n1022_o <= not n1021_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:129:25
  n1023_o <= n1017_o and n1022_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:129:25
  n1024_o <= n1017_o and n1021_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:129:25
  n1025_o <= n1018_o and n1022_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:129:25
  n1026_o <= n1018_o and n1021_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:129:25
  n1027_o <= n1019_o and n1022_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:129:25
  n1028_o <= n1019_o and n1021_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:129:25
  n1029_o <= n1020_o and n1022_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:129:25
  n1030_o <= n1020_o and n1021_o;
  n1031_o <= cal_storage (7 downto 0);
  -- ../src/hdl/sensors/sensor_hub.vhd:129:25
  n1032_o <= n1023_o and n650_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:129:25
  n1033_o <= n1031_o when n1032_o = '0' else n285_o;
  n1034_o <= cal_storage (15 downto 8);
  -- ../src/hdl/sensors/sensor_hub.vhd:129:25
  n1035_o <= n1024_o and n650_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:129:25
  n1036_o <= n1034_o when n1035_o = '0' else n285_o;
  n1037_o <= cal_storage (23 downto 16);
  -- ../src/hdl/sensors/sensor_hub.vhd:129:25
  n1038_o <= n1025_o and n650_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:129:25
  n1039_o <= n1037_o when n1038_o = '0' else n285_o;
  n1040_o <= cal_storage (31 downto 24);
  -- ../src/hdl/sensors/sensor_hub.vhd:129:25
  n1041_o <= n1026_o and n650_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:129:25
  n1042_o <= n1040_o when n1041_o = '0' else n285_o;
  n1043_o <= cal_storage (39 downto 32);
  -- ../src/hdl/sensors/sensor_hub.vhd:129:25
  n1044_o <= n1027_o and n650_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:129:25
  n1045_o <= n1043_o when n1044_o = '0' else n285_o;
  n1046_o <= cal_storage (47 downto 40);
  -- ../src/hdl/sensors/sensor_hub.vhd:129:25
  n1047_o <= n1028_o and n650_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:129:25
  n1048_o <= n1046_o when n1047_o = '0' else n285_o;
  n1049_o <= cal_storage (55 downto 48);
  -- ../src/hdl/sensors/sensor_hub.vhd:129:25
  n1050_o <= n1029_o and n650_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:129:25
  n1051_o <= n1049_o when n1050_o = '0' else n285_o;
  n1052_o <= cal_storage (63 downto 56);
  -- ../src/hdl/sensors/sensor_hub.vhd:129:25
  n1053_o <= n1030_o and n650_o;
  -- ../src/hdl/sensors/sensor_hub.vhd:129:25
  n1054_o <= n1052_o when n1053_o = '0' else n285_o;
  n1055_o <= n1054_o & n1051_o & n1048_o & n1045_o & n1042_o & n1039_o & n1036_o & n1033_o;
end rtl;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clock_manager is
  port (
    clk_in : in std_logic;
    rst : in std_logic;
    clk_sys : out std_logic;
    clk_sample : out std_logic;
    clk_control : out std_logic;
    locked : out std_logic);
end entity clock_manager;

architecture rtl of clock_manager is
  signal clk_sample_int : std_logic;
  signal clk_control_int : std_logic;
  signal n200_counter_sample : std_logic_vector (6 downto 0);
  signal n200_counter_control : std_logic_vector (13 downto 0);
  signal n204_o : std_logic;
  signal n206_o : std_logic;
  signal n207_o : std_logic;
  signal n209_o : std_logic_vector (6 downto 0);
  signal n212_o : std_logic_vector (6 downto 0);
  signal n214_o : std_logic;
  signal n215_o : std_logic;
  signal n217_o : std_logic_vector (13 downto 0);
  signal n220_o : std_logic_vector (13 downto 0);
  signal n238_q : std_logic;
  signal n239_o : std_logic;
  signal n240_q : std_logic;
  signal n241_o : std_logic;
  signal n242_q : std_logic;
  signal n243_q : std_logic_vector (6 downto 0) := "0000000";
  signal n244_q : std_logic_vector (13 downto 0) := "00000000000000";
begin
  clk_sys <= clk_in;
  clk_sample <= clk_sample_int;
  clk_control <= clk_control_int;
  locked <= n238_q;
  -- ../src/hdl/core/clock_manager.vhd:20:12
  clk_sample_int <= n240_q; -- (signal)
  -- ../src/hdl/core/clock_manager.vhd:21:12
  clk_control_int <= n242_q; -- (signal)
  -- ../src/hdl/core/clock_manager.vhd:25:18
  n200_counter_sample <= n243_q; -- (isignal)
  -- ../src/hdl/core/clock_manager.vhd:26:18
  n200_counter_control <= n244_q; -- (isignal)
  -- ../src/hdl/core/clock_manager.vhd:34:15
  n204_o <= '1' when rising_edge (clk_in) else '0';
  -- ../src/hdl/core/clock_manager.vhd:36:31
  n206_o <= '1' when n200_counter_sample = "1100011" else '0';
  -- ../src/hdl/core/clock_manager.vhd:38:35
  n207_o <= not clk_sample_int;
  -- ../src/hdl/core/clock_manager.vhd:40:50
  n209_o <= std_logic_vector (unsigned (n200_counter_sample) + unsigned'("0000001"));
  -- ../src/hdl/core/clock_manager.vhd:36:13
  n212_o <= n209_o when n206_o = '0' else "0000000";
  -- ../src/hdl/core/clock_manager.vhd:44:32
  n214_o <= '1' when n200_counter_control = "10011100001111" else '0';
  -- ../src/hdl/core/clock_manager.vhd:46:36
  n215_o <= not clk_control_int;
  -- ../src/hdl/core/clock_manager.vhd:48:52
  n217_o <= std_logic_vector (unsigned (n200_counter_control) + unsigned'("00000000000001"));
  -- ../src/hdl/core/clock_manager.vhd:44:13
  n220_o <= n217_o when n214_o = '0' else "00000000000000";
  -- ../src/hdl/core/clock_manager.vhd:34:9
  process (clk_in, rst)
  begin
    if rst = '1' then
      n238_q <= '0';
    elsif rising_edge (clk_in) then
      n238_q <= '1';
    end if;
  end process;
  -- ../src/hdl/core/clock_manager.vhd:36:31
  n239_o <= clk_sample_int when n206_o = '0' else n207_o;
  -- ../src/hdl/core/clock_manager.vhd:34:9
  process (clk_in, rst)
  begin
    if rst = '1' then
      n240_q <= '0';
    elsif rising_edge (clk_in) then
      n240_q <= n239_o;
    end if;
  end process;
  -- ../src/hdl/core/clock_manager.vhd:44:32
  n241_o <= clk_control_int when n214_o = '0' else n215_o;
  -- ../src/hdl/core/clock_manager.vhd:34:9
  process (clk_in, rst)
  begin
    if rst = '1' then
      n242_q <= '0';
    elsif rising_edge (clk_in) then
      n242_q <= n241_o;
    end if;
  end process;
  -- ../src/hdl/core/clock_manager.vhd:34:9
  process (clk_in, rst)
  begin
    if rst = '1' then
      n243_q <= "0000000";
    elsif rising_edge (clk_in) then
      n243_q <= n212_o;
    end if;
  end process;
  -- ../src/hdl/core/clock_manager.vhd:34:9
  process (clk_in, rst)
  begin
    if rst = '1' then
      n244_q <= "00000000000000";
    elsif rising_edge (clk_in) then
      n244_q <= n220_o;
    end if;
  end process;
end rtl;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

architecture rtl of nebkiso_top is
  signal wrap_clk_in: std_logic;
  signal wrap_ext_rst_n: std_logic;
  signal wrap_watchdog_error: std_logic;
  signal wrap_adc_spi_miso: std_logic;
  subtype typwrap_flow_pulse is std_logic_vector (7 downto 0);
  signal wrap_flow_pulse: typwrap_flow_pulse;
  subtype typwrap_operational_mode is std_logic_vector (1 downto 0);
  signal wrap_operational_mode: typwrap_operational_mode;
  signal wrap_self_test_req: std_logic;
  signal wrap_error_reset: std_logic;
  signal wrap_cal_mode: std_logic;
  subtype typwrap_cal_data is std_logic_vector (15 downto 0);
  signal wrap_cal_data: typwrap_cal_data;
  subtype typwrap_cal_addr is std_logic_vector (7 downto 0);
  signal wrap_cal_addr: typwrap_cal_addr;
  signal wrap_cal_wr: std_logic;
  subtype typwrap_voc_threshold is std_logic_vector (11 downto 0);
  signal wrap_voc_threshold: typwrap_voc_threshold;
  subtype typwrap_aq_threshold is std_logic_vector (11 downto 0);
  signal wrap_aq_threshold: typwrap_aq_threshold;
  subtype typwrap_press_threshold is std_logic_vector (11 downto 0);
  signal wrap_press_threshold: typwrap_press_threshold;
  subtype typwrap_temp_threshold is std_logic_vector (11 downto 0);
  signal wrap_temp_threshold: typwrap_temp_threshold;
  subtype typwrap_flow_threshold is std_logic_vector (7 downto 0);
  signal wrap_flow_threshold: typwrap_flow_threshold;
  signal wrap_uart_rx: std_logic;
  signal wrap_watchdog_kick: std_logic;
  signal wrap_adc_spi_sclk: std_logic;
  signal wrap_adc_spi_mosi: std_logic;
  subtype typwrap_adc_spi_cs_n is std_logic_vector (7 downto 0);
  signal wrap_adc_spi_cs_n: typwrap_adc_spi_cs_n;
  signal wrap_emergency_stop_a: std_logic;
  signal wrap_emergency_stop_b: std_logic;
  signal wrap_ventilation_on_a: std_logic;
  signal wrap_ventilation_on_b: std_logic;
  subtype typwrap_chamber_shut_a is std_logic_vector (149 downto 0);
  signal wrap_chamber_shut_a: typwrap_chamber_shut_a;
  subtype typwrap_chamber_shut_b is std_logic_vector (149 downto 0);
  signal wrap_chamber_shut_b: typwrap_chamber_shut_b;
  signal wrap_uart_tx: std_logic;
  subtype typwrap_system_status is std_logic_vector (7 downto 0);
  signal wrap_system_status: typwrap_system_status;
  subtype typwrap_error_code is std_logic_vector (7 downto 0);
  signal wrap_error_code: typwrap_error_code;
  signal wrap_heartbeat: std_logic;
  signal n4_o : std_logic_vector (3 downto 0);
  signal n4_oport : std_logic_vector (3 downto 0);
  signal n5_o : std_logic_vector (3 downto 0);
  signal n5_oport : std_logic_vector (3 downto 0);
  signal clk_sys : std_logic;
  signal pll_locked : std_logic;
  signal rst_n_sync : std_logic;
  signal system_rst : std_logic;
  signal safety_rst : std_logic;
  signal watchdog_counter : std_logic_vector (23 downto 0);
  signal watchdog_timeout : std_logic;
  signal voc_data : std_logic_vector (11 downto 0);
  signal aq_data : std_logic_vector (11 downto 0);
  signal press_data : std_logic_vector (11 downto 0);
  signal temp_data : std_logic_vector (11 downto 0);
  signal flow_data : std_logic_vector (7 downto 0);
  signal emergency_stop_int_a : std_logic;
  signal emergency_stop_int_b : std_logic;
  signal ventilation_on_int_a : std_logic;
  signal ventilation_on_int_b : std_logic;
  signal error_status : std_logic_vector (15 downto 0);
  signal error_counter : std_logic_vector (7 downto 0);
  signal current_state : std_logic_vector (2 downto 0);
  signal sensor_status : std_logic_vector (7 downto 0);
  signal heartbeat_counter : std_logic_vector (24 downto 0);
  signal heartbeat_int : std_logic;
  signal system_status_int : std_logic_vector (7 downto 0);
  signal uart_tx_int : std_logic;
  signal clock_manager_inst_clk_sys : std_logic;
  signal clock_manager_inst_clk_sample : std_logic;
  signal clock_manager_inst_clk_control : std_logic;
  signal clock_manager_inst_locked : std_logic;
  signal reset_sync_proc_sync_ff : std_logic_vector (2 downto 0);
  signal n22_o : std_logic;
  signal n23_o : std_logic_vector (1 downto 0);
  signal n24_o : std_logic_vector (2 downto 0);
  signal n25_o : std_logic;
  signal n26_o : std_logic;
  signal n27_o : std_logic;
  signal n28_o : std_logic;
  signal n29_o : std_logic;
  signal n30_o : std_logic;
  signal n32_o : std_logic;
  signal n34_o : std_logic_vector (7 downto 0);
  signal n35_o : std_logic_vector (7 downto 0);
  signal n38_o : std_logic;
  signal n40_o : std_logic_vector (7 downto 0);
  signal n42_o : std_logic;
  signal n43_o : std_logic;
  signal n46_o : std_logic;
  signal n53_q : std_logic;
  signal n54_q : std_logic;
  signal n55_q : std_logic;
  signal n56_q : std_logic_vector (7 downto 0);
  signal n57_q : std_logic_vector (2 downto 0) := "XXX";
  signal sensor_hub_inst_scl : std_logic_vector (3 downto 0);
  signal sensor_hub_inst_sda : std_logic_vector (3 downto 0);
  signal sensor_hub_inst_adc_spi_sclk : std_logic;
  signal sensor_hub_inst_adc_spi_mosi : std_logic;
  signal sensor_hub_inst_adc_spi_cs_n : std_logic_vector (7 downto 0);
  signal sensor_hub_inst_voc_data : std_logic_vector (11 downto 0);
  signal sensor_hub_inst_aq_data : std_logic_vector (11 downto 0);
  signal sensor_hub_inst_pressure_data : std_logic_vector (11 downto 0);
  signal sensor_hub_inst_temp_data : std_logic_vector (11 downto 0);
  signal sensor_hub_inst_flow_data : std_logic_vector (7 downto 0);
  signal sensor_hub_inst_sensor_status : std_logic_vector (7 downto 0);
  signal sensor_hub_inst_error_flags : std_logic_vector (7 downto 0);
  signal safety_monitor_a_emergency_stop : std_logic;
  signal safety_monitor_a_ventilation_on : std_logic;
  signal safety_monitor_a_chamber_shutdown : std_logic_vector (149 downto 0);
  signal safety_monitor_a_safety_status : std_logic_vector (7 downto 0);
  signal safety_monitor_a_error_code : std_logic_vector (7 downto 0);
  signal safety_monitor_a_error_location : std_logic_vector (7 downto 0);
  signal safety_monitor_b_emergency_stop : std_logic;
  signal safety_monitor_b_ventilation_on : std_logic;
  signal safety_monitor_b_chamber_shutdown : std_logic_vector (149 downto 0);
  signal safety_monitor_b_safety_status : std_logic_vector (7 downto 0);
  signal safety_monitor_b_error_code : std_logic_vector (7 downto 0);
  signal safety_monitor_b_error_location : std_logic_vector (7 downto 0);
  signal uart_ctrl_tx : std_logic;
  signal uart_ctrl_tx_busy : std_logic;
  signal uart_ctrl_rx_data : std_logic_vector (7 downto 0);
  signal uart_ctrl_rx_done : std_logic;
  constant n78_o : std_logic_vector (7 downto 0) := "00000000";
  constant n79_o : std_logic := '0';
  signal n81_o : std_logic;
  signal n83_o : std_logic_vector (23 downto 0);
  signal n85_o : std_logic;
  signal n87_o : std_logic;
  signal n89_o : std_logic;
  signal n91_o : std_logic;
  signal n92_o : std_logic;
  signal n94_o : std_logic_vector (23 downto 0);
  signal n96_o : std_logic;
  signal n98_o : std_logic_vector (23 downto 0);
  signal n100_o : std_logic;
  signal n104_q : std_logic_vector (23 downto 0);
  signal n105_q : std_logic;
  signal n107_o : std_logic;
  signal n109_o : std_logic_vector (24 downto 0);
  signal n110_o : std_logic_vector (27 downto 0);
  signal n112_o : std_logic;
  signal n113_o : std_logic;
  signal n115_o : std_logic_vector (24 downto 0);
  signal n116_o : std_logic;
  signal n118_o : std_logic_vector (24 downto 0);
  signal n120_o : std_logic;
  signal n124_q : std_logic_vector (24 downto 0);
  signal n125_q : std_logic;
  signal n127_o : std_logic;
  signal n129_o : std_logic;
  signal n130_o : std_logic;
  signal n132_o : std_logic_vector (2 downto 0);
  signal n134_o : std_logic;
  signal n136_o : std_logic;
  signal n138_o : std_logic;
  signal n139_o : std_logic;
  signal n141_o : std_logic_vector (2 downto 0);
  signal n143_o : std_logic_vector (2 downto 0);
  signal n145_o : std_logic;
  signal n146_o : std_logic;
  signal n148_o : std_logic_vector (2 downto 0);
  signal n150_o : std_logic;
  signal n152_o : std_logic;
  signal n153_o : std_logic;
  signal n155_o : std_logic_vector (2 downto 0);
  signal n157_o : std_logic_vector (2 downto 0);
  signal n159_o : std_logic;
  signal n161_o : std_logic;
  signal n162_o : std_logic;
  signal n164_o : std_logic_vector (2 downto 0);
  signal n166_o : std_logic;
  signal n168_o : std_logic;
  signal n169_o : std_logic;
  signal n171_o : std_logic_vector (2 downto 0);
  signal n173_o : std_logic;
  signal n174_o : std_logic_vector (5 downto 0);
  signal n176_o : std_logic_vector (2 downto 0);
  signal n178_o : std_logic_vector (2 downto 0);
  signal n181_q : std_logic_vector (2 downto 0);
  signal n182_o : std_logic;
  signal n183_o : std_logic;
  signal n184_o : std_logic;
  signal n185_o : std_logic;
  signal n188_o : std_logic_vector (2 downto 0);
  signal n189_o : std_logic_vector (5 downto 0);
  signal n190_o : std_logic_vector (6 downto 0);
  signal n191_o : std_logic_vector (7 downto 0);
  signal n192_o : std_logic_vector (7 downto 0);
  signal n193_o : std_logic;
  signal n194_o : std_logic_vector (15 downto 0);
begin
  wrap_clk_in <= clk_in;
  wrap_ext_rst_n <= ext_rst_n;
  wrap_watchdog_error <= watchdog_error;
  wrap_adc_spi_miso <= adc_spi_miso;
  wrap_flow_pulse <= flow_pulse;
  wrap_operational_mode <= operational_mode;
  wrap_self_test_req <= self_test_req;
  wrap_error_reset <= error_reset;
  wrap_cal_mode <= cal_mode;
  wrap_cal_data <= cal_data;
  wrap_cal_addr <= cal_addr;
  wrap_cal_wr <= cal_wr;
  wrap_voc_threshold <= voc_threshold;
  wrap_aq_threshold <= aq_threshold;
  wrap_press_threshold <= press_threshold;
  wrap_temp_threshold <= temp_threshold;
  wrap_flow_threshold <= flow_threshold;
  wrap_uart_rx <= uart_rx;
  watchdog_kick <= wrap_watchdog_kick;
  adc_spi_sclk <= wrap_adc_spi_sclk;
  adc_spi_mosi <= wrap_adc_spi_mosi;
  adc_spi_cs_n <= wrap_adc_spi_cs_n;
  emergency_stop_a <= wrap_emergency_stop_a;
  emergency_stop_b <= wrap_emergency_stop_b;
  ventilation_on_a <= wrap_ventilation_on_a;
  ventilation_on_b <= wrap_ventilation_on_b;
  chamber_shut_a <= wrap_chamber_shut_a;
  chamber_shut_b <= wrap_chamber_shut_b;
  uart_tx <= wrap_uart_tx;
  system_status <= wrap_system_status;
  error_code <= wrap_error_code;
  heartbeat <= wrap_heartbeat;
  wrap_watchdog_kick <= n193_o;
  wrap_adc_spi_sclk <= sensor_hub_inst_adc_spi_sclk;
  wrap_adc_spi_mosi <= sensor_hub_inst_adc_spi_mosi;
  wrap_adc_spi_cs_n <= sensor_hub_inst_adc_spi_cs_n;
  scl <= n4_oport;
  sda <= n5_oport;
  wrap_emergency_stop_a <= n182_o;
  wrap_emergency_stop_b <= n183_o;
  wrap_ventilation_on_a <= n184_o;
  wrap_ventilation_on_b <= n185_o;
  wrap_chamber_shut_a <= safety_monitor_a_chamber_shutdown;
  wrap_chamber_shut_b <= safety_monitor_b_chamber_shutdown;
  wrap_uart_tx <= uart_tx_int;
  wrap_system_status <= system_status_int;
  wrap_error_code <= n192_o;
  wrap_heartbeat <= heartbeat_int;
  -- ../src/hdl/core/nebkiso_top.vhd:25:9
  n4_oport <= sensor_hub_inst_scl; -- (inout - port)
  n4_o <= scl; -- (inout - read)
  -- ../src/hdl/core/nebkiso_top.vhd:26:9
  n5_oport <= sensor_hub_inst_sda; -- (inout - port)
  n5_o <= sda; -- (inout - read)
  -- ../src/hdl/core/nebkiso_top.vhd:70:12
  clk_sys <= clock_manager_inst_clk_sys; -- (signal)
  -- ../src/hdl/core/nebkiso_top.vhd:73:12
  pll_locked <= clock_manager_inst_locked; -- (signal)
  -- ../src/hdl/core/nebkiso_top.vhd:76:12
  rst_n_sync <= n53_q; -- (signal)
  -- ../src/hdl/core/nebkiso_top.vhd:77:12
  system_rst <= n54_q; -- (signal)
  -- ../src/hdl/core/nebkiso_top.vhd:78:12
  safety_rst <= n55_q; -- (signal)
  -- ../src/hdl/core/nebkiso_top.vhd:81:12
  watchdog_counter <= n104_q; -- (signal)
  -- ../src/hdl/core/nebkiso_top.vhd:82:12
  watchdog_timeout <= n105_q; -- (signal)
  -- ../src/hdl/core/nebkiso_top.vhd:85:12
  voc_data <= sensor_hub_inst_voc_data; -- (signal)
  -- ../src/hdl/core/nebkiso_top.vhd:86:12
  aq_data <= sensor_hub_inst_aq_data; -- (signal)
  -- ../src/hdl/core/nebkiso_top.vhd:87:12
  press_data <= sensor_hub_inst_pressure_data; -- (signal)
  -- ../src/hdl/core/nebkiso_top.vhd:88:12
  temp_data <= sensor_hub_inst_temp_data; -- (signal)
  -- ../src/hdl/core/nebkiso_top.vhd:89:12
  flow_data <= sensor_hub_inst_flow_data; -- (signal)
  -- ../src/hdl/core/nebkiso_top.vhd:92:12
  emergency_stop_int_a <= safety_monitor_a_emergency_stop; -- (signal)
  -- ../src/hdl/core/nebkiso_top.vhd:93:12
  emergency_stop_int_b <= safety_monitor_b_emergency_stop; -- (signal)
  -- ../src/hdl/core/nebkiso_top.vhd:94:12
  ventilation_on_int_a <= safety_monitor_a_ventilation_on; -- (signal)
  -- ../src/hdl/core/nebkiso_top.vhd:95:12
  ventilation_on_int_b <= safety_monitor_b_ventilation_on; -- (signal)
  -- ../src/hdl/core/nebkiso_top.vhd:98:12
  error_status <= n194_o; -- (signal)
  -- ../src/hdl/core/nebkiso_top.vhd:99:12
  error_counter <= n56_q; -- (signal)
  -- ../src/hdl/core/nebkiso_top.vhd:102:12
  current_state <= n181_q; -- (signal)
  -- ../src/hdl/core/nebkiso_top.vhd:104:12
  sensor_status <= sensor_hub_inst_sensor_status; -- (signal)
  -- ../src/hdl/core/nebkiso_top.vhd:107:12
  heartbeat_counter <= n124_q; -- (signal)
  -- ../src/hdl/core/nebkiso_top.vhd:108:12
  heartbeat_int <= n125_q; -- (signal)
  -- ../src/hdl/core/nebkiso_top.vhd:111:12
  system_status_int <= n191_o; -- (signal)
  -- ../src/hdl/core/nebkiso_top.vhd:112:12
  uart_tx_int <= uart_ctrl_tx; -- (signal)
  -- ../src/hdl/core/nebkiso_top.vhd:116:5
  clock_manager_inst : entity work.clock_manager port map (
    clk_in => wrap_clk_in,
    rst => system_rst,
    clk_sys => clock_manager_inst_clk_sys,
    clk_sample => open,
    clk_control => open,
    locked => clock_manager_inst_locked);
  -- ../src/hdl/core/nebkiso_top.vhd:128:18
  reset_sync_proc_sync_ff <= n57_q; -- (isignal)
  -- ../src/hdl/core/nebkiso_top.vhd:130:12
  n22_o <= '1' when rising_edge (clk_sys) else '0';
  -- ../src/hdl/core/nebkiso_top.vhd:131:31
  n23_o <= reset_sync_proc_sync_ff (1 downto 0);
  -- ../src/hdl/core/nebkiso_top.vhd:131:44
  n24_o <= n23_o & wrap_ext_rst_n;
  -- ../src/hdl/core/nebkiso_top.vhd:132:34
  n25_o <= n24_o (2);
  -- ../src/hdl/core/nebkiso_top.vhd:135:27
  n26_o <= not rst_n_sync;
  -- ../src/hdl/core/nebkiso_top.vhd:135:33
  n27_o <= n26_o or watchdog_timeout;
  -- ../src/hdl/core/nebkiso_top.vhd:135:59
  n28_o <= n27_o or wrap_watchdog_error;
  -- ../src/hdl/core/nebkiso_top.vhd:136:51
  n29_o <= not pll_locked;
  -- ../src/hdl/core/nebkiso_top.vhd:136:37
  n30_o <= n28_o or n29_o;
  -- ../src/hdl/core/nebkiso_top.vhd:142:33
  n32_o <= '1' when error_status /= "0000000000000000" else '0';
  -- ../src/hdl/core/nebkiso_top.vhd:143:52
  n34_o <= std_logic_vector (unsigned (error_counter) + unsigned'("00000001"));
  -- ../src/hdl/core/nebkiso_top.vhd:142:17
  n35_o <= error_counter when n32_o = '0' else n34_o;
  -- ../src/hdl/core/nebkiso_top.vhd:135:13
  n38_o <= '0' when n30_o = '0' else '1';
  -- ../src/hdl/core/nebkiso_top.vhd:135:13
  n40_o <= n35_o when n30_o = '0' else "00000000";
  -- ../src/hdl/core/nebkiso_top.vhd:148:50
  n42_o <= '1' when unsigned (error_counter) > unsigned'("11111111") else '0';
  -- ../src/hdl/core/nebkiso_top.vhd:148:33
  n43_o <= system_rst or n42_o;
  -- ../src/hdl/core/nebkiso_top.vhd:148:13
  n46_o <= '0' when n43_o = '0' else '1';
  -- ../src/hdl/core/nebkiso_top.vhd:130:9
  process (clk_sys)
  begin
    if rising_edge (clk_sys) then
      n53_q <= n25_o;
    end if;
  end process;
  -- ../src/hdl/core/nebkiso_top.vhd:130:9
  process (clk_sys)
  begin
    if rising_edge (clk_sys) then
      n54_q <= n38_o;
    end if;
  end process;
  -- ../src/hdl/core/nebkiso_top.vhd:130:9
  process (clk_sys)
  begin
    if rising_edge (clk_sys) then
      n55_q <= n46_o;
    end if;
  end process;
  -- ../src/hdl/core/nebkiso_top.vhd:130:9
  process (clk_sys)
  begin
    if rising_edge (clk_sys) then
      n56_q <= n40_o;
    end if;
  end process;
  -- ../src/hdl/core/nebkiso_top.vhd:130:9
  process (clk_sys)
  begin
    if rising_edge (clk_sys) then
      n57_q <= n24_o;
    end if;
  end process;
  -- ../src/hdl/core/nebkiso_top.vhd:157:5
  sensor_hub_inst : entity work.sensor_hub port map (
    clk => clk_sys,
    rst => system_rst,
    adc_spi_miso => wrap_adc_spi_miso,
    cal_mode => wrap_cal_mode,
    cal_data => wrap_cal_data,
    cal_addr => wrap_cal_addr,
    cal_wr => wrap_cal_wr,
    scl => sensor_hub_inst_scl,
    sda => sensor_hub_inst_sda,
    adc_spi_sclk => sensor_hub_inst_adc_spi_sclk,
    adc_spi_mosi => sensor_hub_inst_adc_spi_mosi,
    adc_spi_cs_n => sensor_hub_inst_adc_spi_cs_n,
    voc_data => sensor_hub_inst_voc_data,
    aq_data => sensor_hub_inst_aq_data,
    pressure_data => sensor_hub_inst_pressure_data,
    temp_data => sensor_hub_inst_temp_data,
    flow_data => sensor_hub_inst_flow_data,
    sensor_status => sensor_hub_inst_sensor_status,
    error_flags => sensor_hub_inst_error_flags);
  -- ../src/hdl/core/nebkiso_top.vhd:181:5
  safety_monitor_a : entity work.safety_monitor port map (
    clk => clk_sys,
    rst => safety_rst,
    voc_levels => voc_data,
    air_quality => aq_data,
    pressure_levels => press_data,
    temperature => temp_data,
    flow_sensors => flow_data,
    voc_threshold => wrap_voc_threshold,
    aq_threshold => wrap_aq_threshold,
    press_threshold => wrap_press_threshold,
    temp_threshold => wrap_temp_threshold,
    flow_threshold => wrap_flow_threshold,
    emergency_stop => safety_monitor_a_emergency_stop,
    ventilation_on => safety_monitor_a_ventilation_on,
    chamber_shutdown => safety_monitor_a_chamber_shutdown,
    safety_status => open,
    error_code => safety_monitor_a_error_code,
    error_location => open);
  -- ../src/hdl/core/nebkiso_top.vhd:203:5
  safety_monitor_b : entity work.safety_monitor port map (
    clk => clk_sys,
    rst => safety_rst,
    voc_levels => voc_data,
    air_quality => aq_data,
    pressure_levels => press_data,
    temperature => temp_data,
    flow_sensors => flow_data,
    voc_threshold => wrap_voc_threshold,
    aq_threshold => wrap_aq_threshold,
    press_threshold => wrap_press_threshold,
    temp_threshold => wrap_temp_threshold,
    flow_threshold => wrap_flow_threshold,
    emergency_stop => safety_monitor_b_emergency_stop,
    ventilation_on => safety_monitor_b_ventilation_on,
    chamber_shutdown => safety_monitor_b_chamber_shutdown,
    safety_status => open,
    error_code => open,
    error_location => open);
  -- ../src/hdl/core/nebkiso_top.vhd:226:5
  uart_ctrl : entity work.uart_controller_868 port map (
    clk => clk_sys,
    rst => system_rst,
    rx => wrap_uart_rx,
    tx_data => n78_o,
    tx_start => n79_o,
    tx => uart_ctrl_tx,
    tx_busy => open,
    rx_data => open,
    rx_done => open);
  -- ../src/hdl/core/nebkiso_top.vhd:242:12
  n81_o <= '1' when rising_edge (clk_sys) else '0';
  -- ../src/hdl/core/nebkiso_top.vhd:248:54
  n83_o <= std_logic_vector (unsigned (watchdog_counter) + unsigned'("000000000000000000000001"));
  -- ../src/hdl/core/nebkiso_top.vhd:251:37
  n85_o <= '1' when watchdog_counter = "111111111111111111111111" else '0';
  -- ../src/hdl/core/nebkiso_top.vhd:251:17
  n87_o <= watchdog_timeout when n85_o = '0' else '1';
  -- ../src/hdl/core/nebkiso_top.vhd:256:34
  n89_o <= '1' when current_state = "011" else '0';
  -- ../src/hdl/core/nebkiso_top.vhd:256:61
  n91_o <= '1' when error_status = "0000000000000000" else '0';
  -- ../src/hdl/core/nebkiso_top.vhd:256:44
  n92_o <= n89_o and n91_o;
  -- ../src/hdl/core/nebkiso_top.vhd:256:17
  n94_o <= n83_o when n92_o = '0' else "000000000000000000000000";
  -- ../src/hdl/core/nebkiso_top.vhd:256:17
  n96_o <= n87_o when n92_o = '0' else '0';
  -- ../src/hdl/core/nebkiso_top.vhd:243:13
  n98_o <= n94_o when system_rst = '0' else "000000000000000000000000";
  -- ../src/hdl/core/nebkiso_top.vhd:243:13
  n100_o <= n96_o when system_rst = '0' else '0';
  -- ../src/hdl/core/nebkiso_top.vhd:242:9
  process (clk_sys)
  begin
    if rising_edge (clk_sys) then
      n104_q <= n98_o;
    end if;
  end process;
  -- ../src/hdl/core/nebkiso_top.vhd:242:9
  process (clk_sys)
  begin
    if rising_edge (clk_sys) then
      n105_q <= n100_o;
    end if;
  end process;
  -- ../src/hdl/core/nebkiso_top.vhd:267:12
  n107_o <= '1' when rising_edge (clk_sys) else '0';
  -- ../src/hdl/core/nebkiso_top.vhd:272:56
  n109_o <= std_logic_vector (unsigned (heartbeat_counter) + unsigned'("0000000000000000000000001"));
  -- ../src/hdl/core/nebkiso_top.vhd:273:38
  n110_o <= "000" & heartbeat_counter;  --  uext
  -- ../src/hdl/core/nebkiso_top.vhd:273:38
  n112_o <= '1' when n110_o = "0001111111111111111111111111" else '0';
  -- ../src/hdl/core/nebkiso_top.vhd:275:38
  n113_o <= not heartbeat_int;
  -- ../src/hdl/core/nebkiso_top.vhd:273:17
  n115_o <= n109_o when n112_o = '0' else "0000000000000000000000000";
  -- ../src/hdl/core/nebkiso_top.vhd:273:17
  n116_o <= heartbeat_int when n112_o = '0' else n113_o;
  -- ../src/hdl/core/nebkiso_top.vhd:268:13
  n118_o <= n115_o when system_rst = '0' else "0000000000000000000000000";
  -- ../src/hdl/core/nebkiso_top.vhd:268:13
  n120_o <= n116_o when system_rst = '0' else '0';
  -- ../src/hdl/core/nebkiso_top.vhd:267:9
  process (clk_sys)
  begin
    if rising_edge (clk_sys) then
      n124_q <= n118_o;
    end if;
  end process;
  -- ../src/hdl/core/nebkiso_top.vhd:267:9
  process (clk_sys)
  begin
    if rising_edge (clk_sys) then
      n125_q <= n120_o;
    end if;
  end process;
  -- ../src/hdl/core/nebkiso_top.vhd:284:12
  n127_o <= '1' when rising_edge (clk_sys) else '0';
  -- ../src/hdl/core/nebkiso_top.vhd:290:62
  n129_o <= '1' when error_status = "0000000000000000" else '0';
  -- ../src/hdl/core/nebkiso_top.vhd:290:45
  n130_o <= pll_locked and n129_o;
  -- ../src/hdl/core/nebkiso_top.vhd:290:25
  n132_o <= current_state when n130_o = '0' else "001";
  -- ../src/hdl/core/nebkiso_top.vhd:289:21
  n134_o <= '1' when current_state = "000" else '0';
  -- ../src/hdl/core/nebkiso_top.vhd:297:48
  n136_o <= '1' when wrap_operational_mode /= "00" else '0';
  -- ../src/hdl/core/nebkiso_top.vhd:297:73
  n138_o <= '1' when error_status = "0000000000000000" else '0';
  -- ../src/hdl/core/nebkiso_top.vhd:297:56
  n139_o <= n136_o and n138_o;
  -- ../src/hdl/core/nebkiso_top.vhd:297:25
  n141_o <= current_state when n139_o = '0' else "011";
  -- ../src/hdl/core/nebkiso_top.vhd:295:25
  n143_o <= n141_o when wrap_cal_mode = '0' else "010";
  -- ../src/hdl/core/nebkiso_top.vhd:294:21
  n145_o <= '1' when current_state = "001" else '0';
  -- ../src/hdl/core/nebkiso_top.vhd:302:37
  n146_o <= not wrap_cal_mode;
  -- ../src/hdl/core/nebkiso_top.vhd:302:25
  n148_o <= current_state when n146_o = '0' else "001";
  -- ../src/hdl/core/nebkiso_top.vhd:301:21
  n150_o <= '1' when current_state = "010" else '0';
  -- ../src/hdl/core/nebkiso_top.vhd:307:41
  n152_o <= '1' when error_status /= "0000000000000000" else '0';
  -- ../src/hdl/core/nebkiso_top.vhd:309:58
  n153_o <= emergency_stop_int_a or emergency_stop_int_b;
  -- ../src/hdl/core/nebkiso_top.vhd:309:25
  n155_o <= current_state when n153_o = '0' else "100";
  -- ../src/hdl/core/nebkiso_top.vhd:307:25
  n157_o <= n155_o when n152_o = '0' else "110";
  -- ../src/hdl/core/nebkiso_top.vhd:306:21
  n159_o <= '1' when current_state = "011" else '0';
  -- ../src/hdl/core/nebkiso_top.vhd:314:63
  n161_o <= '1' when error_status = "0000000000000000" else '0';
  -- ../src/hdl/core/nebkiso_top.vhd:314:46
  n162_o <= wrap_error_reset and n161_o;
  -- ../src/hdl/core/nebkiso_top.vhd:314:25
  n164_o <= current_state when n162_o = '0' else "001";
  -- ../src/hdl/core/nebkiso_top.vhd:313:21
  n166_o <= '1' when current_state = "100" else '0';
  -- ../src/hdl/core/nebkiso_top.vhd:319:63
  n168_o <= '1' when error_status = "0000000000000000" else '0';
  -- ../src/hdl/core/nebkiso_top.vhd:319:46
  n169_o <= wrap_error_reset and n168_o;
  -- ../src/hdl/core/nebkiso_top.vhd:319:25
  n171_o <= current_state when n169_o = '0' else "001";
  -- ../src/hdl/core/nebkiso_top.vhd:318:21
  n173_o <= '1' when current_state = "110" else '0';
  n174_o <= n173_o & n166_o & n159_o & n150_o & n145_o & n134_o;
  -- ../src/hdl/core/nebkiso_top.vhd:288:17
  with n174_o select n176_o <=
    n171_o when "100000",
    n164_o when "010000",
    n157_o when "001000",
    n148_o when "000100",
    n143_o when "000010",
    n132_o when "000001",
    "000" when others;
  -- ../src/hdl/core/nebkiso_top.vhd:285:13
  n178_o <= n176_o when system_rst = '0' else "000";
  -- ../src/hdl/core/nebkiso_top.vhd:284:9
  process (clk_sys)
  begin
    if rising_edge (clk_sys) then
      n181_q <= n178_o;
    end if;
  end process;
  -- ../src/hdl/core/nebkiso_top.vhd:332:46
  n182_o <= emergency_stop_int_a and emergency_stop_int_b;
  -- ../src/hdl/core/nebkiso_top.vhd:333:46
  n183_o <= emergency_stop_int_a and emergency_stop_int_b;
  -- ../src/hdl/core/nebkiso_top.vhd:334:46
  n184_o <= ventilation_on_int_a and ventilation_on_int_b;
  -- ../src/hdl/core/nebkiso_top.vhd:335:46
  n185_o <= ventilation_on_int_a and ventilation_on_int_b;
  -- ../src/hdl/core/nebkiso_top.vhd:339:38
  n188_o <= sensor_status (2 downto 0);
  -- ../src/hdl/core/nebkiso_top.vhd:338:97
  n189_o <= current_state & n188_o;
  -- ../src/hdl/core/nebkiso_top.vhd:339:51
  n190_o <= n189_o & pll_locked;
  -- ../src/hdl/core/nebkiso_top.vhd:340:36
  n191_o <= n190_o & watchdog_timeout;
  -- ../src/hdl/core/nebkiso_top.vhd:345:31
  n192_o <= error_status (7 downto 0);
  -- ../src/hdl/core/nebkiso_top.vhd:346:22
  n193_o <= not watchdog_timeout;
  n194_o <= safety_monitor_a_error_code & sensor_hub_inst_error_flags;
end rtl;
