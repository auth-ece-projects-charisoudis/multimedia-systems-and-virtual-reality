function bits = L3_AACODER_sec2bits( seq, fNameAACoded )
%L3_AACODER_SEC2BYTES Summary of this function goes here
%   Detailed explanation goes here

    %% Constants
%     NFRAMES = length( seq );
%     
%     %% Calculate sum of bits
%     bits = 0;
%     for channel = 'lr'
% 
%         for frame_i = 1 : NFRAMES
% 
%             % Streams
%             bits = bits + length( seq( frame_i ).(['ch' channel]).stream );
% 
%             % SFCs        
%             if ( seq( frame_i ).frameType == L1_SSC_Frametypes.EightShort ) 
% 
%                 for subframe_i = 1 : 8
%                     
%                     bits = bits + length( seq( frame_i ).(['ch' channel]).sfc( subframe_i ) );
%                     
%                 end
% 
%             else
% 
%                 bits = bits + length( seq( frame_i ).(['ch' channel]).sfc );
% 
%             end
% 
%         end
% 
%     end

    %% Create compressed struct
    CompressedSeq = L3_AACODER_compress_sec( seq );
    
    %% Write struct to binary file
    
    save( fNameAACoded, 'CompressedSeq' );
    
    %% Read mat-file's filesize
    finfo = dir( fNameAACoded );
    bits = 8 * finfo.bytes;

end

