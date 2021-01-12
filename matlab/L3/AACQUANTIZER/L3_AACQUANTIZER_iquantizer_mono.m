function frameF = L3_AACQUANTIZER_iquantizer_mono( S, sfc, G, std_table )
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
    frameF = zeros( length( S ), 1 );
    
    %% Reconstruct Scalefactors using Inverse DPCM
    a = cumsum( [G; sfc] );
    
    %% De-Quantize
    for b = 1 : NBANDS
        
        % Band Limits
        wlow = std_table( b, 2 ) + 1;
        whigh = std_table( b, 3 ) + 1;
    
        % Apply Q^(-1) Formula
        frameF( wlow : whigh ) = L3_AACQUANTIZER_dequantize( ...
            S( wlow : whigh ), a( b ) ...
        );

    end
    
end
