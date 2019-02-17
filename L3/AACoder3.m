function AACSeq3 = AACoder3( fNameIn, confset )
%AACODER3 Level-3 AAC Encoder
%   
%   fNameIn: wav file's name ( on which the AAC Coder will be executed )
%   confset: execution configuration parameters as one of the pre-defined
%   configuration sets ( see ConfSets class )
% 
%   AACSeq3: Level-3 output struct containing info for each of the coder's
%   frames
% 

    % Configuration Set
    if ( nargin == 1 )
        
       confset = ConfSets.Default;
        
    end

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
    FRAME_LENGTH = 2 * length( AACSeq2( 1 ).chl.frameF );
    
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
        
        % Reset ESH previous time frames ( used in psycho_mono() )        
        frameTprev1S_C = zeros( 256, 1);
        frameTprev2S_C = zeros( 256, 1);

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
            
            %   - check if frame is EightShott
            is_esh = AACSeq3( frame_i ).frameType == L1_SSC_Frametypes.EightShort;

            %   - compute SMR
            if ( ~deferred_execution )                

                % NOTICE: on ESH frames, previous frames are the last two
                % sub-frames from the last ESH frame of the encoder
                if ( is_esh )
                    
                    SMR_C = psycho( ...
                        frameT_C, ...
                        AACSeq3( frame_i ).frameType, ...
                        frameTprev1S_C, frameTprev2S_C ...
                    );
                    
                else

                    SMR_C = psycho( ...
                        frameT_C, ...
                        AACSeq3( frame_i ).frameType, ...
                        frameTprev1_C, frameTprev2_C ...
                    );
                    
                end

                %   - slide Frames
                if ( is_esh )
                    
                    FRAME_LENGTH_S = FRAME_LENGTH / 8;
                    
                    fp1s_start = FRAME_LENGTH - FRAME_LENGTH_S - 447;
                    fp1s_end = FRAME_LENGTH - 448;
                    
                    fp2s_start = FRAME_LENGTH - 448 - FRAME_LENGTH_S - FRAME_LENGTH_S / 2 + 1;
                    fp2s_end = FRAME_LENGTH - 448 - FRAME_LENGTH_S / 2;
                    
                    frameTprev1S_C( :, 1 ) = frameT_C( fp1s_start : fp1s_end );
                    frameTprev2S_C( :, 1 ) = frameT_C( fp2s_start : fp2s_end );
                    
                else

                    frameTprev2_C = frameTprev1_C;
                    frameTprev1_C = frameT_C;

                end
                    
            else

                % SMR_C retains its last value, thus 3rd frame's SMR ( for 
                % left & right channel )

            end

            %   - quantize
            [ S, sfc, AACSeq3( frame_i ).(['ch' channel]).G ] = AACquantizer( ...
                AACSeq3( frame_i ).(['ch' channel]).frameF, ...
                AACSeq3( frame_i ).frameType, ...
                SMR_C ...
            );

            %   - Huffman encode
            if ( AACONFIG.L3.HUFFMAN_ENCODE )

                % encode mdcts
                [ AACSeq3( frame_i ).(['ch' channel]).stream, AACSeq3( frame_i ).(['ch' channel]).codebook ] = ...
                    encodeHuff( S, HUFFMAN_LUT );

                % encode sfcs
                if ( is_esh )
                    
                    AACSeq3( frame_i ).(['ch' channel]).sfc = strings( 8, 1 );
                    for subframe_i = 1 : 8

                        % Get huffman bit-sequence
                        AACSeq3( frame_i ).(['ch' channel]).sfc( subframe_i ) = ...
                            encodeHuff( sfc( :, subframe_i ), HUFFMAN_LUT, 12 );
                    end
                    
                else
                    
                    % Get huffman bit-sequence
                    AACSeq3( frame_i ).(['ch' channel]).sfc = ...
                            encodeHuff( sfc, HUFFMAN_LUT, 12 );
                    
                end

            else

                AACSeq3( frame_i ).(['ch' channel]).stream = S;
                AACSeq3( frame_i ).(['ch' channel]).sfc = sfc;

            end

            %% Deferred Execution ( if chosen )
            if ( AACONFIG.L3.ON_PREV_MISSING_POLICY == L3_PSYCHO_MissingPolicies.Defer )
                % On first loop's end, the 3rd frame has been processed and
                % thus, its SMR can be used for the deferred execution of the 2
                % preceding frames. 
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
