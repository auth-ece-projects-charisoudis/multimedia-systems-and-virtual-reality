function size = L3_AACODER_seq_size( seq, fNameAACoded )
%L3_AACODER_SEC_SIZE Writes Coder's Struct to a binary file. Then counts
%filesize and converts it to bits;
%
%   seq: Encoder's output struct
%   fNameAACoded: the name of the binary file
%
%   bits: binary file's filesize in bits
%

    %% Create compressed binary struct
    binSeq = L3_AACODER_sec2bin( seq );
    
    %% Write struct to binary file
    L3_AACODER_fwrite_bin( binSeq, fNameAACoded );
    
    %% Read binary-file's filesize
    finfo = dir( fNameAACoded );
    size = 8 * finfo.bytes;

end

