function AACSeq3 = AACoder3( fNameIn, confset )
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
    
    if ( nargin == 1 )
        
       confset = ConfSets.Default;
        
    end
    
    %% Check for Huffman LUTs' presense in global workspace
    global AACONFIG
    register_config( confset )
    
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
    for channel = 'lr'
        
        %  - initialize    
        if ( AACONFIG.L3.ON_PREV_MISSING_POLICY == L3_PSYCHO_MissingPolicies.Defer )

            frameTprev1_C = AACSeq3( 2 ).(['ch' channel]).frameT;
            frameTprev2_C = AACSeq3( 1 ).(['ch' channel]).frameT;

            frame_i_start = 3;        
            deferred_frame_i = frame_i_start;
            frame_indices_sequence = [ ...
                frame_i_start ...
                1 : frame_i_start - 1 ...
                frame_i_start + 1 : NFRAMES ...
            ];

        else

            frameTprev1_C = zeros( FRAME_LENGTH, 1 );
            frameTprev2_C = zeros( FRAME_LENGTH, 1 );

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

            %% Per channel staff
            %   - save frame in time
            frameT_C = AACSeq3( frame_i ).(['ch' channel]).frameT;

            %   - compute SMR
            if ( ~deferred_execution )

                SMR_L = psycho( ...
                    frameT_C, ...
                    AACSeq3( frame_i ).frameType, ...
                    frameTprev1_C, frameTprev2_C ...
                );

            else

                % SMR_L retains its last value, thus 3rd frame's SMR ( for left
                % channel )

            end

            %   - quantize
            [ S, sfc, AACSeq3( frame_i ).(['ch' channel]).G ] = AACquantizer( ...
                AACSeq3( frame_i ).(['ch' channel]).frameF, ...
                AACSeq3( frame_i ).frameType, ...
                SMR_L ...
            );

            %   - Huffman encode
            if ( AACONFIG.L3.HUFFMAN_ENCODE )

                % encode mdcts
                [ AACSeq3( frame_i ).(['ch' channel]).stream, AACSeq3( frame_i ).(['ch' channel]).codebook ] = ...
                    encodeHuff( S, HUFFMAN_LUT );

                % encode sfcs
                if ( AACONFIG.L3.HUFFMAN_ENCODE_SFCS )

                    if ( AACSeq3( frame_i ).frameType == L1_SSC_Frametypes.EightShort )
                        
                        % Round first sfc for each subframe
                        for subframe_i = 1 : 8

                            % Cast sfc to unsigned 8bit integer
                            sfc( 1, subframe_i ) = cast( ...
                                floor( sfc( 1, subframe_i ) ), 'uint8' ...
                            );
                            
                        end
                        
                        % Huffman encode
                        if ( AACONFIG.L3.HUFFMAN_ENCODE_SFCS_COMBINED )

                            % Combine sfcs
                            AACSeq3( frame_i ).(['ch' channel]).sfc = ...
                                encodeHuff( sfc( : ), HUFFMAN_LUT, 12 );
                            
                        else

                            AACSeq3( frame_i ).(['ch' channel]).sfc = strings( 8, 1 );
                            for subframe_i = 1 : 8

                                % Get huffman bit-sequence
                                AACSeq3( frame_i ).(['ch' channel]).sfc( :, subframe_i ) = ...
                                    encodeHuff( sfc( :, subframe_i ), HUFFMAN_LUT, 12 );

                            end
                        
                        end

                    else

                        % Cast sfc to unsigned 8bit integer
                        sfc( 1 ) = cast( floor( sfc( 1 ) ), 'uint8' );
                        
                        % Get huffman bit-sequence
                        AACSeq3( frame_i ).(['ch' channel]).sfc = ...
                            encodeHuff( sfc, HUFFMAN_LUT, 12 );

                    end

                else

                    AACSeq3( frame_i ).(['ch' channel]).sfc = sfc;

                end

            else

                AACSeq3( frame_i ).(['ch' channel]).stream = S;
                AACSeq3( frame_i ).(['ch' channel]).sfc = sfc;

            end

            %   - slide Frames
            if ( ~deferred_execution )

                frameTprev2_C = frameTprev1_C;
                frameTprev1_C = frameT_C;

            end

            %% Deferred Execution ( if chosen )
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
        
    end
    
    % Inform about L3 codec's execution
    AACONFIG.L1.L3_ENCODER_RUNNING = false;
    
end

