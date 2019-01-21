function SMR = L3_PSYCHO_psycho_mono( frames, spreading_matrix, hann_window, std_table )
%L3_PSYCHO_PSYCHO_MONO Applies psychoaccoustic model to a signle frame or
%subframe with pre-processed previous frames.
% 
%   frames: the 3 consecutive frames [ current, previous, pre-previous ]
%   spreading_matrix: spreading function NbxNb matrix between all bands for
%   this type of frame
%   hann_window: the hanning window to apply to frame before processing
%   std_table: table from AAC Standard
% 
%   SMR: resulting Signal-to-Masking Ratio by applying the psycho-acoustic
%   model to this frame
%

    %% Constants
    FRAME_LENGTH = length( frames );
    NBANDS = length( spreading_matrix );

    %% Apply Hanning window to frames
    frames_windowed = frames .* repmat( hann_window, [1 3] );

    %% FFT for each frame
    frames_fft = fft( frames_windowed, FRAME_LENGTH, 1 );
    
    % Extract norm and angle ( for ( half + 1 ) fft coefficients )
    r = abs( frames_fft( 1 : FRAME_LENGTH / 2, : ) );
    f = angle( frames_fft( 1 : FRAME_LENGTH / 2, : ) );
    
    %% Compute prediction
    rpred = 2 * r( :, 2 ) - r( :, 3 );
    fpred = 2 * f( :, 2 ) - f( :, 3 );
    
    r = r( :, 1 );
    f = f( :, 1 );
    
    %% Predictability Measure
    % Predictability for higher part of spectrum is set constant for long
    % frames, equal to 0.4
    if ( NBANDS > 60 )
        
        c = [ sqrt( ...
            ( r( 1:6 ) .* cos( f( 1:6 ) ) - rpred( 1:6 ) .* cos( fpred( 1:6 ) ) ) .^ 2 + ...
            ( r( 1:6 ) .* sin( f( 1:6 ) ) - rpred( 1:6 ) .* sin( fpred( 1:6 ) ) ) .^ 2 ...
        ) ./ ( r( 1:6 ) + abs( rpred( 1:6 ) ) ); 0.4 * ones( FRAME_LENGTH / 2 - 6, 1 ) ];
        
    else
        
        c = sqrt( ...
            ( r .* cos( f ) - rpred .* cos( fpred ) ) .^ 2 + ...
            ( r .* sin( f ) - rpred .* sin( fpred ) ) .^ 2 ...
        ) ./ ( r + abs( rpred ) );
        
    end

    %% Band Energy & Weighted Predictability Measure
    e = zeros( NBANDS, 1 );
    cw = zeros( NBANDS, 1 );
    for b = 1 : NBANDS
        
        wlow = std_table( b, 2 ) + 1;
        whigh = std_table( b, 3 ) + 1;
        
        e( b ) = sumsqr( r( wlow : whigh ) );
        cw( b ) = sum( c( wlow : whigh ) .* r( wlow : whigh ) .^ 2 );
        
    end
    
    %% Combine Energy & Predictability with Spreading Function
    spreading_matrix_transpose = spreading_matrix';
    spreading_matrix_colsum( :, 1 ) = sum( spreading_matrix );
    
    ecb = spreading_matrix_transpose * e;
    ct = spreading_matrix_transpose * cw;
    
    % Normalize above
    cb = ct ./ ecb;
    en = ecb ./ spreading_matrix_colsum;
    
    %% Tonality Index ( for each band )
    % tb should be in range ( 0, 1 ) => cb < 0.499 => ecb( b ) > 2 * ct( b
    % ) for all b
    tb = -0.299 - 0.43 * log( cb );     % ln is 'log' in MATLAB
    
%     tb
    
    % Clip tb
%     tb = abs( tb );
%     tb( tb > 1 ) = 0.5;
%     tb( tb < 0 ) = 0.5;
% % 
%     if( max( tb ) >= 1 || min( tb ) <= 0 )
%         
%         plot( 0.5 * ecb - ct )
%         
%         tb
%         assert( false )
%         
%     end
    
    %% SNR
    % TMN( b ) = 18dB constant for all bands
    % NMT( b ) = 6dB constant for all bands
    SNR = 18 * tb + 6 * ( 1 - tb );
    
    % Convert DB -> Energy Ratio
    bc = 10 .^ ( -0.1 * SNR );
    
    %% Energy Threshold
    nb = en .* bc;
    
    %% Scalefactor Bands
    % For a more naive encoder, psychoacoustic model's bands are used also
    % as the quantizer bands and thus scalefactor bands are the same as
    % std_table' bands
    
    % Noise Level
    qthr_hat = ( eps() * 0.5 * FRAME_LENGTH ) * ( 10 .^ ( 0.1 * std_table( :, 6 ) ) );
    npart = max( nb, qthr_hat );
    
    %% Compute SMR
    SMR = e ./ npart;
     
end

