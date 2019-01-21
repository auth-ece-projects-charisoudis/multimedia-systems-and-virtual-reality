function AACSeq3 = AACoder3( fNameIn )
%AACODER3 Level-3 AAC Encoder
%   
%   fNameIn: wav file's name ( on which the AAC Coder will be executed )
% 
%   AACSeq3: Level-3 output struct containing info for each of the coder's
%   frames
% 

    %% Check for tables' presence in global workspace
    global B219a
    global B219b
    if ( isempty( B219a ) || isempty( B219b ) )
        
        S = load('TableB219.mat', 'B219a', 'B219b' );
        
        B219a = S.B219a;
        B219b = S.B219b;
        
    end
    
    %% Check for Huffman LUTs' presense in global workspace
    global AACONFIG
    register_config()
    
    % Inform about L3 codec's execution
    AACONFIG.L1.L3_ENCODER_RUNNING = true;
    
    global HUFFMAN_LUT
    if ( AACONFIG.L3.HUFFMAN_ENCODE && isempty( HUFFMAN_LUT ) )
        
        HUFFMAN_LUT = loadLUT();
        
    end

    %% Level-2 Encoder
    AACSeq2 = AACoder2( fNameIn );
    
    %% Quantize MDCT Coefficients based on Psychoaccoustics
    % Get number of frames
    NFRAMES = size( AACSeq2, 1 );
    FRAME_LENGTH = length( AACSeq2( 1 ).chl.frameF );
    
    % Initialize output struct
    AACSeq3 = AACSeq2;
    
    % Psychoaccoustic Model
    %  - initialize    
    if ( AACONFIG.L3.ON_PREV_MISSING_POLICY == L3_PSYCHO_MissingPolicies.Defer )
        
        frameTprev1_L = AACSeq3( 2 ).chl.frameT;
        frameTprev2_L = AACSeq3( 1 ).chl.frameT;
        frameTprev1_R = AACSeq3( 2 ).chr.frameT;
        frameTprev2_R = AACSeq3( 1 ).chr.frameT;
        
        frame_i_start = 3;        
        deferred_frame_i = frame_i_start;
        frame_indices_sequence = [ ...
            frame_i_start ...
            1 : frame_i_start - 1 ...
            frame_i_start + 1 : NFRAMES ...
        ];
        
    else
        
        frameTprev1_L = zeros( FRAME_LENGTH, 1 );
        frameTprev2_L = zeros( FRAME_LENGTH, 1 );
        frameTprev1_R = zeros( FRAME_LENGTH, 1 );
        frameTprev2_R = zeros( FRAME_LENGTH, 1 );
        
        frame_indices_sequence = 1 : NFRAMES;
        
    end
    
    %  - run
    deferred_execution = false;
    for frame_i = frame_indices_sequence
        
        if ( AACONFIG.DEBUG )
            
            sprintf( ...
                '\t- frame: #%03d ( %s )', ...
                frame_i, ...
                L1_SSC_Frametypes.getShortCode( AACSeq3( frame_i ).frameType ) ...
            )
            
        end
        
        %% Left Channel
        %   - save frame in time
        frameT_L = AACSeq3( frame_i ).chl.frameT;
        
        %   - compute SMR
        if ( ~deferred_execution )
            
            SMR_L = psycho( ...
                frameT_L, ...
                AACSeq3( frame_i ).frameType, ...
                frameTprev1_L, frameTprev2_L ...
            );
        
        else
            
            % SMR_L retains its last value, thus 3rd frame's SMR ( for left
            % channel )
        
        end
    
        %   - quantize
        [ S, sfc, AACSeq3( frame_i ).chl.G ] = AACquantizer( ...
            AACSeq3( frame_i ).chl.frameF, ...
            AACSeq3( frame_i ).frameType, ...
            SMR_L ...
        );
    
        %   - Huffman encode
        if ( AACONFIG.L3.HUFFMAN_ENCODE )
            
            % encode mdcts
            [ AACSeq3( frame_i ).chl.stream, AACSeq3( frame_i ).chl.codebook ] = ...
                encodeHuff( S, HUFFMAN_LUT );
       
            % encode sfcs
            if ( AACONFIG.L3.HUFFMAN_ENCODE_SFCS )
            
                if ( AACSeq3( frame_i ).frameType == L1_SSC_Frametypes.EightShort )
                
                    AACSeq3( frame_i ).chl.sfc = zeros( size( sfc ) );
                    for subframe_i = 1 : 8

                        AACSeq3( frame_i ).chl.sfc( :, subframe_i ) = ...
                            encodeHuff( sfc( :, subframe_i ), HUFFMAN_LUT, 12 );

                    end

                else

                    AACSeq3( frame_i ).chl.sfc = encodeHuff( sfc, HUFFMAN_LUT, 12 );

                end
                
            else
                
                AACSeq3( frame_i ).chl.sfc = sfc;
                
            end
            
        else
           
            AACSeq3( frame_i ).chl.stream = S;
            AACSeq3( frame_i ).chl.sfc = sfc;
            
        end
    
        %   - slide Frames
        if ( ~deferred_execution )
            
            frameTprev2_L = frameTprev1_L;
            frameTprev1_L = frameT_L;
            
        end
        
    
        %% Right Channel
        %   - save frame in time
        frameT_R = AACSeq3( frame_i ).chr.frameT;
        
        %   - compute SMR
        if ( ~deferred_execution )
            
            SMR_R = psycho( ...
                frameT_R, ...
                AACSeq3( frame_i ).frameType, ...
                frameTprev1_R, frameTprev2_R ...
            );
        
        else
            
            % SMR_R retains its last value, thus 3rd frame's SMR ( for
            % right channel )
        
        end
    
        %   - quantize
        [ S, sfc, AACSeq3( frame_i ).chr.G ] = AACquantizer( ...
            AACSeq3( frame_i ).chr.frameF, ...
            AACSeq3( frame_i ).frameType, ...
            SMR_R ...
        );
    
        %   - Huffman encode
        if ( AACONFIG.L3.HUFFMAN_ENCODE )
            
            % encode mdcts
            [ AACSeq3( frame_i ).chr.stream, AACSeq3( frame_i ).chr.codebook ] = ...
                encodeHuff( S, HUFFMAN_LUT );
       
            % encode sfcs
            if ( AACONFIG.L3.HUFFMAN_ENCODE_SFCS )
            
                if ( AACSeq3( frame_i ).frameType == L1_SSC_Frametypes.EightShort )
                
                    AACSeq3( frame_i ).chr.sfc = zeros( size( sfc ) );
                    for subframe_i = 1 : 8

                        AACSeq3( frame_i ).chr.sfc( :, subframe_i ) = ...
                            encodeHuff( sfc( :, subframe_i ), HUFFMAN_LUT, 12 );

                    end

                else

                    AACSeq3( frame_i ).chr.sfc = encodeHuff( sfc, HUFFMAN_LUT, 12 );

                end
                
            else
                
                AACSeq3( frame_i ).chr.sfc = sfc;
                
            end
            
        else
           
            AACSeq3( frame_i ).chr.stream = S;
            AACSeq3( frame_i ).chr.sfc = sfc;
            
        end
        
        %   - slide Frames
        if ( ~deferred_execution )
            
            frameTprev2_R = frameTprev1_R;
            frameTprev1_R = frameT_R;
            
        end
        
        
        %% Deferred Execution
        if ( AACONFIG.L3.ON_PREV_MISSING_POLICY == L3_PSYCHO_MissingPolicies.Defer )
            % On first loop's end, the 3rd frame has been processed and
            % thus its SMR can be used for the deferred execution of the 2
            % preceeding frames. 
            % So, at this point, we activate the
            % deferred_execution flag and set the frame index variable to
            % the last deferred frame, gradually decrementing its value
            % until 1st deferred frame has been processed.
            % After that, we deactivate this flag and let the coder proceed
            % with all unprocessed frames
            
            deferred_frame_i = deferred_frame_i - 1;
            deferred_execution = deferred_frame_i > 0;
            
        end
        
        
    end
    
    % Inform about L3 codec's execution
    AACONFIG.L1.L3_ENCODER_RUNNING = false;
    
end

