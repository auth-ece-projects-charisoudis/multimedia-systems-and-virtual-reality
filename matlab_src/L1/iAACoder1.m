function x = iAACoder1( AACSeq1, fNameOut )
%IAACCODER1 Level-1 Inverse AAC Coder
%   
%   fNameOut: output wav file's name
%   AACSeq1: Level-1 output struct containing info for each of the coder's
%   frames
%   
%   x: if nargout, then the samples are not written to wav file but rather
%   they are returned to this variable
% 

    %% Constants
    NCHANNELS = 2;
    NFRAMES = size( AACSeq1, 1 );
    WINDOW_LENGTH = 2 * size( AACSeq1(1).chl.frameF, 1 );

    %% Inverse FilterBank for each frame ( multichannel )
    channel_frames_out_by_frame = zeros( WINDOW_LENGTH, NCHANNELS, NFRAMES );
    for frame_i = 1 : NFRAMES

        % Left Channel
        channel_frames_out_by_frame( :, 1, frame_i ) = ifilterbank( ...
            AACSeq1( frame_i ).chl.frameF, ...
            AACSeq1( frame_i ).frameType, ...
            AACSeq1( frame_i ).winType ...
        );
    
        % Right Channel
        channel_frames_out_by_frame( :, 2, frame_i ) = ifilterbank( ...
            AACSeq1( frame_i ).chr.frameF, ...
            AACSeq1( frame_i ).frameType, ...
            AACSeq1( frame_i ).winType ...
        );

    end
    
    channel_frames_out_by_channel = permute( channel_frames_out_by_frame, [1, 3, 2] );
    
    % Get outputs ( Using Overlapp-and-Add Technique )
    x( :, 1 ) = L1_FILTERBANK_MDCT_unbuffer( channel_frames_out_by_channel( :, :, 1 ) );
    x( :, 2 ) = L1_FILTERBANK_MDCT_unbuffer( channel_frames_out_by_channel( :, :, 2 ) );
    
    %% Write / return output
%     if ( nargout == 0 )
%         
%         % Write to output file
%         audiowrite( fNameOut, x, 48000 );
%         
%         % Clear output variable
%         clear x;
%         
%     end   

end

