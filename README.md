# DE10-nano---RIS-controller-with-RS232
DE10-nano 上開發的 RIS phase controller ，以 UART 通訊協定 ( RS232 Transceiver ) 傳輸控制狀態

## Hardware
1. DE10-nano (可以使用其他 altera 的系列板，需要自行重新下PIN腳)
2. HC-05 Bluetooth Module x 1  或  USB-to-TTL x 2 (差別是無線 / 有線傳輸，無線傳輸需要電腦有藍芽)

## FPGA Function
| File            | Function                                           |
| --------------- |:--------------------------------------------------:|
| RIS_controller.v| main file                                          |
| _7Seg.v         | 七段顯示器的顯示電路 (7-segment)                     |
| fDIV_115200HZ.v | 除頻器 (更改 clk 頻率至 115200Hz)                    |
| one_shot.v      |  防止電路訊號跳動，造成錯誤的正負緣觸發                |
| ROM_GPIO.v      | RIS 控制狀態編/解碼                                  |
| SNRcollector.v  | SNR / 控制狀態 (serial-in data) 儲存、parallel-out   |
| TxEncoder.v     | 將欲回傳資訊編碼                                     |
| Tx.v            | RS232 Transmitter (115200Hz)                        |
| Rx.v            | RS232 Receiver (115200Hz)                           |

## System Block Diagram
**Whole system block generate by RTL viewer**
![This is an alt text.](/Image/Whole_System.png)
**Rx system block generate by RTL viewer**
![This is an alt text.](/Image/Rx.png)
**其餘自動產生的細節可參考/Image/Whole_System(detail).pdf 圖可放大**

## MATLAB Function
| File                 | Function                                           |
| -------------------- |:--------------------------------------------------:|
| RS232_4x4_4state.m   | main file                                          |
| RS232initial.m       | 傳送初始化信號，reset FPGA                           |
| RS232rx.m            | 接收 FPGA 回傳的控制狀態                             |
| RS232tx_GPIO.m       | 傳送想要的控制狀態給 FPGA                            |
| RS232tx_reset1step.m | 傳送失敗時使用，重新傳送該筆傳送失敗的控制狀態          |

**如果你是有線傳輸， main file 中請使用 `serialport`**
**如果你是藍芽傳輸， main file 中請使用 `bluetooth`**
