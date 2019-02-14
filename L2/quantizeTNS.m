function index = quantizeTNS(coeffs)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
    p = length(coeffs);
    for u =1:p
        quant(u)= max(min((floor(coeffs(u) * 10)/10)+0.05, 0.75) , -0.75);
        symbol = round(10*(quant(u)+0.75)) ;
        bit_vec = bitget(symbol, 4:-1:1, 'uint8');
        index{u} = num2str(bit_vec);
    end

end

