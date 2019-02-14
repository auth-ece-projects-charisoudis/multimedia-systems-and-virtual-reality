function CompressedSeq = L3_AACODER_compress_sec( AACSeq3 )
%L3_AACODER_SEC2AAC_SEC Summary of this function goes here
%   Detailed explanation goes here

    % Initialize output struct
    CompressedSeq = repmat( struct( ... 
            'frameType', '', 'winType', AACONFIG.L1.WINDOW_SHAPE, ...
            'chl', struct( 'stream', '', 'codebook', 0, 'sfc', '', 'G', 0, 'TNScoeffs', zeros( 4, 1 ) ), ...
            'chl', struct( 'stream', '', 'codebook', 0, 'sfc', '', 'G', 0, 'TNScoeffs', zeros( 4, 1 ) ) ...
        ), NFRAMES, 1 ...
    );

    % Copy from original sequence
    for frame_i = 1 : length( AACSeq3 )
       
        CompressedSeq( frame_i ).frameType = L1_SSC_Frametypes.getShortCode( AACSeq3( frame_i ).frameType );
        CompressedSeq( frame_i ).winType = AACSeq3( frame_i ).winType;
        
        for channel = 'lr'
           
            CompressedSeq( frame_i ).(['ch' channel]).stream    = AACSeq3( frame_i ).(['ch' channel]).stream;
            CompressedSeq( frame_i ).(['ch' channel]).codebook  = AACSeq3( frame_i ).(['ch' channel]).codebook;
            CompressedSeq( frame_i ).(['ch' channel]).sfc       = AACSeq3( frame_i ).(['ch' channel]).sfc;
            CompressedSeq( frame_i ).(['ch' channel]).G         = AACSeq3( frame_i ).(['ch' channel]).G;
            CompressedSeq( frame_i ).(['ch' channel]).TNScoeffs = AACSeq3( frame_i ).(['ch' channel]).TNScoeffs;
            
        end
        
    end
        

end

