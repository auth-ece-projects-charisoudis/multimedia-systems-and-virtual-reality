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
%   frameType: frame's type
%   frameTprev1: previous frame ( time samples )
%   frameTprev2: pre-previous frame ( time samples )
% 
%   SMR: resulting Signal-to-Masking Ratio by applying the psycho-acoustic
%   model to this frame
% 

    %% Constants
    FRAME_LENGTH = length( frameT );
    global ON_PREV_MISSING_POLICY   
    
    %% Load Standard's Tables
    %  - B219a: for Long Windows
    %  - B219b: for Short Windows
    global B219a
    global B219b

    %% Compute Sreading Function Matrix ( once for each frame type )
    persistent spreading_matrix_short
    persistent spreading_matrix_long
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
    persistent hann_window_short
    persistent hann_window_long
    if ( frameType == L1_SSC_Frametypes.EightShort )
        
        if ( isempty( hann_window_short ) )
           
            hann_window_short = hann( 2 * FRAME_LENGTH / 8 );
            hann_window_short = hann_window_short( 1 : FRAME_LENGTH / 8 );
            
        end
        hann_window = hann_window_short;
        
    else
        
        if ( isempty( hann_window_long ) )
           
            hann_window_long = hann( 2 * FRAME_LENGTH );
            hann_window_long = hann_window_long( 1 : FRAME_LENGTH );
            
        end
        hann_window = hann_window_long;
        
    end
    
    %% Check Frame Type
    if ( frameType == L1_SSC_Frametypes.EightShort )
       
        % Prepare output argument
        SMR = zeros( length( spreading_matrix ), 8 );
        
        % Extract Sub-Frames ( for current )
        subframes = buffer( frameT( 449 : end - 448 ), 256, 128, 'nodelay');
        
        % Initial Assignment of previous frames
        switch( ON_PREV_MISSING_POLICY )
            
            case L3_PSYCHO_MissingPolicies.Defer
                % Defer computation of first 2 subframes until 3rd's SMR
                % has been computed. Then copy this result for the
                % preceding two subframes.
                SMR( :, 1:2 ) = NaN( length( B219b ), 2 );
                subframe_i_start = 3;
                
                frameTprev1 = subframes( :, 2 );
                frameTprev2 = subframes( :, 1 );
                
            case L3_PSYCHO_MissingPolicies.Zeros
                
                frameTprev1 = zeros( 256, 1 );
                frameTprev2 = zeros( 256, 1 );
                subframe_i_start = 1;
        	
            case L3_PSYCHO_MissingPolicies.SameAsFirst
                
                frameTprev1 = subframes( :, 1 );
                frameTprev2 = subframes( :, 1 );
                subframe_i_start = 1;
        
            case L3_PSYCHO_MissingPolicies.FromPreviousFrame
                
                subframes_previous = buffer( frameTprev1( end - 448 - 3 * 128 + 1 : end - 448 ), 256, 128, 'nodelay');
                
                frameTprev1 = subframes_previous( :, 2 );
                frameTprev2 = subframes_previous( :, 1 );
                subframe_i_start = 1;
                
        end
        
        % Loop through all sub-frames
        for subframe_i = subframe_i_start : 8
            
            % Get one new subframe
            frameT = subframes( :, subframe_i );
            
            % Compute SMR
            SMR( :, subframe_i ) = L3_PSYCHO_psycho_mono( ...
                [ frameT, frameTprev1, frameTprev2 ], ...
                spreading_matrix, hann_window, B219b ...
            );
        
            % Slide previous frames
            frameTprev2 = frameTprev1;
            frameTprev1 = frameT;
            
        end
        
        % Check if Defered execution has been selected
        if ( ON_PREV_MISSING_POLICY == L3_PSYCHO_MissingPolicies.Defer )
           
            SMR( :, 1 ) = SMR( :, 3 );
            SMR( :, 2 ) = SMR( :, 3 );
            
        end            
        
    else
        
        % Check if previous frames exist
        if ( L3_PSYCHO_MissingPolicies.Defer )
            % Defer computation of first 2 frames until 3rd's SMR has been
            % computed. Then copy this result for the first two
            
            
        elseif ( ~ any( frameTprev1 ~= 0 ) )
            % Both previous frames missing
                        
            switch( ON_PREV_MISSING_POLICY )
                
                case L3_PSYCHO_MissingPolicies.Defer
                    % Defer computation of first 2 frames until 3rd's SMR
                    % has been computed. Then copy this result for the
                    % preceding two frames.
                    SMR = NaN( length( B219a ), 1 );
                    return
            
                case L3_PSYCHO_MissingPolicies.SameAsFirst

                    frameTprev1 = frameT;
                    frameTprev2 = frameT;

                otherwise

                    frameTprev1 = zeros( size( frameT ) );
                    frameTprev2 = zeros( size( frameT ) );
                
            end
           
        elseif ( ~ any( frameTprev2 ~= 0 ) )
            % One previous frame missing
            
            switch( ON_PREV_MISSING_POLICY )
                
                case L3_PSYCHO_MissingPolicies.Defer
                    % Defer computation of first 2 frames until 3rd's SMR
                    % has been computed. Then copy this result for the
                    % preceding two frames.
                    SMR = NaN( length( B219a ), 1 );
                    return
            
                case L3_PSYCHO_MissingPolicies.SameAsFirst

                    frameTprev2 = frameTprev1;

                otherwise

                    frameTprev2 = zeros( size( frameTprev1 ) );
                
            end
            
        end
        
        % Compute SMR
        SMR = L3_PSYCHO_psycho_mono( ...
            [ frameT, frameTprev1, frameTprev2 ], ...
            spreading_matrix, hann_window, B219a ...
        );
        
    end

end

