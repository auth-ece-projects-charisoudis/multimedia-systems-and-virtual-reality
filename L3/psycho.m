function SMR = psycho( frameT, frameType, frameTprev1, frameTprev2 )
%PSYCHO Applies psychoaccoustic model to this frame ( needs previous time
%frames for predicting the frequency coefficients.
% 
%   When applying prediction we donot care about previous frames's types
%   just their samples's values ( which will then be transformed with DFT
%   and used by the predictor ).
% 
%   LONG Frames:
%   If both previous frames are not available, then the current frame
%   should be given for the previous and pre-previous.
%   If only previous frame is available, then psycho model should be fed
%   with the previous frame two times. 
% 
%   SHORT Frames:
%   If any of the previous sub-frames is not available, then model should
%   be fed with the last respective samples of the previous frame ( even if
%   the previous frame is a long one, we virtually cut it and extract last
%   one or two sub-frames ).
% 
%   frameT: frame in time samples
        
        % Check if previous frames exist
        % ...
%   frameType: frame's type
%   frameTprev1: previous frame ( time samples )
%   frameTprev2: pre-previous frame ( time samples )
% 
%   SMR: resulting Signal-to-Masking Ratio by applying the psycho-acoustic
%   model to this frame
% 

    %% Constants
    FRAME_LENGTH = length( frameT );
    global AACONFIG
    
    %% Load Standard's Tables
    %  - B219a: for Long Windows
    %  - B219b: for Short Windows
    global B219a
    global B219b

    %% Compute Sreading Function Matrix ( once for each frame type )
    global spreading_matrix_short
    global spreading_matrix_long
    if ( frameType == L1_SSC_Frametypes.EightShort )
        
        if ( isempty( spreading_matrix_short ) )
           
            spreading_matrix_short = L3_PSYCHO_spreading( L1_SSC_Frametypes.EightShort );
            
        end
        spreading_matrix = spreading_matrix_short;
        
    else
        
        if ( isempty( spreading_matrix_long ) )
           
            spreading_matrix_long = L3_PSYCHO_spreading( L1_SSC_Frametypes.OnlyLong );
            
        end
        spreading_matrix = spreading_matrix_long;
        
    end
    
    %% Compute Hanning window ( once for each frame type )
    % Note: this is the left half of the hanning window
    global hann_window_short
    global hann_window_long
    if ( frameType == L1_SSC_Frametypes.EightShort )
        
        if ( isempty( hann_window_short ) )
           
            N = FRAME_LENGTH / 8;
            hann_window_short = ...
                0.5 - 0.5 * cos( pi * ( ( 0 : N-1 )' + 0.5 ) / N );
            
        end
        hann_window = hann_window_short;
        
    else
        
        if ( isempty( hann_window_long ) )
           
            N = FRAME_LENGTH;
            hann_window_long = ...
                0.5 - 0.5 * cos( pi * ( ( 0 : N-1 )' + 0.5 ) / N );
            
        end
        hann_window = hann_window_long;
        
    end
    
    %% Check Frame Type
    if ( frameType == L1_SSC_Frametypes.EightShort )
       
        % Prepare output argument
        SMR = zeros( length( spreading_matrix ), 8 );
        
        % Extract Sub-Frames ( for current )
        subframes = buffer( frameT( 449 : end - 448 ), 256, 128, 'nodelay' );
        subframe_i_start = 1;
        
        % Initial Assignment of previous frames if previous frames are
        % zeros
        if ( all( frameTprev1 == 0 ) )
            
            switch( AACONFIG.L3.ON_PREV_MISSING_POLICY )

                case L3_PSYCHO_MissingPolicies.Defer
                    % Defer computation of first 2 subframes until 3rd's SMR
                    % has been computed. Then copy this result for the
                    % preceding two subframes.
                    % ATTENTION: This strategy is used ONLY for the 1st ESH
                    % frame in the song. For the following ESH frames, the last
                    % two subframes of the previous ESH frame are used.
                    frameTprev1 = subframes( :, 2 );
                    frameTprev2 = subframes( :, 1 );
                    subframe_i_start = 3;

                case L3_PSYCHO_MissingPolicies.Zeros
                    % nothing to do...

                case L3_PSYCHO_MissingPolicies.SameAsFirst

                    frameTprev1 = subframes( :, 2 );
                    frameTprev2 = subframes( :, 1 );

            end
            
        end
        
        % Loop through all sub-frames
        for subframe_i = subframe_i_start : 8
            
            % Get one new subframe
            subframeT = subframes( :, subframe_i );
            
            % Compute SMR
            SMR( :, subframe_i ) = L3_PSYCHO_psycho_mono( ...
                [ subframeT, frameTprev1, frameTprev2 ], ...
                spreading_matrix, hann_window, B219b ...
            );
        
            % Slide previous frames
            frameTprev2 = frameTprev1;
            frameTprev1 = subframeT;
            
        end
        
        % Check if Defered execution has been selected and if yes, copy SMR
        % of 3rd subframe two preceeding subframes
        for subframe_i = 1 : subframe_i_start - 1
            
            SMR( :, subframe_i ) = SMR( :, subframe_i_start );

        end
        
    else
        
        % Compute SMR
        SMR = L3_PSYCHO_psycho_mono( ...
            [ frameT frameTprev1 frameTprev2 ], ...
            spreading_matrix, hann_window, B219a ...
        );
        
    end

end
