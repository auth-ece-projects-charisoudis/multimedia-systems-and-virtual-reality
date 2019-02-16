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
    tic
    
    %% Encoder
    AACSeq1 = AACoder1( fNameIn, confset );
    
    %% Decoder
    y_out = iAACoder1( AACSeq1, fNameOut );
    
    %% Finished
    toc
    
    % Write output file
    if ( nargout == 0 )
        
        audiowrite( fNameOut, y_out, 48000 )
        
    end

    % Print SNR
    [ SNR, ~, ~ ] = L1_AACODER_snr( y, y_out );

end