function bits = L3_AACODER_sec2bits( seq )
%L3_AACODER_SEC2BYTES Summary of this function goes here
%   Detailed explanation goes here

    %% Constants
    NFRAMES = length( seq );
    
    %% Calculate sum of bits
    bits = 0;
    for frame_i = 1 : NFRAMES
        
        % Streams
        bits = bits + length( seq( frame_i ).chl.stream );
        bits = bits + length( seq( frame_i ).chr.stream );
        
        % SFCs
        bits = bits + 8;
        
    end

end

