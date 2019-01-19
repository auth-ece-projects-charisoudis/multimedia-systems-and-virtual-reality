function frame_mdct = L1_FILTERBANK_filterbank_mono( frame, WINDOW_LENGTH, frameType, winType )
%L1_FILTERBANK_FILTERBANK_MONO Filterbank for sigle channel frarmes
%   Time to Frequency Mapping using MDCT
% 
%   frameT: frame's time samples
%   frameType: frame's type ( one of L1_SSC_Frametypes.EightShort, 'OLS', 'LSS', 'LPS' )
%   winType: window type ( one of 'SIN', 'KBD' )
%
%   frameF: frequncy samples for this frame ( output of MDCT )
%

    %% Constants
    WINDOW_LENGTH_SHORT = WINDOW_LENGTH / 8;    % Eight-Short Sub-Frames
    MDCT_LENGTH = WINDOW_LENGTH / 2;
    MDCT_LENGTH_SHORT = WINDOW_LENGTH_SHORT / 2;
    
%     frame_mdct = zeros( MDCT_LENGTH, 1 );
%     frame_mdct_extended = [zeros( WINDOW_LENGTH_SHORT, 1 ); frame_mdct];

    %% ( Analysis ) Window + MDCT ( L + R )
    if ( frameType == L1_SSC_Frametypes.EightShort )
        
        % Initialize return array
        frame_mdct = zeros( MDCT_LENGTH / 8, 8 );
        
        % Extract sub-frames
        frame_subframes = L1_FILTERBANK_MDCT_buffer( ...
            frame( 449:WINDOW_LENGTH-448 ), ...
            WINDOW_LENGTH_SHORT, MDCT_LENGTH_SHORT ...
        );
    
        % Widnow + MDCT for each frame
        for subframe_i = 2 : size( frame_subframes, 2 ) - 1
            
            % Get sub-frames
            subframe = frame_subframes( :, subframe_i );
            
            % Window
            subframe_windowed = L1_FILTERBANK_WINDOW_window( L1_SSC_Frametypes.EightShort, WINDOW_LENGTH_SHORT, winType ) .*  subframe;
            
            % MDCT
            frame_mdct( :, subframe_i - 1 ) = L1_FILTERBANK_MDCT_mdct( subframe_windowed );
%             start = ( subframe_i - 1 ) * MDCT_LENGTH_SHORT + 1;
%             frame_mdct_extended( start:start + MDCT_LENGTH_SHORT - 1) = L1_FILTERBANK_MDCT_mdct( subframe_windowed );
            
        end
        
        % Convert output argument to 128-by-1-by-8
        frame_mdct = permute( frame_mdct, [ 1, 3, 2 ] );
        
        % Shrink frame_mdct_extended
%         frame_mdct = frame_mdct_extended( MDCT_LENGTH_SHORT + 1:end - MDCT_LENGTH_SHORT );
        
    else
        
        % Window
        frame_windowed = L1_FILTERBANK_WINDOW_window( frameType, WINDOW_LENGTH, winType ) .*  frame;

        % MDCT
        frame_mdct = L1_FILTERBANK_MDCT_mdct( frame_windowed );
        
    end    

end

