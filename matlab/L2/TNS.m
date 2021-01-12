function [ frameFout, TNScoeffs ] = TNS( frameFin, frameType )
%TNS Applies Temporal Noise Shaping to each frame's MDCT coefficients
%   
%   frameFin: input MDCT coefficients
%   frameType: type of the given frame ( one of 'ESH','OLS','LSS','LPS' )
%   
%   frameFout: converted MDCT coefficients using TNS
%   TNScoeffs: quantized ( 4 bit ) TNS coefficients ( 4 coeefs / frame )
%   

%     TNScoeffs = zeros( 32, 1 );
%     frameFout = frameFin;
    
    %% Load Standard's Tables
    %  - B219a: for Long Windows
    %  - B219b: for Short Windows
    global B219a;
    global B219b;
    
    %% Per Frame TNS
    switch frameType
        
        case L1_SSC_Frametypes.EightShort
            
            % Get input frame's dimensions
            frameFin_size = size( frameFin );
            
            % Init output arguments
            frameFout = zeros( frameFin_size );
            TNScoeffs = strings( 4, frameFin_size( 2 ) );
            
            % Apply TNS to each sub-MDCT
            for sub_frame_i = 1 : frameFin_size( 2 )
               
                [ frameFout( :, sub_frame_i ), TNScoeffs( :, sub_frame_i ) ] ...
                    = L2_TNS_tns_mono( frameFin( :, sub_frame_i ), B219b );
                
            end
            
        otherwise
            
            % All long-typed frames
            [ frameFout, TNScoeffs ] = L2_TNS_tns_mono( frameFin, B219a );
            
    end
    
end            
