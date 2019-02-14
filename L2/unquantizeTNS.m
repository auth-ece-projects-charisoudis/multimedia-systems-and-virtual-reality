function a = unquantizeTNS(index)
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here
    
    symbol = bin2dec(index);
    a = -0.75 + symbol*0.1;
    a = a(:);

end

