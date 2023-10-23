module SNRcollector( 
		input             reset,       // system reset
		input 			   output_sel,  // 接收完成的訊號
		input      [7:0]  din_ASCII,   // 接收到的 data (ASCII形式)
		
		output reg        SNR_start,   // 接收到 SNR 後解碼完成時為高電位
		output reg        GPIO_start,  // 接收到 控制狀態 後解碼完成時為高電位
		output reg [31:0] dout         // 接收到並解碼完的控制狀態
); 

reg [5:0]    din;
reg [69:0]   dtmp;

parameter allzero = 70'd0; // 清0用


/////////////////////////////////////// ASCII to Word ////////////////////////////////////////////////////
/*
space     當傳送SNR時，用來補齊傳送資料長度 (如 " 99","  1")
plus      傳送一串 "element控制狀態" / "SNR" 時，在資料最前端加上 "+"，讓 FPGA 知道要開始接收資料
minus     當 MATLAB 傳送初始化訊號時，會傳送 "element全0" 以及 "SNR=-99" 的訊號，其中以minus代表負號
semicolon 當 MATLAB 傳送的值是 "SNR" 時，會以":"作為結尾來辨識
at        當 MATLAB 傳送的值是 "element控制狀態" 時，會以"@"作為結尾來辨識
*/

//MATLAB 傳輸 -> FPGA 收到 的是ASCII，所以只能先對收到的數值做解碼
always@(din_ASCII)
	case(din_ASCII)
		32: din = 12;		//ASCII value 32 = 12 in Binary replace to " "  
		43: din = 11;		//ASCII value 43 = 11 in Binary replace to "Plus"
		45: din = 10;		//ASCII value 45 = 10 in Binary replace to "Minus"
		59: din = 13;     //ASCII value 59 = 13 in Binary replace to "semicolon(;)"
		64: din = 14;		//ASCII value 64 = 14 in Binary replace to "at(@)"
		47: din = 15;		//ASCII value 47 = 15 in Binary replace to "/"
		
		48: din = 0;		//ASCII value 48 = 0 in Binary
		49: din = 1;		//ASCII value 49 = 1 in Binary
		50: din = 2;		//ASCII value 50 = 2 in Binary
		51: din = 3;		//ASCII value 51 = 3 in Binary
		52: din = 4;		//ASCII value 52 = 4 in Binary
		53: din = 5; 		//ASCII value 53 = 5 in Binary
		54: din = 6;		//ASCII value 54 = 6 in Binary
		55: din = 7;		//ASCII value 55 = 7 in Binary
		56: din = 8;		//ASCII value 56 = 8 in Binary
		57: din = 9;		//ASCII value 57 = 9 in Binary
	endcase	

/////////////////////////////////////// Stack Words //////////////////////////////////////////////////////

always @(negedge output_sel or posedge reset)
begin
	if(reset)
		begin
			SNR_start = 0;
			GPIO_start = 0;		
			dout = 70'd0;
			dtmp = 70'd0;
		end
	
	else
		begin
			if (din == 6'd11) // if PLUS(+)，為收到的 data 的開頭
				begin          
					dtmp = allzero;    // 清0
					SNR_start = 1'b0;  // 不顯示 SNR  
					GPIO_start = 1'b0; // 不輸出 GPIO
				end
			
			
			else if (din == 6'd13) // if semicolon(;)，為收到 SNR 的結束
				begin
					dout = dtmp;       // 將 SNR 存下來 (for Display)
					SNR_start = 1'b1;  // 顯示 SNR 的訊號
					GPIO_start = 1'b0; // 不輸出GPIO
				end
				
			
			
			else if (din == 6'd14) // if at(@) 14，為收到 "控制狀態" 的結束
			   begin		           // 暴力法將收到的訊號 (0~9) 全部加總起來
					if(dtmp[11:6] == 6'd12) // 空格
						dout =  1*dtmp[3:0] ;
						
					else if(dtmp[17:12] == 6'd12)		
						dout =  (10*dtmp[9:6]) + (1*dtmp[3:0]) ;
						
					else if(dtmp[23:18] == 6'd12)			
						dout =  (100*dtmp[15:12]) + (10*dtmp[9:6]) + (1*dtmp[3:0]) ;
						
					else if(dtmp[29:24] == 6'd12)		
						dout =  (1000*dtmp[21:18]) + (100*dtmp[15:12]) + (10*dtmp[9:6]) + (1*dtmp[3:0]) ;
						
					else if(dtmp[35:30] == 6'd12)		
						dout =  (10000*dtmp[27:24]) + (1000*dtmp[21:18]) + (100*dtmp[15:12]) + (10*dtmp[9:6]) + (1*dtmp[3:0]) ;
						
					else if(dtmp[41:36] == 6'd12)		
						dout =  (100000*dtmp[33:30]) + (10000*dtmp[27:24]) + (1000*dtmp[21:18]) + (100*dtmp[15:12]) + (10*dtmp[9:6]) + (1*dtmp[3:0]) ;
						
					else if(dtmp[47:42] == 6'd12)		
						dout =  (1000000*dtmp[39:36]) + (100000*dtmp[33:30]) + (10000*dtmp[27:24]) + (1000*dtmp[21:18]) + (100*dtmp[15:12]) + (10*dtmp[9:6]) + (1*dtmp[3:0]) ;
						
					else if(dtmp[53:48] == 6'd12)		
						dout =  (10000000*dtmp[45:42]) + (1000000*dtmp[39:36]) + (100000*dtmp[33:30]) + (10000*dtmp[27:24]) + (1000*dtmp[21:18]) + (100*dtmp[15:12]) + (10*dtmp[9:6]) + (1*dtmp[3:0]) ;
						
					else if(dtmp[59:54] == 6'd12)		
						dout =  (100000000*dtmp[51:48]) + (10000000*dtmp[45:42]) + (1000000*dtmp[39:36]) + (100000*dtmp[33:30]) + (10000*dtmp[27:24]) + (1000*dtmp[21:18]) + (100*dtmp[15:12]) + (10*dtmp[9:6]) + (1*dtmp[3:0]) ;
						
					else
						dout =  (1000000000*dtmp[57:54]) + (100000000*dtmp[51:48]) + (10000000*dtmp[45:42]) + (1000000*dtmp[39:36]) + (100000*dtmp[33:30]) + (10000*dtmp[27:24]) + (1000*dtmp[21:18]) + (100*dtmp[15:12]) + (10*dtmp[9:6]) + (1*dtmp[3:0]) ;
						
					SNR_start = 1'b0;   // 不顯示 SNR  
					GPIO_start = 1'b1;  // 輸出GPIO
				end
				

			else  // 除上述遇到特殊符號以外，其餘時間收到的資料會以串列形式一個個輸入進來
			      // Rx 接收資料以 8 bit 為一個單位(收到的是ASCII)，會在上方先解碼成 din (6 bits)
					// 因為一次控制傳輸會需要連續接收，代表會收到很多個 din
					// 所以儲存時會一直 shift，讓下一筆新收到的能補進去
				begin
					dtmp[65:60] = dtmp[59:54];
					dtmp[59:54] = dtmp[53:48];
					dtmp[53:48] = dtmp[47:42];
					dtmp[47:42] = dtmp[41:36];
					dtmp[41:36] = dtmp[35:30];
					dtmp[35:30] = dtmp[29:24];			
					dtmp[29:24] = dtmp[23:18];
					dtmp[23:18] = dtmp[17:12];
					dtmp[17:12] = dtmp[11:6];
					dtmp[11:6] = dtmp[5:0];
					dtmp[5:0] = din;
					SNR_start = 1'b0;  // 不顯示 SNR  
					GPIO_start = 1'b0; // 不輸出GPIO
				end
				
		end
end

endmodule 