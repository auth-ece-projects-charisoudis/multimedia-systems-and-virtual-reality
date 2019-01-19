function SNR = demoAAC3( fNameIn, fNameOut )
%DEMOAAC2 Executes Level-3 AAC Codec and calculates SNR
%   
%   fNameIn: input wav's filename
%   fNameOut: output wav's filename
%   
%   SNR: codec's SNR
%   

    %% Get y for SNR calculation
    [ y, ~ ] = audioread( fNameIn );
    NSAMPLES_PAD_RIGHT = 1024 - rem( length( y ), 1024 );
    y = [ y; zeros( NSAMPLES_PAD_RIGHT, 2 ) ];
    
    %% Global Settings
    global LEVEL_3_ENCODER_RUNNING
    LEVEL_3_ENCODER_RUNNING = true;
    
    global LEVEL_3_ENCODER_HUFFMAN
    global LEVEL_3_ENCODER_HUFFMAN_CODE_SFCS
    LEVEL_3_ENCODER_HUFFMAN = true;
    LEVEL_3_ENCODER_HUFFMAN_CODE_SFCS = true;

    %% Start!
    clearvars -except fNameIn fNameOut y NSAMPLES_PAD_RIGHT;
    clc
    tic
    
    %% Encoder
    AACSeq3 = AACoder3( fNameIn );
    
    %% Decoder
    y_out = iAACoder3( AACSeq3, fNameOut );
    
    % Write Codec's output to file
    if( nargout == 0 )
       
        audiowrite( fNameOut, y_out( 1 : end - NSAMPLES_PAD_RIGHT, : ), 48000 );
        
    end
    
    %% Finished
    toc

    % Print SNR
    [ SNR, ~, ~ ] = L1_AACORDER_snr( y, y_out );

end
