function SNR = demoAAC2( fNameIn, fNameOut, confset )
%DEMOAAC2 Executes Level-2 AAC Codec and calculates SNR
%   
%   fNameIn: input wav's filename
%   fNameOut: output wav's filename
%   confset: execution configuration parameters as one of the pre-defined
%   configuration sets ( see ConfSets class )
%   
%   SNR: codec's SNR
%

    % Set confset if none selected
    if ( nargin == 2 )
        
       confset = ConfSets.Default; 
        
    end

    %% Get y for SNR calculation
    [ y, ~ ] = audioread( fNameIn );
    y = [ y; zeros( 1024 - rem( size( y, 1 ), 1024 ), 2 ) ];

    %% Start!
    clear global
    clearvars -except fNameIn fNameOut y confset;
    clc
    tic
    
    %% Encoder
    AACSeq2 = AACoder2( fNameIn, confset );
    
    %% Decoder
    y_out = iAACoder2( AACSeq2, fNameOut );
    
    %% Finished
    toc

    % Print SNR
    [ SNR, ~, ~ ] = L1_AACODER_snr( y, y_out );

end
