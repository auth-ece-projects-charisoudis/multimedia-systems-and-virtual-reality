function fBin = L3_AACODER_fwrite_bin( binSeq,fNameBin )
%L3_AACODER_FWRITE_BIN Summary of this function goes here
%   Detailed explanation goes here

    % Create file
    fBin = fopen( fNameBin, 'w' );
    
    % Begin writing process
    %   - each new frame is written in a new line
    for frame_i = 1 : length( binSeq )
       
        binSeq( frame_i ).frameType = dec2bin( AACSeq3( frame_i ).frameType, 2 );
        
        for channel = 'lr'
           
            binSeq( frame_i ).(['ch' channel]).stream    = AACSeq3( frame_i ).(['ch' channel]).stream;
            binSeq( frame_i ).(['ch' channel]).codebook  = dec2bin( AACSeq3( frame_i ).(['ch' channel]).codebook, 4 );
            binSeq( frame_i ).(['ch' channel]).sfc       = AACSeq3( frame_i ).(['ch' channel]).sfc;
            binSeq( frame_i ).(['ch' channel]).G         = single( AACSeq3( frame_i ).(['ch' channel]).G );
            
            % TNS Coefficients are four ( 4 ) with 4 bits / coeff ( 4x4
            % char array ). The complete binary string will be 16 bits (
            % columnwise ).
            binSeq( frame_i ).(['ch' channel]).TNScoeffs = AACSeq3( frame_i ).(['ch' channel]).TNScoeffs( : )';
            
        end
        
    end

end

