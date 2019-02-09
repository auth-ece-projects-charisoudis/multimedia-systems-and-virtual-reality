function y = L1_FILTERBANK_MDCT_unbuffer( frames )
%L1_FILTERBANK_MDCT_UNBUFFER Restores initial vector of samples applying
%Overlap-and-Add technique in successive frames.
%   
%   frames: all frames ( either all the sub-frames of and ESH frame or all
%   the frames of decoder )
% 
%   y: resulting vector of samples
% 

    %% Constants
    [FRAME_LENGTH, NFRAMES] = size( frames );
    OVERLAP_LENGTH = FRAME_LENGTH / 2;

    % Length of final vector ( plus the length of a frame )
    NSAMPLES = OVERLAP_LENGTH * ( NFRAMES + 2 );

    %% Overlap-and-Add Loop ( Using original technique - described in M.Bosi's book )
    y = zeros( NSAMPLES, 1 );
    for frame_i = 1 : NFRAMES

        % get write position
        y_pos_start = ( frame_i - 1 ) * OVERLAP_LENGTH + 1;
        y_pos_stop = y_pos_start + FRAME_LENGTH - 1;

        % get new frame
        frame = frames( :, frame_i );

        % add 1st half and copy 2nd half
        y( y_pos_start : y_pos_stop ) = y( y_pos_start : y_pos_stop )  + frame;

    end

    %% Extract Useful Samples
    y = y( OVERLAP_LENGTH + 1:end - FRAME_LENGTH );

end
