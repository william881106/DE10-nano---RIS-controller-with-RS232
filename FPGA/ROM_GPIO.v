
/*

對單一個 RIS element 的控制狀態進行編/解碼

*/
module   ROM_GPIO (start, Address, D_Out);

input              start;   // 可以開始解碼 Address 的訊號
input     [1:0]    Address; // 收到的 RIS 控制狀態編號
output  reg  [1:0] D_Out;   // 依據收到的編號，輸出對應的 RIS 控制狀態(GPIO)



//編碼矩陣，wire 名稱前面的中括號是編碼的 bit 數
//名稱後面的中括號是有幾種不同的 DPS 控制狀態
wire      [1:0]    ROM_Data[3:0]; 




/*
我們將 RIS 狀態編碼成 ...000、...001、...010、...011、...
但未必一定是以 ...000 來控制 DPS
比方 DPS 我們選擇了 0011、0111、1010、1111 四個 phase
我們依序將上面四個 phase 編碼成 00、01、10、11 時
這兩組數值之間並沒有直接關聯
所以需要將接收到的控制訊號 (Address) 進一步解碼成控制的相位
透過以下兩個註解的例子 
可以看到 Address 與最終要控制 DPS 的數值沒有直接關係
只是將其編號而已

EX 1.
assign ROM_Data[0] = 4'b0001; //狀態0 : 用 0th bit 控制DPS
assign ROM_Data[1] = 4'b0010; //狀態1 : 用 1st bit 控制DPS
assign ROM_Data[2] = 4'b0100; //狀態2 : 用 2nd bit 控制DPS
assign ROM_Data[3] = 4'b1000; //狀態3 : 用 3rd bit 控制DPS

EX 2.
assign ROM_Data[0] = 4'b0100; //狀態0 : GPIO = 4
assign ROM_Data[1] = 4'b0111; //狀態1 : GPIO = 7
*/



assign ROM_Data[0] = 2'b00; // 0 (State0~3)
assign ROM_Data[1] = 2'b01; // 1
assign ROM_Data[2] = 2'b10; // 2
assign ROM_Data[3] = 2'b11; // 3


/*
assign ROM_Data[0] = 4'b0000; 
assign ROM_Data[1] = 4'b0001; 
assign ROM_Data[2] = 4'b0010; 
assign ROM_Data[3] = 4'b0011; 
assign ROM_Data[4] = 4'b0100;
assign ROM_Data[5] = 4'b0101; 
assign ROM_Data[6] = 4'b0110; 
assign ROM_Data[7] = 4'b0111; 
assign ROM_Data[8] = 4'b1000;
assign ROM_Data[9] = 4'b1001; 
assign ROM_Data[10] = 4'b1010; 
assign ROM_Data[11] = 4'b1011; 
assign ROM_Data[12] = 4'b1100;
assign ROM_Data[13] = 4'b1101;
assign ROM_Data[14] = 4'b1110;
assign ROM_Data[15] = 4'b1111;
*/

always @(start)                // start = 1 時才開始解碼
	D_Out = ROM_Data[Address];  // 由ROM_Data內取出編碼資料
	
endmodule

