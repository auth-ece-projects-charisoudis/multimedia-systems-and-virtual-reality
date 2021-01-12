function frameT = ifilterbank( frameF, frameType, winType )
%IFILTERBANK Inverse Filterbank Step 
%   Frequency back to Time Mapping using IMDCT
% 
%   frameF: frequncy samples for this frame ( output of MDCT )
%   frameType: frame's type ( one of 'ESH', 'OLS', 'LSS', 'LPS' )
%   winType: window type ( one of 'SIN', 'KBD' )
%
%   frameT: frame's time samples ( for both channels - 2048x2 )
%

    is_short = frameType == L1_SSC_Frametypes.EightShort;

    %% Constants
    if ( is_short )
        
        [ MDCT_LENGTH, ~, NCHANNELS ] = size( frameF );
        
        % Because we weep the full frame length
        MDCT_LENGTH = MDCT_LENGTH * 8;
        
    else
        
        [ MDCT_LENGTH, NCHANNELS ] = size( frameF );
        
    end
    WINDOW_LENGTH = MDCT_LENGTH * 2;
    
    %% Per-Channel Inverse FilterBank
    frameT = zeros( WINDOW_LENGTH, NCHANNELS );
    for channel_i = 1:NCHANNELS
        
        if ( is_short )
            frameF_loop = frameF( :, :, channel_i );
        else
            frameF_loop = frameF( :, channel_i );
        end
        
        frameT( :, channel_i ) = L1_FILTERBANK_ifilterbank_mono( ...
            frameF_loop, WINDOW_LENGTH, ...
            frameType, winType ...
        );
        
    end

end
