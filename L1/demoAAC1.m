function SNR = demoAAC1( fNameIn, fNameOut )
%DEMOAAC1 Executes Level-1 AAC Codec and calculates SNR
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
    clearvars -except fNameIn fNameOut y;
    clc
    tic
    
    %% Encoder
    AACSeq1 = AACoder1( fNameIn );
    
    %% Decoder
    y_out = iAACoder1( AACSeq1, fNameOut );
    
    %% Finished
    toc

    % Print SNR
    [ SNR, ~, ~ ] = L1_AACORDER_snr( y, y_out );

end