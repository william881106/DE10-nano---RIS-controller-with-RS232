/*
輸入：重置訊號(reset)、115200Hz 時脈(clock)、被傳輸資料、開始傳輸訊號。
輸出：Tx 訊號。
*/
module TX(

		input 		 clk,       // 115200 Hz
		input 		 reset,     // system reset
		input        _start,    // start transmission
		input  [31:0] T_data_in,// 傳輸資料
		output reg	 TX         // output signal (串列傳輸，所以只有一個bit)
);

wire 			count_reset;   // count 的 Reset 訊號
wire 			enable_shift;  // 可以開始 serial output
wire 			TDC;           // (連續)傳輸完成的訊號 
wire     	output_select; // MUX 的 selection bit
wire        start;			// start signal (防彈跳過後的訊號)
wire [39:0]	_T_data;
wire [39:0]	T_data;


// Tx NSG 的 current / next state
reg  [2:0]	cs;
reg  [2:0]	ns;

// One-Shot NSG 的 current / next state
reg  [2:0]	cs1;
reg  [2:0]	ns1;


reg  [3:0]	ss;
reg  [5:0]	count;     // 計數器，計數傳了幾個bit
reg  [3:0]	outs;      // {output_select, enable_shift, count_reset} 的 BUS
reg  [39:0] Trans_bit; // 串列傳輸的 register



/////////////////////////////////// NSG (Next State Generator) /////////////////////////////////////////////
//////////////////////////// One-Shot (prevent start signal glitch) ////////////////////////////////////////
// 功能如同 one_shot.v，主要為了防止內部訊號不明波動，造成訊號錯誤的被突波的正緣/高電位觸發
// 詳細說明可見 one_shot.v

always@(posedge clk)
	cs1 <= ns1;

always@(cs1)
	if(reset==1'b1)
		ns1 <= 3'b0;
	else
		case(cs1)
			3'd0:ns1 <= (_start)?3'd1:3'd0;
			3'd1:ns1 <= (_start)?3'd2:3'd0;//當cs=1,ns先判斷start，若start=1，進入狀態2，否則留在狀態1
			3'd2:ns1 <= 3'd3;
			3'd3:ns1 <= 3'd4;//當cs=3,ns先判斷TDC，若TDC=1，進入狀態4，否則留在狀態3
			3'd4:ns1 <= (_start)?3'd4:3'd0;
			default:ns1 <= 3'd0;
		endcase

assign start = (cs1==3'd3)?1:0;



////////////////////////////////////// NSG (Next State Generator) ////////////////////////////////////////////////
///////////////////////////////////// control serial transmission ////////////////////////////////////////////////
// RS232 Tx 端的核心部分

always@(posedge clk)
	cs <= ns;

always@(cs or TDC or start or reset)
	if(reset==1'b1)
		ns<=3'b0;
	else
		case(cs)
			3'd0:ns<=3'd1;
			3'd1:ns<=(start)?3'd2:3'd1;//當cs=1,ns先判斷start，若start=1，進入狀態2，否則留在狀態1
			3'd2:ns<=3'd3;
			3'd3:ns<=(TDC)?3'd4:3'd3;  //當cs=3,ns先判斷TDC，若TDC=1，進入狀態4，否則留在狀態3
			3'd4:ns<=3'd1;
			default:ns<=3'd0;
		endcase
	
	
/////////////////////////////////////////// counter /////////////////////////////////////////////////////////
always@(posedge clk)
	if(count_reset)//除count_reset為歸0訊號外，其餘count皆累加1上去
		count<=0;
	else
		count<=count+1;
		

/////////////////////////////////////////// comparator ////////////////////////////////////////////////////

assign TDC=(count==6'd39)?1'b1:1'b0;//當count到39時(傳輸40個bits)，TDC輸出1，否則輸出0   




//////////////////////////////////////////// decoder ///////////////////////////////////////////////////////		

always@(cs)
	case(cs)
		3'd0:outs<=3'b100; //當cs=0，outs輸出1000，其餘以此類推
		3'd1:outs<=3'b100;
		3'd2:outs<=3'b100;
		3'd3:outs<=3'b011;
		3'd4:outs<=3'b100;
		default:outs<=3'b000;
	endcase	

assign enable_shift  = outs[0]; //outs的第0個位元為訊號enable_shift
assign output_select  = outs[1];//outs的第1個位元為訊號output_select
assign count_reset = outs[2];   //outs的第2個位元為訊號count_reset






 
////////////////////////////////////////shift register///////////////////////////////////////
// 連續傳送一組 32bit 的訊號，需要綑綁成40個bit
// 每一串傳送的 {start bit , 8-bits data, stop bit} 中, start bit = 0 才會被接收端辨識成正要傳輸

assign T_data = { 1'b1,   T_data_in[31:24], 1'b0,
						1'b1,   T_data_in[23:16], 1'b0, 
						1'b1,   T_data_in[15:8] , 1'b0, 
						1'b1,   T_data_in[7:0]  , 1'b0 };
					// stop bit	8-bits data      start bit
				
			
			

assign _T_data={Trans_bit[0],Trans_bit[39:1]};//將每個位元右移一位，並將最右邊的位元移到最左邊


always @(posedge clk)
	if(start)   //load data
		Trans_bit <= T_data;
	else
		if(enable_shift)   //enable shiftout, enable_shift = outs[0]
			Trans_bit <= _T_data;
		else
			Trans_bit <= T_data;


///////////////////////////////////////// MUX ///////////////////////////////////////////

always @(output_select or Trans_bit[0])//outs[2:1]
	case(output_select)
		1'b0:ss <= 1'b1;         //output_select = 0 為 waiting, 維持高電位代表沒有要傳輸
		1'b1:ss <= Trans_bit[0]; //output_select = 1 為 shiftout, 開始傳輸資料
		default:ss <= 1'b1;
	endcase 

//assign stop = (output_select==2'd3)?1'b1:1'b0;


////////////////////////////////////////////DFF////////////////////////////////////////

always@(posedge clk)//當正緣觸發 
	TX <= ss;          //Tx 輸出端

	
endmodule	
