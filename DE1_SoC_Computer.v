module DE1_SoC_Computer (
		CLOCK_50, 
		reset, 
		Rx,

		Tx,        // RS232回傳
		Ctl_Gpio,   // GPIO控制
		led
);


//=======================================================
//  PORT declarations
//=======================================================

input			  CLOCK_50; // DE10 板子自帶時脈 50MHz
input			  reset;    // system reset 指撥開關
input			  Rx;       // 接收從 MATLAB 傳過來的訊息

output		  Tx;       // 回傳給 MATLAB (向 MATLAB 告知 FPGA 收到的訊號)
output [31:0] Ctl_Gpio; // GPIO控制
output [7:0]  led;      // 可以檢查 GPIO 用



//=======================================================
//  REG/WIRE declarations
//=======================================================

wire 			 clk_115200;    // RS232 Baud Rate 115200 Hz
wire 			 Tx_start_out;  // 需要 Tx 開始傳輸時為高電位
wire		    SNR_start;     // 需要顯示 SNR 時為高電位
wire			 GPIO_start;    // 需要輸出 GPIO 時為高電位

wire  [31:0] Receiced_Data; // 接收到的"控制狀態"
wire  [31:0] TxDataTMP;     // 需要回傳的"控制狀態"


assign led[7:0] = Ctl_Gpio[7:0];	// 可以檢查 GPIO 用



///////////////////////////////////////////////////////////////////////////////////////////////////


fDIV_115200HZ fDIV(
		CLOCK_50,
		clk_115200
);

TxEncoder TxEncoder(
		reset,
		SNR_start,
		GPIO_start,
		clk_115200,
		Receiced_Data,
		Tx_start_out, //可開始回傳
		Ctl_Gpio,     //GPIO的控制訊號
		TxDataTMP     //回傳完成GPIO控制的代號
);


TX	Transmiter0(
		clk_115200,
		reset,
		Tx_start_out,
		TxDataTMP,
		Tx
);
	

RX Receiver(
		clk_115200,
		reset,
		Rx,
		SNR_start, 
		GPIO_start,	
		Receiced_Data 
);




endmodule // end top level