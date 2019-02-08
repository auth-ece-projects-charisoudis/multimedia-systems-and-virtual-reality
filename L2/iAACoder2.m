function x = iAACoder2( AACSeq2, fNameOut )
%IAACCODER2 Level-2 AAC Decoder
%   
%   fNameOut: output wav file's name
%   AACSeq2: Level-2 output struct containing info for each of the coder's
%   frames
%   
%   x: if nargout, then the samples are not written to wav file but rather
%   they are returned to this variable
% 

    %% Constants
    NFRAMES = size( AACSeq2, 1 );
    
    %% Inverse TNS
    AACSeq1 = AACSeq2;
    for channel = 'lr'
        
        for frame_i = 1 : NFRAMES

            % Per Channel
            AACSeq1( frame_i ).(['ch' channel]).frameF = iTNS( ...
                AACSeq2( frame_i ).(['ch' channel]).frameF, ...
                AACSeq2( frame_i ).frameType, ...
                AACSeq2( frame_i ).(['ch' channel]).TNScoeffs ...
            );

        end
    
    end
    
    %% Inverse Level-1 Decoder
    x = iAACoder1( AACSeq1, fNameOut );
    
end

