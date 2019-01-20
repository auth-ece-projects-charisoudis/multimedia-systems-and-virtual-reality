function frames = L1_FILTERBANK_MDCT_buffer( channel, WINDOW_LENGTH, OVERLAP_LENGTH  )
%L1_FILTERBANK_MDCT_buffer Frames extraction for multichannel signal
%   
%   channel: the audio samples. If multi-channel, then each channel is
%   processed separately and the resulting frames for each channel are then
%   combined to the outpout argument.
%   WINDOW_LENGTH: number of samples in each frame
%   OVERLAP_LENGTH:  number of elements for the overlap region
% 
%   frames: the extracted frames ( WINDOW_LENGTH x NFRAMES for each 
%   channel ).
% 

    %% Check if stereo given
    nchannels = size( channel, 2 );
    if ( nchannels > 1 )
        
        channel_1 = channel( :, 1 );
        
    else
        
        channel_1 = channel;
        
    end

    %% Buffer channel to frames
    frames_channel1 = buffer( ...
        [ ...
            zeros( OVERLAP_LENGTH, 1); ...
            channel_1; ...
            zeros( OVERLAP_LENGTH, 1) ...
        ], ...
        WINDOW_LENGTH, ...
        OVERLAP_LENGTH, ...
        'nodelay' ...
    );

    %% Repeat for all remaining channels
    if ( nchannels > 1 )

        frames( :, :, 1 ) = frames_channel1;
        for channel_i = 2:nchannels

            frames( :, :, channel_i ) = ...
                L1_FILTERBANK_MDCT_buffer( ...
                    channel( :, channel_i ), ...
                    WINDOW_LENGTH, ...
                    OVERLAP_LENGTH ...
                );

        end

    else

        frames = frames_channel1;

    end
    
end

