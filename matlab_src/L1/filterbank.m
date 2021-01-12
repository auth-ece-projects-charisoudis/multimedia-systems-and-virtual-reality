function frameF = filterbank( frameT, frameType, winType )
%filterbank Filterbank Step 
%   Time to Frequency Mapping using MDCT
% 
%   frameT: frame's time samples
%   frameType: frame's type ( one of 'ESH', 'OLS', 'LSS', 'LPS' )
%   winType: window type ( one of 'SIN', 'KBD' )
%
%   frameF: frequncy samples for this frame ( output of MDCT )
%

    %% Constants
    [WINDOW_LENGTH, NCHANNELS] = size( frameT );
    if ( frameType == L1_SSC_Frametypes.EightShort )
        
        FRAME_NSUBFRAMES = 8;
        MDCT_LENGTH = WINDOW_LENGTH / 8 / 2;
%         WINDOW_LENGTH = WINDOW_LENGTH * 8;  % Because we weep the full frame length
        
    else
        
        FRAME_NSUBFRAMES = 1;
        MDCT_LENGTH = WINDOW_LENGTH / 2;
        
    end
    
    %% Per-Channel FilterBank
    % Init output argument
    frameF = zeros( MDCT_LENGTH, NCHANNELS, FRAME_NSUBFRAMES );
    
    % Get MDCT
    for channel_i = 1:NCHANNELS
        
        frameF( :, channel_i, : ) = L1_FILTERBANK_filterbank_mono( ...
            frameT( :, channel_i ), WINDOW_LENGTH, ...
            frameType, winType ...
        );
        
    end

end
