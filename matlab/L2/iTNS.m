function frameFout = iTNS( frameFin, frameType, TNScoeffs )
%TNS Applies Inverse Temporal Noise Shaping
%   
%   frameFin: input MDCT TNS'ed coefficients
%   frameType: type of the given frame ( one of 'ESH','OLS','LSS','LPS' )
%   TNScoeffs: quantized ( 4 bit ) TNS coefficients ( 4 coeefs / frame )
%   
%   frameFout: original MDCT coefficients
%   

%     frameFout = frameFin;

    %% Per Frame Inverse TNS
    switch frameType
        
        case L1_SSC_Frametypes.EightShort
            
            % Get input frame's dimensions
            frameFin_size = size( frameFin );
            
            % Init output arguments
            frameFout = zeros( frameFin_size );
            
            % Apply TNS to each sub-MDCT
            for sub_frame_i = 1 : frameFin_size( 2 )
               
                frameFout( :, sub_frame_i ) = ...
                    L2_TNS_itns_mono( ...
                        frameFin( :, sub_frame_i ), ...
                        char( TNScoeffs( :, sub_frame_i ) )...
                    );
                
            end
            
        otherwise
            
            % All long-type frames
            frameFout = L2_TNS_itns_mono( frameFin, TNScoeffs );
            
    end
    
end
