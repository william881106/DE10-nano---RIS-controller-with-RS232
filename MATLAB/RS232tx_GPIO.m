function [txdata_temp, txdata_org, rx_all_dps] = RS232tx_GPIO(device, rx, txdata_temp, txdata_org, ASCIInum, state_num)
%% Setup
ASCII_space = ASCIInum.ASCII_space;
ASCII_plus = ASCIInum.ASCII_plus;
ASCII_at = ASCIInum.ASCII_at;

%%
if isempty (rx) %傳送錯誤的第一階段:傳送error訊號(空格88)給FPGA
    txdata_org = txdata_temp;
elseif (txdata_org == 88) %傳送錯誤的第二階段:傳送error後，重新傳送上筆資料
    txdata_org = txdata_temp;
else
%     txdata_org = fix(rand(1)*254+1);
%     txdata_org = txdata_org + 1;
    txdata_temp = txdata_org;
end

txdata_org_ASCII = double(num2str( txdata_org ));
if size(txdata_org_ASCII,2) < 3
    txdata_org_ASCII = [ASCII_space*ones(length(txdata_org),1), txdata_org_ASCII]; 
end
Plus_ASCII = ASCII_plus*ones(length(txdata_org),1);
at_ASCII = ASCII_at*ones(length(txdata_org),1);
txdata = [ Plus_ASCII, txdata_org_ASCII , at_ASCII ]; 

%%
rx_mod1 = mod(txdata_org, state_num);    rx_fix1 = fix(txdata_org/ state_num);   rx_1bit = rx_mod1;
rx_mod2 = mod(rx_fix1, state_num);       rx_fix2 = fix(rx_fix1/ state_num);      rx_2bit = rx_mod2;
rx_mod3 = mod(rx_fix2, state_num);       rx_fix3 = fix(rx_fix2/ state_num);      rx_3bit = rx_mod3;
rx_mod4 = mod(rx_fix3, state_num);       rx_fix4 = fix(rx_fix3/ state_num);      rx_4bit = rx_mod4;
rx_mod5 = mod(rx_fix4, state_num);       rx_fix5 = fix(rx_fix4/ state_num);      rx_5bit = rx_mod5;
rx_mod6 = mod(rx_fix5, state_num);       rx_fix6 = fix(rx_fix5/ state_num);      rx_6bit = rx_mod6;
rx_mod7 = mod(rx_fix6, state_num);       rx_fix7 = fix(rx_fix6/ state_num);      rx_7bit = rx_mod7;
rx_mod8 = mod(rx_fix7, state_num);       rx_fix8 = fix(rx_fix7/ state_num);      rx_8bit = rx_mod8;
rx_mod9 = mod(rx_fix8, state_num);       rx_fix9 = fix(rx_fix8/ state_num);      rx_9bit = rx_mod9;
rx_mod10 = mod(rx_fix9, state_num);      rx_fix10 = fix(rx_fix9/ state_num);     rx_10bit = rx_mod10;
rx_mod11 = mod(rx_fix10, state_num);      rx_fix11 = fix(rx_fix10/ state_num);   rx_11bit = rx_mod11;
rx_mod12 = mod(rx_fix11, state_num);      rx_fix12 = fix(rx_fix11/ state_num);   rx_12bit = rx_mod12;
rx_mod13 = mod(rx_fix12, state_num);      rx_fix13 = fix(rx_fix12/ state_num);   rx_13bit = rx_mod13;
rx_mod14 = mod(rx_fix13, state_num);      rx_fix14 = fix(rx_fix13/ state_num);   rx_14bit = rx_mod14;
rx_mod15 = mod(rx_fix14, state_num);      rx_fix15 = fix(rx_fix14/ state_num);   rx_15bit = rx_mod15;
rx_mod16 = mod(rx_fix15, state_num);      rx_fix16 = fix(rx_fix15/ state_num);   rx_16bit = rx_mod16;
			
disp(['MATLAB transmit GPIO number: ']);  
disp([num2str(rx_16bit), ' / ', num2str(rx_15bit), ' / ', num2str(rx_14bit), ' / ', num2str(rx_13bit)]);  
disp([num2str(rx_12bit), ' / ', num2str(rx_11bit), ' / ', num2str(rx_10bit), ' / ', num2str(rx_9bit)]);  
disp([num2str(rx_8bit), ' / ', num2str(rx_7bit), ' / ', num2str(rx_6bit), ' / ', num2str(rx_5bit)]);  
disp([num2str(rx_4bit), ' / ', num2str(rx_3bit), ' / ', num2str(rx_2bit), ' / ', num2str(rx_1bit)]);  

rx_all_dps = [rx_16bit, rx_15bit, rx_14bit, rx_13bit, ...
                rx_12bit, rx_11bit, rx_10bit, rx_9bit, ...
                rx_8bit, rx_7bit, rx_6bit, rx_5bit, ...
                rx_4bit, rx_3bit, rx_2bit, rx_1bit];
%%
for i = 1:size(txdata,1)
    for j = 1:size(txdata,2)
        write(device,txdata(i,j),'uint8');
    end
end

end

