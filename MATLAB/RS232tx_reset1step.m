function [ ] = RS232tx_reset1step(device, rx, ASCIInum)
%% Setup
ASCII_space = ASCIInum.ASCII_space;
ASCII_plus = ASCIInum.ASCII_plus;
ASCII_semicolon = ASCIInum.ASCII_semicolon;
%%
txdata_org = 0;
txdata_org_ASCII = double(num2str( txdata_org ));
if size(txdata_org_ASCII,2) < 3
    txdata_org_ASCII = [ASCII_space*ones(length(txdata_org),1), txdata_org_ASCII]; 
end 

Plus_ASCII = ASCII_plus*ones(length(txdata_org),1);
semicolon_ASCII = ASCII_semicolon*ones(length(txdata_org),1);
txdata = [ Plus_ASCII , txdata_org_ASCII , semicolon_ASCII ];   
fprintf(['MATLAB transmit the reset 1 step signal~~~~~~~~~~~~~~~~~~~~~~~~~~~ \n']);  

for i = 1:size(txdata,1)
    for j = 1:size(txdata,2)
        write(device,txdata(i,j),'uint8');
    end
%     fprintf(['\n']);
end

end

