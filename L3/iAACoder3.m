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

    %% Global Config
    global AACONFIG
    register_config()
    
    %% Check for Huffman LUTs' presense in global workspace
    global HUFFMAN_LUT
    if ( AACONFIG.L3.HUFFMAN_ENCODE && isempty( HUFFMAN_LUT ) )
        
        HUFFMAN_LUT = loadLUT();
        
    end
    
    %% Constants
    NFRAMES = length( AACSeq3 );

    %% Dequantize MDCT Coefficients
    AACSeq2 = AACSeq3;
    for channel = 'lr'

        for frame_i = 1 : NFRAMES

            % Per Channel Operations
            %   - Huffman decode
            if ( AACONFIG.L3.HUFFMAN_ENCODE )

                % decode mdcts
                S = decodeHuff( ...
                    AACSeq3( frame_i ).(['ch' channel]).stream, ...
                    AACSeq3( frame_i ).(['ch' channel]).codebook, ...
                    HUFFMAN_LUT ...
                )';

                % decode sfcs
                if ( AACONFIG.L3.HUFFMAN_ENCODE_SFCS )

                    if ( AACSeq3( frame_i ).frameType == L1_SSC_Frametypes.EightShort )
                        
                        sfc = zeros( 41, 8 );
                        if ( AACONFIG.L3.HUFFMAN_ENCODE_SFCS_COMBINED )

                            % Split decoded sfcs
                            sfc = buffer( decodeHuff( ...
                                AACSeq3( frame_i ).(['ch' channel]).sfc, ...
                                12, HUFFMAN_LUT ...
                            ), 41 );
                            
                        else

                            for subframe_i = 1 : 8

                                sfc( :, subframe_i ) = decodeHuff( ...
                                    convertStringsToChars( ...
                                        AACSeq3( frame_i ).(['ch' channel]).sfc( subframe_i ) ...
                                    ), ...
                                    12, HUFFMAN_LUT ...
                                );

                            end
                        
                        end

                    else

                        sfc = reshape( decodeHuff( AACSeq3( frame_i ).(['ch' channel]).sfc, ...
                            12, HUFFMAN_LUT ...
                        ), [ 68, 1 ] );

                    end

                else

                    sfc = AACSeq3( frame_i ).(['ch' channel]).sfc;

                end

            else

                S = AACSeq3( frame_i ).(['ch' channel]).stream;
                sfc = AACSeq3( frame_i ).(['ch' channel]).sfc;

            end

            %   - dequantize
            AACSeq2( frame_i ).(['ch' channel]).frameF = iAACquantizer( ...
                S, sfc, AACSeq3( frame_i ).(['ch' channel]).G, AACSeq3( frame_i ).frameType ...
            );

        end
    
    end
    
    %% Level-2 Decoder
    x = iAACoder2( AACSeq2, fNameOut );
    
end

