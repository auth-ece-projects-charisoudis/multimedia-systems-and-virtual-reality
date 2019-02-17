function [ SNR, bitrate, compression ] = demoAAC3( fNameIn, fNameOut, fNameAACoded, confset )
%DEMOAAC3 Executes Level-3 AAC Codec and calculates SNR
%   
%   fNameIn: input wav's filename
%   fNameOut: output wav's filename
%   confset: execution configuration parameters as one of the pre-defined
%   configuration sets ( see ConfSets class )
%   
%   SNR: codec's SNR
%   bitrate: codec's resulting datarate
%   compression: resulting datarate / original datarate
%

    % Set confset if none selected
    if ( nargin == 2 )
        
       confset = ConfSets.Marios; 
        
    end

    %% Get y for SNR calculation
    [ y, FS ] = audioread( fNameIn );
    NSAMPLES = length( y );

    %% Start!
    clear global
    clearvars -except fNameIn fNameOut fNameAACoded y NSAMPLES FS confset;
    clc
    demoaac3_tic = tic;
    
    %% Encoder
    aacoder3_tic = tic;
    AACSeq3 = AACoder3( fNameIn, confset );
    aacoder3_toc = toc( aacoder3_tic );
    
    %% Decoder
    iaacoder3_tic = tic;
    y_out = iAACoder3( AACSeq3, fNameOut );
    iaacoder3_toc = toc( iaacoder3_tic );
    
    %% Check result
%     S = load( 'level3.mat', 'y' );
%     y_del = S.y( 1:end - 1024, : );    % y_del has 1024 more samples/channel than y_out
%     
%     figure
%     plot( abs( y_out( :, 1 ) - y_del( :, 1 ) ) )
%     title( ['max = ' num2str( max( abs( y_out( :, 1 ) - y_del( :, 1 ) ) ) ) ] )
%     
%     figure
%     plot( abs( y_out( 1 : NSAMPLES, 1 ) - y( :, 1 ) ) )
%     title( ['max = ' num2str( max( abs( y_out( 1 : NSAMPLES, 1 ) - y( :, 1 ) ) ) ) ] )
    
    % Trim output back to original number of samples
    y_out = y_out( 1 : NSAMPLES, : );
    
    %% Finished
    demoaac3_toc = toc( demoaac3_tic );
    
    % Write Codec's output to file
    if( nargout == 0 || true )
       
        % if file exists, tweak fNameOut by adding a Level_3 indicator
        if isfile( fNameOut )
           
            % Change filename
            [~, fName, fExt] = fileparts( fNameOut );
            fName = [fName '_L3'];
            
            % Re-compose fNameOut
            fNameOut = [fName fExt];
            
        end
        
        % Write file
        audiowrite( fNameOut, y_out, FS );
        
    end

    %% Compute SNR
    snrOb = L1_AACODER_SnrCalculator( y, y_out );
    SNR = snrOb.mean;
    
    %% Compute bitrate & Compression
    used_Huffman = confset == ConfSets.Marios_Huffman || confset == ConfSets.Default_Huffman;
    if ( used_Huffman )
        
        % Compute bitrate
        % Original
        secs = NSAMPLES / FS;
        finfo = dir( fNameIn );
        total_bits_original = finfo.bytes * 8;
%         bitrate_original = total_bits_original / secs;

        % Reconstructed
        %   - 48000 samples / sec
        %   - x bits / sample
        total_bits = L3_AACODER_seq_size( AACSeq3, fNameAACoded );
        bitrate = total_bits / secs;

        % Compute compression
        compression = total_bits / total_bits_original;
        
        % Print results
        jf = java.text.DecimalFormat;
        fprintf([ ...
            'Level 3\n', ...
            '=======\n', ...
            'Coding: time elapsed is %0.5f seconds\n', ...
            'Decoding: time elapsed is %0.5f seconds\n', ...
            '\t-> total time: %0.5f seconds\n', ...
            'Uncompressed audio: %0.4f MB (%s bits)\n', ...
            'Compressed struct : %0.4f KB (%s bits)\n', ...
            '\t-> Compression ratio : %0.4f %% (x %0.4f)\n', ...
            'Channel 1 SNR: %0.4f dB\n', ...
            'Channel 2 SNR: %0.4f dB\n', ...
            '\t-> mean SNR: %0.4f dB\n', ...
            ], ...
            aacoder3_toc, iaacoder3_toc, demoaac3_toc, ...
            total_bits_original / 1024^2, jf.format( total_bits_original ), ...
            total_bits / 1024, jf.format( total_bits ), ...
            compression * 100, 1 / compression, ...
            snrOb.channelLeft, snrOb.channelRight, SNR ...
        )
        
    else
        
        bitrate = NaN;
        compression = NaN;
        
        % Print results
        fprintf([ ...
            'Level 3 (no Huffman)\n', ...
            '====================\n', ...
            'Coding: time elapsed is %0.5f seconds\n', ...
            'Decoding: time elapsed is %0.5f seconds\n', ...
            '\t-> total time: %0.5f seconds\n', ...
            'Channel 1 SNR: %0.4f dB\n', ...
            'Channel 2 SNR: %0.4f dB\n', ...
            '\t-> mean SNR: %0.4f dB\n', ...
            ], ...
            aacoder3_toc, iaacoder3_toc, demoaac3_toc, ...
            snrOb.channelLeft, snrOb.channelRight, SNR ...
        )
        
    end

end
