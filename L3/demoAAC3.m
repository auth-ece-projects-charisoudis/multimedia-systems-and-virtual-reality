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
        
       confset = ConfSets.Default; 
        
    end

    %% Get y for SNR calculation
    [ y, FS ] = audioread( fNameIn );
    NSAMPLES = length( y );

    %% Start!
    clear global
    clearvars -except fNameIn fNameOut fNameAACoded y NSAMPLES FS confset;
    clc
    tic
    
    %% Encoder
    AACSeq3 = AACoder3( fNameIn, confset );
    
    %% Decoder
    y_out = iAACoder3( AACSeq3, fNameOut );
    
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
    toc
    
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
    
    %% Compute bitrate
    % Original
    secs = NSAMPLES / FS;
    finfo = dir( fNameIn );
    bitrate_original = ( finfo.bytes * 8 ) / secs;
    
    % Reconstructed
    %   - 48000 samples / sec
    %   - x bits / sample
    total_bits = L3_AACODER_seq_size( AACSeq3, fNameAACoded );
    bitrate = total_bits / secs;
    
    %% Compute compression
    compression = bitrate / bitrate_original;

end
