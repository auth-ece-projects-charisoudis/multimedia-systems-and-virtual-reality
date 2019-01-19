clear;
clc;

[y_orig, ~] = audioread( 'sample.wav' );
y = [ y_orig; zeros( 670, 2 ) ];

%% Constants
WINDOW_LENGTH = 2048;
OVERLAP_LENGTH = WINDOW_LENGTH / 2;

[NSAMPLES, NCHANNELS] = size( y );

tic

WINDOW_SHAPE = 'SIN';

%% Frames extraction
% Split audio signal in channels
channel_frames_by_channel = L1_FILTERBANK_MDCT_buffer(  y, WINDOW_LENGTH, OVERLAP_LENGTH );
channel_frames_by_frame = permute( channel_frames_by_channel, [1, 3, 2] );

% Split audio singal in frames ( 50% overlap - prepend & append half windows with zeros )
% left_channel_frames = channel_frames_by_channel( :, :, 1 );
% right_channel_frames = channel_frames_by_channel( :, :, 2 );

NFRAMES = size( channel_frames_by_frame, 3 );

%% SSC: Find frame Type
frame_types = zeros( NFRAMES, 1 );
% first frame - only right half has non-zero values - is set arbitarily to
% OnlyLong
frame_types( 1 ) = L1_SSC_Frametypes.OnlyLong;
for frame_i = 2: NFRAMES - 1
   
   frame_types( frame_i ) = SSC(... 
        channel_frames_by_frame( :, :, frame_i ), ...
        channel_frames_by_frame( :, :, frame_i + 1 ), ...
        frame_types( frame_i - 1 ) ...
    );

    frame_types( frame_i ) = L1_SSC_Frametypes.OnlyLong;
    
end
% last frame - only left half has non-zero values - is set based on
% previous frame's type
if (  frame_types( frame_i ) == L1_SSC_Frametypes.EightShort )
    frame_types( NFRAMES ) = L1_SSC_Frametypes.LongStop;
else
    frame_types( NFRAMES ) = L1_SSC_Frametypes.OnlyLong;
end

%% FilterBank: Time-to-Frequency Mapping for each frame using MDCT
channel_frame_mdcts_by_frame = zeros( WINDOW_LENGTH/2, NCHANNELS, NFRAMES );
for frame_i = 1 : NFRAMES
    
    channel_frame_mdcts_by_frame( :, :, frame_i ) = filterbank( ...
        channel_frames_by_frame( :, :, frame_i ), ...
        frame_types( frame_i ), ...
        WINDOW_SHAPE ...
    );
    
end

%% TNS
channel_frame_mdcts_tns_by_frame = zeros( WINDOW_LENGTH/2, NCHANNELS, NFRAMES );
channel_frame_mdcts_tns_coeffs_by_frame = zeros( 32, NCHANNELS, NFRAMES );
for frame_i = 1 : NFRAMES
    
    % Left Channel
    [channel_frame_mdcts_tns_by_frame( :, 1, frame_i ), channel_frame_mdcts_tns_coeffs_by_frame( :, 1, frame_i )] = TNS( ...
        channel_frame_mdcts_by_frame( :, 1, frame_i ), ...
        frame_types( frame_i ) ...
    );

    % Right Channel
    [channel_frame_mdcts_tns_by_frame( :, 2, frame_i ), channel_frame_mdcts_tns_coeffs_by_frame( :, 2, frame_i )] = TNS( ...
        channel_frame_mdcts_by_frame( :, 2, frame_i ), ...
        frame_types( frame_i ) ...
    );
    
end

%% Inverse TNS
channel_frame_mdcts_out_by_frame = zeros( WINDOW_LENGTH/2, NCHANNELS, NFRAMES );
for frame_i = 1 : NFRAMES
    
    % Left Channel
    channel_frame_mdcts_out_by_frame( :, 1, frame_i ) = iTNS( ...
        channel_frame_mdcts_tns_by_frame( :, 1, frame_i ), ...
        frame_types( frame_i ), ...
        channel_frame_mdcts_tns_coeffs_by_frame( :, 1, frame_i ) ...
    );

    % Right Channel
    channel_frame_mdcts_out_by_frame( :, 2, frame_i ) = iTNS( ...
        channel_frame_mdcts_tns_by_frame( :, 2, frame_i ), ...
        frame_types( frame_i ), ...
        channel_frame_mdcts_tns_coeffs_by_frame( :, 2, frame_i ) ...
    );
    
end

%% Inverse FilterBank for each frame ( multichannel )
channel_frames_out_by_frame = zeros( WINDOW_LENGTH, NCHANNELS, NFRAMES );
for frame_i = 1 : NFRAMES
    
    channel_frames_out_by_frame( :, :, frame_i ) = ifilterbank( ...
        channel_frame_mdcts_out_by_frame( :, :, frame_i ), ...
        frame_types( frame_i ), ...
        WINDOW_SHAPE ...
    );
    
end

%% FilterBank Evaluation
channel_frames_out_by_channel = permute( channel_frames_out_by_frame, [1, 3, 2] );

% Get outputs ( Using Overlapp-and-Add Technique )
left_channel_out  = L1_FILTERBANK_MDCT_unbuffer( channel_frames_out_by_channel( :, :, 1 ) );
right_channel_out = L1_FILTERBANK_MDCT_unbuffer( channel_frames_out_by_channel( :, :, 2 ) );

y_out = [left_channel_out right_channel_out];

% Trigger clock
toc


%% Errors
[ SNR, SNR_L, SNR_R ] = L1_AACORDER_snr( y, y_out );
