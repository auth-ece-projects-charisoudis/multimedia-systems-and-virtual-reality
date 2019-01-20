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
    
    % Extract norm and angle ( for half + first fft coefficients )
    r = abs( frames_fft( 2 : FRAME_LENGTH / 2 + 1, : ) );
    f = abs( frames_fft( 2 : FRAME_LENGTH / 2 + 1, : ) );
    clear frames_fft
    
    %% Compute prediction
    rpred = 2 * r( :, 2 ) - r( :, 3 );
    fpred = 2 * f( :, 2 ) - f( :, 3 );
    
    r = r( :, 1 );
    f = f( :, 1 );
    
    %% Predictability Measure
    c = sqrt( ...
        ( r .* cos( f ) - rpred .* cos( fpred ) ) .^ 2 + ...
        ( r .* sin( f ) - rpred .* sin( fpred ) ) .^ 2 ...
    ) ./ ( r + abs( rpred ) );

    %% Weighted Predictability Measure
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
    
    ecb = spreading_matrix_transpose * e;
    ct = spreading_matrix_transpose * cw;
    
    clear spreading_matrix_transpose;
    
    % Normalize above
    cb = ct ./ ecb;
    en = ecb ./ ( sum( spreading_matrix )' );
    
    %% Tonality Index ( for each band )
    tb = -0.299 - 0.43 * log( cb ); % ln is 'log' in MATLAB
    
    %% SNR
    % TMN( b ) = 6dB constant for all bands
    % NMT( b ) = 18dB constant for all bands
    SNR = 6 * tb + 18 * ( 1 - tb );
    
    % Convert DB -> Energy Ratio
    bc = 10 .^ ( -0.1 * SNR );
    
    %% Energy Threshold
    nb = en .* bc;
    
    %% Scalefactor Bands
    % For a more naive encoder, psychoacoustic model's bands are used also
    % as the quantizer bands and thus scalefactor bands are the same as
    % std_table' bands
    
    % Noise Level
    qthr_hat = ( eps() * 5 * FRAME_LENGTH ) .^ ( 0.1 * std_table( :, 6 ) );
    npart = max( nb, qthr_hat );
    
    %% Compute SMR
    SMR = e ./ npart;
     
end

