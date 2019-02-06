function [ SNR, bitrate, compression ] = demoAAC3( fNameIn, fNameOut )
%DEMOAAC3 Executes Level-3 AAC Codec and calculates SNR
%   
%   fNameIn: input wav's filename
%   fNameOut: output wav's filename
%   
%   SNR: codec's SNR
%   

    %% Get y for SNR calculation
    [ y, FS ] = audioread( fNameIn );
    NSAMPLES = length( y );

    %% Start!
    clear global
    clearvars -except fNameIn fNameOut y NSAMPLES FS;
    clc
    tic
    
    %% Encoder
    AACSeq3 = AACoder3( fNameIn );
    
    %% Decoder
    y_out = iAACoder3( AACSeq3, fNameOut );
    
    % Trim output back to original number of samples
    y_out = y_out( 1 : NSAMPLES, : );
    
    % Write Codec's output to file
    if( nargout == 0 )
       
        audiowrite( fNameOut, y_out, FS );
        
    end
    
    %% Finished
    toc

    %% Compute SNR
    snrOb = L1_AACODER_SnrCalculator( y, y_out );
    SNR = snrOb.mean;
    
    %% Compute bitrate
    % Original
    secs = NSAMPLES / FS;
    finfo = dir( fNameIn );
    bitrate_original = ( finfo.bytes * 8 ) / secs;
    
    % Reconstructed
    %   - 48000 samples / sec
    %   - x bits / sample
    total_bits = L3_AACODER_sec2bits( AACSeq3 );
    bitrate = total_bits / secs;
    
    %% Compute compression
    compression = bitrate / bitrate_original;

end
