function frame = L1_FILTERBANK_ifilterbank_mono( frame_mdct, WINDOW_LENGTH, frameType, winType )
%L1_FILTERBANK_IFILTERBANK_MONO Inverse Filterbank for sigle channel frarmes
%   Frequency back to Time Mapping using IMDCT
% 
%   frame_mdct: frequncy samples for this frame ( output of mono MDCT )
%   frameType: frame's type ( one of L1_SSC_Frametypes.EightShort, 'OLS', 'LSS', 'LPS' )
%   winType: window type ( one of 'SIN', 'KBD' )
%
%   frame: frame's time samples
%

    %% Constants
    WINDOW_LENGTH_SHORT = WINDOW_LENGTH / 8;    % Eight-Short Sub-Frames

    %% IMDCT + Un-Window ( Synthesis )
    if ( frameType == L1_SSC_Frametypes.EightShort )
        
        % Extract sub-mdcts
        frame_sub_mdcts = [ ...
            zeros( 128, 1 ) ...
            frame_mdct ...
            zeros( 128, 1 ) ...
        ];
    
        % Widnow + MDCT for each frame
        subframes = zeros( WINDOW_LENGTH_SHORT, 8 );
        for subframe_i = 1:10
            
            % Get sub-frames
            subframe_mdct = frame_sub_mdcts( :, subframe_i );
            
            % IMDCT
            subframe_imdct = L1_FILTERBANK_MDCT_imdct( subframe_mdct );
            
            % Un-Window
            subframes( :, subframe_i ) = L1_FILTERBANK_WINDOW_window( frameType, WINDOW_LENGTH_SHORT, winType ) .*  subframe_imdct;
            
        end
        
        % Unbuffer to get complete frame
        frame = L1_FILTERBANK_MDCT_unbuffer( subframes );
        frame = [zeros(448,1); frame; zeros(448,1)];
        
    else
        
        % IMDCT
        frame_imdct = L1_FILTERBANK_MDCT_imdct( frame_mdct );
        
        % Un-Window
        frame = L1_FILTERBANK_WINDOW_window( frameType, WINDOW_LENGTH, winType ) .*  frame_imdct;
        
    end    

end

