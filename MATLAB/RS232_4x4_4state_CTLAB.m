%% ========================================================================
% CTLAB 7GHz RIS Contorler
% Bluetooth version.
% RIS : 2bits switch ( 01/10 for 2 phases)
% Baudrate : 115200
%==========================================================================
close all; clear; clc;

%% camera 
cam = webcam(1)
preview(cam);

%% initial parameter
state_num = 4;   % 單一 element 的狀態數量
DPS_num = 16;    % element 的數量
DPS_maxnum = 16; % 想調控 element 的數量
allstate_num = state_num ^ DPS_num; % 所有可能性的總數量

%% ASCII-code of some characters 
stack_data=[];
ASCIInum.ASCII_space = 32;      % 當傳送SNR時，用來補齊傳送資料長度 (如 " 99","  1")
ASCIInum.ASCII_plus = 43;       % 傳送一串控制訊號 / SNR 時，在資料最前端加上 "+"，讓 FPGA 知道要開始接收資料
ASCIInum.ASCII_minus = 45;      % 當 MATLAB 傳送初始化訊號時，會傳送 "element全0" 以及 "SNR=-99" 的訊號，其中以minus代表負號
ASCIInum.ASCII_semicolon = 59;  % 當 MATLAB 傳送的值是 "SNR"時，會以":"作為結尾來辨識
ASCIInum.ASCII_at = 64;         % 當 MATLAB 傳送的值是 "element控制狀態"時，會以"@"作為結尾來辨識

% 總結 :
% 初始化 : 傳送 全 0 狀態，以及 SNR = -99
% ([ Plus_ASCII, txdata_org_ASCII , at_ASCII ]; )

%%%%% Connect to FPGA with RS232
% device = serialport('COM6',115200,'Timeout',0.2)
device = bluetooth("CTL4",1,"Timeout",1)
%%%%% Initial
txdata_org = 0; 
GPIO_org = 0;
GPIO_temp = 0;
GPIO_idx = 0;
% GPIO_idx = randi([2^15,4^16],1); % codebook的index
GPIO_idxcode = zeros(1, state_num);
GPIO_B2D = [];
for i = 1:DPS_maxnum
        GPIO_B2D = [GPIO_B2D, state_num^(i-1)];
end

%%
[txdata] = RS232initial(device, txdata_org, ASCIInum, state_num);
while true
        [rx, rx_idxcode] = RS232rx(device, state_num);  % RS232 Rx  
        if isempty(rx)
                [txdata] = RS232initial(device, txdata_org, ASCIInum, state_num);
        else
                break;
        end
end
%%
fprintf(['\n']);
disp(['Transmitted N-th State: ', num2str(GPIO_idx)]);
wait_time = 0.01;
S21_stack=[];
while true   
        GPIO_need = GpioIndex2Codebook(GPIO_idx, state_num);
        %% RS232        
        % Tx: GPIO選擇
        GPIO_org = GPIO_B2D * GPIO_need;
        [GPIO_temp, GPIO_org, GPIO_idxcode] = RS232tx_GPIO(device, rx, ...
                        GPIO_temp, GPIO_org, ASCIInum, state_num); % RS232 Tx: GPIO選擇
        while true
                [rx, rx_idxcode] = RS232rx(device, state_num);  % RS232 Rx                  
                if  isempty(rx)
                        disp('Re-Transmit!!!!!!!!!!!!!!!!!');
                        RS232tx_reset1step(device, rx, ASCIInum); % RS232 Tx: reset 1 step signal
                        [GPIO_temp, GPIO_org, GPIO_idxcode] = RS232tx_GPIO(device, rx, ...
                                    GPIO_temp, GPIO_org, ASCIInum, state_num); % RS232 Tx: GPIO選擇
                else
                        GPIO_test = GPIO_idxcode;
                        rx_test = rx_idxcode;
                        if  ~isequal(sum(GPIO_test-rx_test),0)
                                disp('Re-Transmit!!!!!!!!!!!!!!!!!');
                                disp('Re-Transmit!!!!!!!!!!!!!!!!!');
                                disp('Re-Transmit!!!!!!!!!!!!!!!!!');
                                RS232tx_reset1step(device, rx, ASCIInum); % RS232 Tx: reset 1 step signal
                                [GPIO_temp, GPIO_org, GPIO_idxcode] = RS232tx_GPIO(device, rx, ...
                                            GPIO_temp, GPIO_org, ASCIInum, state_num); % RS232 Tx: GPIO選擇
                        else
                                break;
                        end                        
                end
        end              
        % Tx: reset 1 step signal
        RS232tx_reset1step(device, rx, ASCIInum); % RS232 Tx: reset 1 step signal
        %
        pause(wait_time);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if GPIO_idx >= allstate_num
                disp('The END!!!!!!!!!!!!!!!!!');
                break;
        else
                GPIO_idx = GPIO_idx+1;
                fprintf(['\n']);
                disp(['Transmitted N-th State: ', num2str(GPIO_idx)]);
        end        
end


