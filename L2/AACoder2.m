function AACSeq2 = AACoder2( fNameIn )
%AACODER2 Level-2 AAC Enoder
%   
%   fNameIn: wav file's name ( on which the AAC Coder will be executed )
% 
%   AACSeq2: Level-2 output struct containing info for each of the coder's
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
    
    %% Level-1 Encoder
    AACSeq1 = AACoder1( fNameIn );
    
    %% Level-2 Encoder
    % Get number of frames
    NFRAMES = size( AACSeq1, 1 );
    
    % Initialize output struct
    AACSeq2 = AACSeq1;

    % Apply TNS
    for frame_i = 1 : NFRAMES

        % Left Channel
        [AACSeq2( frame_i ).chl.frameF, AACSeq2( frame_i ).chl.TNScoeffs] = TNS( ...
            AACSeq2( frame_i ).chl.frameF, ...
            AACSeq2( frame_i ).frameType ...
        );

        % Right Channel
        [AACSeq2( frame_i ).chr.frameF, AACSeq2( frame_i ).chr.TNScoeffs] = TNS( ...
            AACSeq2( frame_i ).chr.frameF, ...
            AACSeq2( frame_i ).frameType ...
        );

    end
    
end

