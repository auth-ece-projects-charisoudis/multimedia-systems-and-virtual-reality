function Sb = L3_AACQUANTIZER_quantize( frameFB, ab )
%L3_AACQUANTIZER_QUANTIZE Quantize MDCT coeffs that belong to frequency
%band B.
%   
%   frameFB: MDCT coeffs in band B
%   ab: sfc coefficieng in band B
%   
%   Sb: quantized MDCT coeffs in band B ( symbols )
% 

    persistent MagicNumber
    MagicNumber = 0.4054;

    Sb = L2_TNS_QUANTIZER_sgn( frameFB ) .* floor( ...
        ( 2^( -0.25 * ab ) * abs( frameFB ) ) .^ 0.75 + MagicNumber );
    
end
