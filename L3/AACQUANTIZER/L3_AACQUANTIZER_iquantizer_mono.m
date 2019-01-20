function frame = L3_AACQUANTIZER_iquantizer_mono( S, sfc, std_table )
%L3_AACQUANTIZER_IQUANTIZER_MONO De-Quantizes a single frame or sub-frame
%
%   S: quantized MDCT coefficients
%   sfc: scalefactors ( DPCM'ed )
%   std_table: AAC standard's tables
%
%   frameF: dequantized MDCT coefficients  
%
    
    %% Constants
    NBANDS = length( sfc );
    frame = zeros( length( S ), 1 );
    
    %% Reconstruct Scalefactors using Inverse DPCM
    a = cumsum( sfc );
    
    %% De-Quantize
    for b = 1 : NBANDS
        
        % Band Limits
        wlow = std_table( b, 2 ) + 1;
        whigh = std_table( b, 3 ) + 1;
    
        % Apply Q^(-1) Formula
        frame( wlow : whigh ) = ...
            ( L2_TNS_QUANTIZER_sgn( S( wlow : whigh ) ) .* abs( S( wlow : whigh ) ) .^ (4 / 3) ) ...
            * 2^( 0.25 * a( b ) ) ...
        ;

    end
end
