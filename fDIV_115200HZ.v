/*
使用DE10 std. 的內部時脈(50MHz)，接上"除以434"的除頻器得到近似 115200Hz 的頻率。
*/
module fDIV_115200HZ(

		input 	  fin,
		output reg _fout

);

wire [31:0] DIVN;
wire [31:0] _DIVN;
wire 			fout;
reg  [31:0] count;

                      
assign DIVN = 32'd434;//除以434                          
assign _DIVN = {1'b0,DIVN[31:1]};//將DIVN右移一位，即對 DIVN 除以2

// 因為除數 = 434 代表在 50MHz 的時脈下，每434個正緣會產生一個"輸出正緣"
// 輸出一個正緣包含一個高電位 + 一個低電位
// 一個高電位 與 一個低電位 各佔 434/2 個系統clk的正緣(50MHz)



always @(posedge fin) //當正緣觸發
	if(count >= DIVN) //當count數超過DIVN時，count從1開始數，否則count+1
		count <= 32'd1;
	else
		count <= count+32'd1;
		
assign fout = (count <= _DIVN)?1'b0:1'b1;//當count數到_DIVN時，fout輸出0，否則輸出1


always @(negedge fin)
		_fout <= fout; //輸出新的 clk

endmodule 