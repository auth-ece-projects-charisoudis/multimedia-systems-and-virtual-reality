function [ SNR, bitrate, compression ] = demoAAC3( fNameIn, fNameOut )
%DEMOAAC2 Executes Level-3 AAC Codec and calculates SNR
%   
%   fNameIn: input wav's filename
%   fNameOut: output wav's filename
%   
%   SNR: codec's SNR
%   

    %% Get y for SNR calculation
    [ y, ~ ] = audioread( fNameIn );
    
    % Constants
    NSAMPLES = length( y );
    OVERLAP_LENGTH = 1024;
    NSAMPLES_PAD_RIGHT = OVERLAP_LENGTH - rem( NSAMPLES, OVERLAP_LENGTH );
    
    % Format y
    y = [ y; zeros( NSAMPLES_PAD_RIGHT, 2 ) ];
    
    %% Global Settings
    global LEVEL_3_ENCODER_RUNNING
    LEVEL_3_ENCODER_RUNNING = true;
    
    global LEVEL_3_ENCODER_HUFFMAN
    global LEVEL_3_ENCODER_HUFFMAN_CODE_SFCS
    LEVEL_3_ENCODER_HUFFMAN = true;
    LEVEL_3_ENCODER_HUFFMAN_CODE_SFCS = false;

    %% Start!
    clearvars -except fNameIn fNameOut y NSAMPLES;
    clc
    tic
    
    %% Encoder
    AACSeq3 = AACoder3( fNameIn );
    
    %% Decoder
    y_out = iAACoder3( AACSeq3, fNameOut );
    
    % Write Codec's output to file
    if( nargout == 0 )
       
        audiowrite( fNameOut, y_out( 1 : NSAMPLES, : ), 48000 );
        
    end
    
    %% Finished
    toc

    % Compute SNR
    snrOb = L1_AACODER_SnrCalculator( y, y_out );
    SNR = snrOb.mean;
    
    % Compute bitrate
    %   - 48000 samples / sec
    %   - x bits / sample
    bits_per_sample = 0;
    bitrate = bits_per_sample * 48000;
    
    % Compute compression
    finfo = dir( fNameIn );
    bitrate_original = ( finfo.bytes * 8 ) / ( NSAMPLES / 48000 );
    compression = bitrate / bitrate_original;

end
