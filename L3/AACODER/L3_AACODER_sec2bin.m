function binSeq = L3_AACODER_sec2bin( AACSeq3 )
%L3_AACODER_SEC2BIN Summary of this function goes here
%   Detailed explanation goes here

    global AACONFIG
    NFRAMES = length( AACSeq3 );

    % Window shape to bit
    windowType = strcmp( AACONFIG.L1.WINDOW_SHAPE, 'KBD' );
    
    % Initialize output struct
    binSeq = repmat( struct( ... 
            'frameType', '', 'winType', dec2bin( windowType, 1 ), ...
            'chl', struct( 'stream', '', 'codebook', 0, 'sfc', '', 'G', 0, 'TNScoeffs', zeros( 4, 1 ) ), ...
            'chr', struct( 'stream', '', 'codebook', 0, 'sfc', '', 'G', 0, 'TNScoeffs', zeros( 4, 1 ) ) ...
        ), NFRAMES, 1 ...
    );

    % Copy from original sequence
    for frame_i = 1 : NFRAMES
       
        binSeq( frame_i ).frameType = dec2bin( AACSeq3( frame_i ).frameType, 2 );
        
        for channel = 'lr'
           
            binSeq( frame_i ).(['ch' channel]).stream    = AACSeq3( frame_i ).(['ch' channel]).stream;
            binSeq( frame_i ).(['ch' channel]).codebook  = dec2bin( AACSeq3( frame_i ).(['ch' channel]).codebook, 4 );
            binSeq( frame_i ).(['ch' channel]).sfc       = AACSeq3( frame_i ).(['ch' channel]).sfc;
            binSeq( frame_i ).(['ch' channel]).G         = single( AACSeq3( frame_i ).(['ch' channel]).G );
            
            % TNS Coefficients are four ( 4 ) with 4 bits / coeff ( 4x4
            % char array ). The complete binary string will be 16 bits (
            % columnwise ).
            %
            % Revert back using:
            %   - revert for ESH: reshape( AACSeq3(27).chl.TNScoeffs(:)', [4 4 8] )
            %   - revert else   : reshape( AACSeq3(27).chl.TNScoeffs(:)', [4 4] )
            binSeq( frame_i ).(['ch' channel]).TNScoeffs = AACSeq3( frame_i ).(['ch' channel]).TNScoeffs( : )';
            
        end
        
    end
    
    %% Compressed Struct Data
    %   Per frame:
    %   - frameType:        bin( 2 )
    %   - winType:          bin( 1 )
    %
    %   Per frame channel:
    %   - ch{c}.stream:     bin( ~ )
    %   - ch{c}.codebook:   bin( 4 )
    %   - ch{c}.sfc:        bin( ~ )
    %   - ch{c}.G:          sinble( 32 )
    %   - ch{c}.TNScoeffs:  bin( 16 )

end

