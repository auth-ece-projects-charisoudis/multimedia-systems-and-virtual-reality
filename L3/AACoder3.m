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
    global LEVEL_3_ENCODER_RUNNING
    if ( isempty( LEVEL_3_ENCODER_RUNNING ) )
        
        LEVEL_3_ENCODER_RUNNING = true;
        
    end
    
    global LEVEL_3_ENCODER_HUFFMAN
    global LEVEL_3_ENCODER_HUFFMAN_CODE_SFCS
    if ( isempty( LEVEL_3_ENCODER_HUFFMAN ) )
        
        LEVEL_3_ENCODER_HUFFMAN = false;
        LEVEL_3_ENCODER_HUFFMAN_CODE_SFCS = false;
        
    end
    
    global HUFFMAN_LUT
    if ( LEVEL_3_ENCODER_HUFFMAN && isempty( HUFFMAN_LUT ) )
        
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
    frameTprev1_L = zeros( FRAME_LENGTH, 1 );
    frameTprev2_L = zeros( FRAME_LENGTH, 1 );
    frameTprev1_R = zeros( FRAME_LENGTH, 1 );
    frameTprev2_R = zeros( FRAME_LENGTH, 1 );
    for frame_i = 1 : NFRAMES
        
        % Left Channel
        %   - save frame in time
        frameT_L = AACSeq3( frame_i ).chl.frameT;
        
        %   - compute SMR
        SMR_L = psycho( ...
            frameT_L, ...
            AACSeq3( frame_i ).frameType, ...
            frameTprev1_L, frameTprev2_L ...
        );
    
        %   - quantize
        [ S, sfc, AACSeq3( frame_i ).chl.G ] = AACquantizer( ...
            AACSeq3( frame_i ).chl.frameF, ...
            AACSeq3( frame_i ).frameType, ...
            SMR_L ...
        );
    
        %   - Huffman encode
        if ( LEVEL_3_ENCODER_HUFFMAN )
            
            % encode mdcts
            [ AACSeq3( frame_i ).chl.stream, AACSeq3( frame_i ).chl.codebook ] = ...
                encodeHuff( S, HUFFMAN_LUT );
       
            % encode sfcs
            if ( LEVEL_3_ENCODER_HUFFMAN_CODE_SFCS )
            
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
        frameTprev2_L = frameTprev1_L;
        frameTprev1_L = frameT_L;
    
        % Right Channel
        %   - save frame in time
        frameT_R = AACSeq3( frame_i ).chr.frameT;
        
        %   - compute SMR
        SMR_R = psycho( ...
            frameT_R, ...
            AACSeq3( frame_i ).frameType, ...
            frameTprev1_R, frameTprev2_R ...
        );
    
        %   - quantize
        [ S, sfc, AACSeq3( frame_i ).chr.G ] = AACquantizer( ...
            AACSeq3( frame_i ).chr.frameF, ...
            AACSeq3( frame_i ).frameType, ...
            SMR_R ...
        );
    
        %   - Huffman encode
        if ( LEVEL_3_ENCODER_HUFFMAN )
            
            % encode mdcts
            [ AACSeq3( frame_i ).chr.stream, AACSeq3( frame_i ).chr.codebook ] = ...
                encodeHuff( S, HUFFMAN_LUT );
       
            % encode sfcs
            if ( LEVEL_3_ENCODER_HUFFMAN_CODE_SFCS )
            
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
        frameTprev2_R = frameTprev1_R;
        frameTprev1_R = frameT_R;
        
    end
    
end

