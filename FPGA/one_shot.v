/*
輸入：按鈕訊號。輸出：穩定的訊號輸出。
在按按鈕的時候，訊號並不是很穩定的送出，而是有一段彈跳時間，
其電位會高低來回跳動，將造成按一次按鍵，硬體卻會收到多個訊號，造成錯誤。
防彈跳就是為了消除不穩定的訊號而設計，利用一個有限狀態機，在確定輸入
訊號穩定後才將之傳遞給下一級電路。
*/
module one_shot(

		input      din,
		input      clk, 
		output reg dout
		
);

wire      _dout;
reg [2:0] cs;
reg [2:0] ns;


always @(posedge clk)
	cs <= ns;		
	
	
always @(cs)
			
	case(cs)
		3'd0: ns <= (din)?3'd1:3'd0;
		3'd1: ns <= (din)?3'd2:3'd0;
		3'd2: ns <= (din)?3'd3:3'd0;
		3'd3: ns <= 3'd4;
		3'd4: ns <= (din)?3'd4:3'd0;
		default: ns <= 3'd0;
	endcase
	
assign _dout =(cs==3'd3)?1'd1:1'd0;	
	
always @(negedge clk)
	 dout = _dout;

endmodule		
		