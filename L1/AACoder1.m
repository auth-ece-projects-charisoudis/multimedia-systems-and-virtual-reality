function AACSeq1 = AACoder1( fNameIn )
%AACCODER1 Level-1 AAC Coder
%   
%   fNameIn: wav file's name ( on which the AAC Coder will be executed )
% 
%   AACSeq1: Level-1 output struct containing info for each of the coder's
%   frames
% 

    %% Constants
    WINDOW_LENGTH = 2048;
    OVERLAP_LENGTH = WINDOW_LENGTH / 2;

    WINDOW_SHAPE = 'SIN';

    %% Read wav file
    [y, ~] = audioread( fNameIn );
    y = [ y; zeros( OVERLAP_LENGTH - rem( size( y, 1 ), OVERLAP_LENGTH ), 2 ) ];

    %% Frames extraction
    % Split audio signal in channels
    channel_frames_by_channel = L1_FILTERBANK_MDCT_buffer( y, WINDOW_LENGTH, OVERLAP_LENGTH );
    NFRAMES = size( channel_frames_by_channel, 2 );
    
    % Initialize output struct
    AACSeq1 = repmat( struct( ... 
            'frameType', '', 'winType', WINDOW_SHAPE, ...
            'chl', struct( 'frameF', [] ), ...
            'chr', struct( 'frameF', [] ) ...
        ), NFRAMES, 1 ...
    );

    % Check if Level-3 Encoder is running: add frameT to struct as, it will
    % be used in the psychoacoustic modeling stage of the encoder.
    global LEVEL_3_ENCODER_RUNNING
    if ( ~isempty( LEVEL_3_ENCODER_RUNNING ) && LEVEL_3_ENCODER_RUNNING )
        
        for frame_i = 1:NFRAMES
           
            % Left Channel
            AACSeq1( frame_i ).chl.frameT = ...
                channel_frames_by_channel( :, frame_i, 1 );
            
            % Right Channel
            AACSeq1( frame_i ).chr.frameT = ...
                channel_frames_by_channel( :, frame_i, 2 );
            
        end
        
    end

    %% SSC: Find frame Type
    % first frame - only right half has non-zero values - is set arbitarily to
    % OnlyLong
    AACSeq1( 1 ).frameType = L1_SSC_Frametypes.OnlyLong;
    for frame_i = 2: NFRAMES - 1

        AACSeq1( frame_i ).frameType = SSC(... 
            channel_frames_by_channel( :, frame_i, : ), ...
            channel_frames_by_channel( :, frame_i + 1, : ), ...
            AACSeq1( frame_i - 1 ).frameType ...
        );

    end
    % last frame - only left half has non-zero values - is set based on
    % previous frame's type
    if (  AACSeq1( frame_i ).frameType == L1_SSC_Frametypes.EightShort )
        AACSeq1( NFRAMES ).frameType = L1_SSC_Frametypes.LongStop;
    else
        AACSeq1( NFRAMES ).frameType = L1_SSC_Frametypes.OnlyLong;
    end

    %% FilterBank: Time-to-Frequency Mapping for each frame using MDCT
    for frame_i = 1 : NFRAMES
        
        % Left Channel
        AACSeq1( frame_i ).chl.frameF = permute( filterbank( ...
            channel_frames_by_channel( :, frame_i, 1 ), ...
            AACSeq1( frame_i ).frameType, ...
            WINDOW_SHAPE ...
        ), [ 1, 3, 2 ] );

        % Right Channel
        AACSeq1( frame_i ).chr.frameF = permute( filterbank( ...
            channel_frames_by_channel( :, frame_i, 2 ), ...
            AACSeq1( frame_i ).frameType, ...
            WINDOW_SHAPE ...
        ), [ 1, 3, 2 ] );

    end
    
end

