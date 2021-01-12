function [ S, sfc, G ] = AACquantizer( frameF, frameType, SMR )
%AACQUANTIZER Quantizer Stage of AAC Encoder.
% 
%   Calculates auditity threshold and quantizes MDCT coefficients based on
%   the results of the psychocoustic model being applied to this frame.
% 
%   Scalefactors define quantizer quality ( and thus quantization noise )
%   in each of the quantizer bands ( same for our naive AAC codec with the
%   psychoacoustic bands ). Therefore, via sfcs we can move quantization
%   noise to bands with high auditity threshold and produce no audible
%   artiface, whereas in other bands with lower tb quantizer should be more
%   accurate to maintain SNR ( 'N' is the quantization noise ).
% 
%   frameF: MDCT coefficients ( 1024x1 for long frame or 128x8 for short
%   ones )
%   frameType: frame's type
%   SMR: Signal-to-Masking Ratio as outputed from psycho()
%   
%   S: quantized MDCT symbols ( 1024x1 for all frame types )
%   sfc: scalefactors for each band ( DPCM'ed )
%   G: global scalefactor gain ( sfc( 0 ) or a( 0 ) )
% 

    %% Constants
    NBANDS = length( SMR );
    
    %% Load Standard's Tables
    %  - B219a: for Long Windows
    %  - B219b: for Short Windows
    global B219a;
    global B219b;

    %% Check Frame Type
    if ( frameType == L1_SSC_Frametypes.EightShort )
       
        % Prepare output argument
        S = zeros( size( frameF ) );
        sfc = zeros( NBANDS - 1, 8 );
        G = zeros( 1, 8 );
        
        % Loop through all sub-frames
        for subframe_i = 1 : 8
            
            [ S( :, subframe_i ), sfc( :, subframe_i ), G( :, subframe_i ) ] = ...
                L3_AACQUANTIZER_quantizer_mono( ...
                    frameF( :, subframe_i ), ...
                    SMR( :, subframe_i ), ...
                    B219b ...
                );
            
        end
        
        % Linearize S, because output needs to be 1024x1
        S = S( : );
        
    else
        
        [ S, sfc, G ] = L3_AACQUANTIZER_quantizer_mono( ...
            frameF, SMR, B219a ...
        );
        
    end

end
