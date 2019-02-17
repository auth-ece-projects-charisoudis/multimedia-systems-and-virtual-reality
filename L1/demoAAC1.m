function SNR = demoAAC1( fNameIn, fNameOut, confset )
%DEMOAAC1 Executes Level-1 AAC Codec and calculates SNR
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
        
       confset = ConfSets.Marios; 
        
    end
    
    %% Get y for SNR calculation
    [ y, ~ ] = audioread( fNameIn );
    y = [ y; zeros( 1024 - rem( size( y, 1 ), 1024 ), 2 ) ];

    %% Start!
    clear global
    clearvars -except fNameIn fNameOut y confset;
    clc
    demoaac1_tic = tic;
    
    %% Encoder
    aacoder1_tic = tic;
    AACSeq1 = AACoder1( fNameIn, confset );
    aacoder1_toc = toc( aacoder1_tic );
    
    %% Decoder
    iaacoder1_tic = tic;
    y_out = iAACoder1( AACSeq1, fNameOut );
    iaacoder1_toc = toc( iaacoder1_tic );
    
    %% Finished
    demoaac1_toc = toc( demoaac1_tic );
    
    % Write output file
    if ( nargout == 0 )
        
        audiowrite( fNameOut, y_out, 48000 )
        
    end

    % Compute SNR
    [ SNR, SNR_L, SNR_R ] = L1_AACODER_snr( y, y_out );
    
    % Print results
    fprintf([ ...
        'Level 1\n', ...
        '=======\n', ...
        'Coding: time elapsed is %0.5f seconds\n', ...
        'Decoding: time elapsed is %0.5f seconds\n', ...
        '\t-> total time: %0.5f seconds\n', ...
        'Channel 1 SNR: %0.4f dB\n', ...
        'Channel 2 SNR: %0.4f dB\n', ...
        '\t-> mean SNR: %0.4f seconds\n', ...
        ], aacoder1_toc, iaacoder1_toc, demoaac1_toc, SNR_L, SNR_R, SNR ...
    )

end