function frameF = iAACquantizer( S, sfc, G, frameType )
%IAACQUANTIZER De-Quantizer Stage for Level-3 AAC Decoder.
%
%   S: quantized MDCT coefficients
%   sfc: scalefactors ( DPCM'ed )
%   G: global gain ( sfc(0) )
%   frameType: frame's type
%
%   frameF: dequantized MDCT coefficients  
%
  
    %% Constants
    WINDOW_LENGTH = length( S );
    
    %% Load Standard's Tables
    %  - B219a: for Long Windows
    %  - B219b: for Short Windows
    global B219a;
    global B219b;

    %% Check Frame Type
    if ( frameType == L1_SSC_Frametypes.EightShort )
       
        % Prepare output argument
        WINDOW_LENGTH = WINDOW_LENGTH / 8;
        frameF = zeros( WINDOW_LENGTH, 1 );
        
        % Split S into sub-frames
        S = buffer( S, WINDOW_LENGTH );
        
        % Loop through all sub-frames
        for subframe_i = 1 : 8
            
            frameF( :, subframe_i ) = L3_AACQUANTIZER_iquantizer_mono( ...
                S( :, subframe_i ), ...
                sfc( :, subframe_i ), ...
                G(subframe_i), ...
                B219b ...
            );
            
        end
        
    else
        
        frameF = L3_AACQUANTIZER_iquantizer_mono( S, sfc, G, B219a );
        
    end

end
