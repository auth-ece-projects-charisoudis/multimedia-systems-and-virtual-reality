function frameFB = L3_AACQUANTIZER_dequantize( Sb,ab )
%L3_AACQUANTIZER_DEQUANTIZE Dequantize MDCT coeffs that belong to frequency
%band B.
%   
%   Sb: quantized MDCT coeffs in band B ( symbols )
%   ab: sfc coefficieng in band B
%   
%   frameFB: MDCT coeffs in band B
% 
    
    frameFB = L2_TNS_QUANTIZER_sgn( Sb ) .* ( ...
        abs( Sb ) .^ (4 / 3) * 2^( 0.25 * ab ) ...
    );
    
end
