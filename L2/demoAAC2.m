function SNR = demoAAC2( fNameIn, fNameOut )
%DEMOAAC2 Executes Level-2 AAC Codec and calculates SNR
%   
%   fNameIn: input wav's filename
%   fNameOut: output wav's filename
%   
%   SNR: codec's SNR
%   

    %% Get y for SNR calculation
    [ y, ~ ] = audioread( fNameIn );
    y = [ y; zeros( 1024 - rem( size( y, 1 ), 1024 ), 2 ) ];

    %% Start!
    clear global
    clearvars -except fNameIn fNameOut y;
    clc
    tic
    
    %% Encoder
    AACSeq2 = AACoder2( fNameIn );
    
    %% Decoder
    y_out = iAACoder2( AACSeq2, fNameOut );
    
    %% Finished
    toc

    % Print SNR
    [ SNR, ~, ~ ] = L1_AACODER_snr( y, y_out );

end
