module _7Seg( 

		input      [3:0] din,
		output reg [6:0] dout
		
); 

// The segment can be turned on or off by applying a low logic level or high logic level from the FPGA, respectively.
// MEAN: "低電位發光"，所以是共陽極的七段顯示器。
always@(din)  	
	case(din)   
		4'b0000:dout<=7'b1000000;//當din=4'b0000時，表示0，此時dout輸出7'b1000000，為0
		4'b0001:dout<=7'b1111001;//為1
		4'b0010:dout<=7'b0100100;//為2
		4'b0011:dout<=7'b0110000;//為3
		4'b0100:dout<=7'b0011001;//為4
		4'b0101:dout<=7'b0010010;//為5
		4'b0110:dout<=7'b0000010;//為6
		4'b0111:dout<=7'b1111000;//為7
		4'b1000:dout<=7'b0000000;//為8
		4'b1001:dout<=7'b0010000;//為9
		4'b1010:dout<=7'b0111111;//當din為10，dout為"Minus"，即為"-"
		4'b1011:dout<=7'b0011100;//當din為11，dout為"小寫o"，for testing
		4'b1100:dout<=7'b1111111;//當din為12，dout為" "(空白鍵)	
	endcase 
endmodule 