/*
輸入：重置訊號(reset)、115200Hz 時脈(clock)、Rx 訊號。
輸出：接收到的資料。
*/
module RX(
				
		input 		  clk,   // 115200 Hz
		input 		  reset, // system reset
		input 		  Rx,    // serial-input
		
		output        SNR_start, // 接收到 SNR 後解碼完成時為高電位
		output        GPIO_start,// 接收到 控制狀態 後解碼完成時為高電位
		output [31:0] Rx_stack   // 欲輸出的控制狀態，bit 數為 "element 數" 乘 "狀態 bit 數"
);
		


wire [7:0] _RData;
wire [7:0] _SR;
wire 		  RDC;
wire 		  output_sel;
wire 		  rst;
wire 		  en;
reg  [7:0] SR;
reg  [2:0] Outs;
reg  [2:0] cs;
reg  [2:0] ns;
reg  [2:0] count;
reg        _output_sel;

wire [7:0] RData;



//////////////////////////////////////// DFF //////////////////////////////////////////////////////
always@(posedge clk)
	cs <= ns;

	
//////////////////////////////////////// NSG (Next State Generator) //////////////////////////////
always@(cs or RDC or Rx or reset)
	if(reset==1'b1)
		ns <= 3'd0;
	else
		case(cs)
			3'd0:ns<=3'd1;
			3'd1:ns<=(Rx)?3'd1:3'd2;
			3'd2:ns<=(RDC)?3'd3:3'd2;
			3'd3:ns<=(Rx)?3'd4:3'd1;
			3'd4:ns<=(Rx)?3'd1:3'd2;
			default:ns<=3'd0;
		endcase

		
		
//////////////////////////////////////// decoder /////////////////////////////////////////////////
//control signal : reset(rst), register enable(en), output select(output_sel)
//reset(rst)                : reset counter when it is not receiving data
//register enable(en)       : when en = 1, we start saving the received data
//output select(output_sel) : select that our receive data should change or not (mutiple transfer)


always@(cs)//decoder
	case(cs)
		3'd0:Outs<=3'b100;
		3'd1:Outs<=3'b100;
		3'd2:Outs<=3'b010;
		3'd3:Outs<=3'b100;
		3'd4:Outs<=3'b101;
		default:Outs<=3'b000;
	endcase
	

assign output_sel = Outs[0];
assign en = Outs[1];
assign rst = Outs[2];



////////////////////////////////// RDC (receive data complete) ////////////////////////////////////////
always@(posedge clk)//counter
	if(rst)
		count <= 3'd0;
	else
		count <= count + 3'd1;
		
assign RDC = (count==3'd7)?1'b1:1'b0;//if count = 7 ,means 8-bit data received




//////////////////////////////////Register(receive and save serial data)//////////////////////////////////

assign _SR={Rx,SR[7:1]};//Shift Register




////////////////////////////////// output select /////////////////////////////////////////////////////////
always @(posedge clk)//dff2
	 _output_sel <= output_sel;
always @(posedge clk)
	SR = (en)?_SR:SR; 

	
/////////////////////////////////////// MUX //////////////////////////////////////////////////////////////
assign _RData = RData;
assign RData = (_output_sel)?SR:_RData;



/////////////////////////////////////// ASCII to Word ////////////////////////////////////////////////////

SNRcollector SNR( 
		reset,
		_output_sel,
		RData,
		SNR_start,
		GPIO_start,
		Rx_stack
); 


	

	
endmodule 