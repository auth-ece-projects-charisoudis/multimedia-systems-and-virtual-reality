function x = iAACoder3( AACSeq3, fNameOut )
%IAACCODER3 Level-3 AAC Decoder
%   
%   fNameOut: output wav file's name
%   AACSeq3: Level-3 encoder's output struct containing info for each of
%   the coder's frames
%   
%   x: if nargout, then the samples are not written to wav file but rather
%   they are returned to this variable
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
    global LEVEL_3_ENCODER_HUFFMAN
    global LEVEL_3_ENCODER_HUFFMAN_CODE_SFCS
    global HUFFMAN_LUT
    if ( LEVEL_3_ENCODER_HUFFMAN && isempty( HUFFMAN_LUT ) )
        
        HUFFMAN_LUT = loadLUT();
        
    end
    
    %% Constants
    NFRAMES = length( AACSeq3 );

    %% Dequantize MDCT Coefficients
    AACSeq2 = AACSeq3;
    for frame_i = 1 : NFRAMES
       
        % Left Channel        
        %   - Huffman decode
        if ( LEVEL_3_ENCODER_HUFFMAN )

            % decode mdcts
            S = decodeHuff( ...
                AACSeq3( frame_i ).chl.stream, ...
                AACSeq3( frame_i ).chl.codebook, ...
                HUFFMAN_LUT ...
            )';
        
            % decode sfcs
            if ( LEVEL_3_ENCODER_HUFFMAN_CODE_SFCS )
                
                sfc = decodeHuff( AACSeq3( frame_i ).chl.sfc, 12, HUFFMAN_LUT );
                
            else
                
                sfc = AACSeq3( frame_i ).chl.sfc;
                
            end
            
        else
           
            S = AACSeq3( frame_i ).chl.stream;
            sfc = AACSeq3( frame_i ).chl.sfc;
            
        end
        
        %   - dequantize
        AACSeq2( frame_i ).chl.frameF = iAACquantizer( ...
            S, sfc, AACSeq3( frame_i ).chl.G, AACSeq3( frame_i ).frameType ...
        );

        % Right Channel
        %   - Huffman decode
        if ( LEVEL_3_ENCODER_HUFFMAN )
            
            % decode mdcts
            S = decodeHuff( ...
                AACSeq3( frame_i ).chr.stream, ...
                AACSeq3( frame_i ).chr.codebook, ...
                HUFFMAN_LUT ...
            );
        
            % decode sfcs
            if ( LEVEL_3_ENCODER_HUFFMAN_CODE_SFCS )
                
                sfc = decodeHuff( AACSeq3( frame_i ).chr.sfc, 12, HUFFMAN_LUT );
                
            else
                
                sfc = AACSeq3( frame_i ).chr.sfc;
                
            end
            
        else
           
            S = AACSeq3( frame_i ).chr.stream;
            sfc = AACSeq3( frame_i ).chr.sfc;
            
        end
        
        %   - dequantize
        AACSeq2( frame_i ).chr.frameF = iAACquantizer( ...
            S, sfc, AACSeq3( frame_i ).chr.G, AACSeq3( frame_i ).frameType ...
        );

    end
    
    %% Level-2 Decoder
    x = iAACoder2( AACSeq2, fNameOut );
    
end

