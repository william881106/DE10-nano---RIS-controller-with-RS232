module TxEncoder(

		input 		      reset,       // system reset
		input             SNR_start,   // SNR 接收完成時為高電位
		input             GPIO_start,  // GPIO 接收完成時為高電位
		input             clk,         // 系統 clk，115200 Hz
		input      [31:0] RData,       // RS232 收到的 data
		
		output reg  		Tx_start_out,// 告知 Tx 可以輸出資料的信號
		output     [31:0] CtlGpio,     // FPGA 用來控制 RIS element 的 GPIO
		output reg [31:0] TData        // 要傳送的資料 (給 Tx 的資料)
		
);

/*
wire [2:0] address1;
wire [2:0] address2;
wire [2:0] address3;
wire [2:0] address4;
wire [2:0] address5;
wire [2:0] address6;
wire [2:0] address7;
wire [2:0] address8;
wire [2:0] address9;
wire [2:0] address10;
wire [2:0] address11;
wire [2:0] address12;
wire [2:0] address13;
wire [2:0] address14;
wire [2:0] address15;
wire [2:0] address16;
*/

// MATLAB 傳送的控制訊號，編號 0~3 的控制狀態
// 有幾個 element 就會得到幾個控制狀態
wire [1:0]	address1;
wire [1:0]	address2;
wire [1:0]	address3;
wire [1:0]	address4;
wire [1:0]	address5;
wire [1:0]	address6;
wire [1:0]	address7;
wire [1:0]	address8;
wire [1:0]	address9;
wire [1:0]	address10;
wire [1:0]	address11;
wire [1:0]	address12;
wire [1:0]	address13;
wire [1:0]	address14;
wire [1:0]	address15;
wire [1:0]	address16;

// 編號 0~3 控制狀態解碼後，GPIO 實際的控制訊號
// 有幾個 element 就會得到幾個控制訊號
wire [1:0] GPIO1;
wire [1:0] GPIO2;
wire [1:0] GPIO3;
wire [1:0] GPIO4;
wire [1:0] GPIO5;
wire [1:0] GPIO6;
wire [1:0] GPIO7;
wire [1:0] GPIO8;
wire [1:0] GPIO9;
wire [1:0] GPIO10;
wire [1:0] GPIO11;
wire [1:0] GPIO12;
wire [1:0] GPIO13;
wire [1:0] GPIO14;
wire [1:0] GPIO15;
wire [1:0] GPIO16;

wire       SNR_start_out;  // SNR  接收完成時為高電位(防彈跳過後的訊號)
wire       GPIO_start_out; // GPIO 接收完成時為高電位(防彈跳過後的訊號)

reg  [31:0] GPIO_num;      // GPIO Regiter，暫存接收到的(來自MATLAB)控制訊號
reg  [3:0] cs;
reg  [3:0] ns;


/////////////////////////////////// one_shot code ////////////////////////////////
// 功能如同 one_shot.v，主要為了防止內部訊號不明波動，造成訊號錯誤的被突波的正緣/高電位觸發
// 詳細說明可見 one_shot.v


// 對 SNR_start、GPIO_start 的跳動進行抑制

always @(posedge clk)
begin
	if(reset)
		cs <= 4'd0;	
	else
		cs <= ns;	
end
	
	
always @(cs)
	case(cs)
		4'd0 : ns <= (GPIO_start)?4'd1:((SNR_start)?4'd6:4'd0);
		
		4'd1 : ns <= (GPIO_start)?4'd2:4'd0;
		4'd2 : ns <= (GPIO_start)?4'd3:4'd0;
		4'd3 : ns <= 4'd4;
		4'd4 : ns <= 4'd5;
		4'd5 : ns <= (GPIO_start)?4'd5:4'd0;
		
		4'd6 : ns <= (SNR_start)?4'd7:4'd0;
		4'd7 : ns <= (SNR_start)?4'd8:4'd0;
		4'd8 : ns <= 4'd9;
		4'd9 : ns <= 4'd10;
		4'd10: ns <= (SNR_start)?4'd10:4'd0;				
		
		default: ns <= 4'd0;
	endcase


assign GPIO_start_out =(cs==4'd4)?1'd1:1'd0;
assign SNR_start_out =(cs==4'd9)?1'd1:1'd0;



///////////////////////////////////////////////////////////////////////////////////////////////////
always @(posedge reset or posedge SNR_start_out or posedge GPIO_start_out)
begin

	if (reset) // system reset
		begin
			Tx_start_out = 1'b0;
			GPIO_num = 32'd0;
			TData = 32'd0;			
		end
	
	else if(GPIO_start_out) // 當全部的控制訊號都收到，GPIO 準備好可以開始解碼
		begin	
			Tx_start_out = 1'b1;    // 告知 Tx 可以傳送資料
			GPIO_num = RData[31:0]; // 將所有收到的資料讀進來
			TData = GPIO_num;			// 將讀進來的資料放在 Tx 資料上，因為要回傳 MATLAB 告訴它 FPGA 收到的資料沒錯
		end
	
	else	 // default : 系統不作動，清0
		begin
			Tx_start_out = 1'b0;
			TData = 32'd0;
		end
end




///////////////////////////////////////////////////////////////////////////////////////////////////



// 16個Digital Phase Shift，每個DPS有2位元(4狀態:00、01、10、11)
// 4的16次方 = 4,294,967,296 -> log2(4...) = 32 -> GPIO_num[31:0]

assign address1 = GPIO_num[1:0];
assign address2 = GPIO_num[3:2];
assign address3 = GPIO_num[5:4];
assign address4 = GPIO_num[7:6];
assign address5 = GPIO_num[9:8];
assign address6 = GPIO_num[11:10];
assign address7 = GPIO_num[13:12];
assign address8 = GPIO_num[15:14];
assign address9 = GPIO_num[17:16];
assign address10 = GPIO_num[19:18];
assign address11 = GPIO_num[21:20];
assign address12 = GPIO_num[23:22];
assign address13 = GPIO_num[25:24];
assign address14 = GPIO_num[27:26];
assign address15 = GPIO_num[29:28];
assign address16 = GPIO_num[31:30];

/*
我們將 RIS 狀態編碼成 ...000、...001、...010、...011、...
但未必一定是以 ...000、...001、...010 來控制 DPS
比方 DPS 我們選擇了 0011、0111、1010、1111 四個 phase
我們依序將上面四個 phase 編碼成 00、01、10、11 時
這兩組數值之間並沒有直接關聯
所以需要將接收到的控制訊號 (Address) 進一步解碼成控制的相位
例子見 ROM_GPIO.v
*/

// 每一個 RIS element 都有各自的調控狀態，需要各自解碼
ROM_GPIO MAP_GPIO1( Tx_start_out, address1, GPIO1 );
ROM_GPIO MAP_GPIO2( Tx_start_out, address2, GPIO2 );
ROM_GPIO MAP_GPIO3( Tx_start_out, address3, GPIO3 );
ROM_GPIO MAP_GPIO4( Tx_start_out, address4, GPIO4 );
ROM_GPIO MAP_GPIO5( Tx_start_out, address5, GPIO5 );
ROM_GPIO MAP_GPIO6( Tx_start_out, address6, GPIO6 );
ROM_GPIO MAP_GPIO7( Tx_start_out, address7, GPIO7 );
ROM_GPIO MAP_GPIO8( Tx_start_out, address8, GPIO8 );
ROM_GPIO MAP_GPIO9( Tx_start_out, address9, GPIO9 );
ROM_GPIO MAP_GPIO10( Tx_start_out, address10, GPIO10 );
ROM_GPIO MAP_GPIO11( Tx_start_out, address11, GPIO11 );
ROM_GPIO MAP_GPIO12( Tx_start_out, address12, GPIO12 );
ROM_GPIO MAP_GPIO13( Tx_start_out, address13, GPIO13 );
ROM_GPIO MAP_GPIO14( Tx_start_out, address14, GPIO14 );
ROM_GPIO MAP_GPIO15( Tx_start_out, address15, GPIO15 );
ROM_GPIO MAP_GPIO16( Tx_start_out, address16, GPIO16 );

// 最後的GPIO控制訊號 (所有 element 的控制訊號綑綁成一個 BUS)
assign CtlGpio = {GPIO16,GPIO15,GPIO14,GPIO13,GPIO12,GPIO11,GPIO10,GPIO9,GPIO8,GPIO7,GPIO6,GPIO5,GPIO4,GPIO3,GPIO2,GPIO1};


endmodule		
