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
        
       confset = ConfSets.Marios; 
        
    end

    %% Get y for SNR calculation
    [ y, Fs ] = audioread( fNameIn );
    y = [ y; zeros( 1024 - rem( size( y, 1 ), 1024 ), 2 ) ];

    %% Start!
    clear global
    clearvars -except fNameIn fNameOut y Fs confset;
    clc
    demoaac2_tic = tic;
    
    %% Encoder
    aacoder2_tic = tic;
    AACSeq2 = AACoder2( fNameIn, confset );
    aacoder2_toc = toc( aacoder2_tic );
    
    %% Decoder
    iaacoder2_tic = tic;
    y_out = iAACoder2( AACSeq2, fNameOut );
    iaacoder2_toc = toc( iaacoder2_tic );
    
    %% Finished
    demoaac2_toc = toc( demoaac2_tic );
    
    % Write Codec's output to file
    if( nargout == 0 )
       
        % if file exists, tweak fNameOut by adding a Level_3 indicator
        if isfile( fNameOut )
           
            % Change filename
            [~, fName, fExt] = fileparts( fNameOut );
            fName = [fName '_L2'];
            
            % Re-compose fNameOut
            fNameOut = [fName fExt];
            
        end
        
        % Write file
        audiowrite( fNameOut, y_out, Fs );
        
    end

    % Compute SNR
    [ SNR, SNR_L, SNR_R ] = L1_AACODER_snr( y, y_out );
    
    % Print results
    fprintf([ ...
        'Level 2\n', ...
        '=======\n', ...
        'Coding: time elapsed is %0.5f seconds\n', ...
        'Decoding: time elapsed is %0.5f seconds\n', ...
        '\t-> total time: %0.5f seconds\n', ...
        'Channel 1 SNR: %0.4f dB\n', ...
        'Channel 2 SNR: %0.4f dB\n', ...
        '\t-> mean SNR: %0.4f seconds\n', ...
        ], aacoder2_toc, iaacoder2_toc, demoaac2_toc, SNR_L, SNR_R, SNR ...
    )

end
