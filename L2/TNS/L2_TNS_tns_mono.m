function [ frameFout, TNScoeffs ] = L2_TNS_tns_mono( frameFin, std_table )
%L2_TNS_MONO TNS for a single frame
%   
%   frameFin: input MDCT coefficients
%   std_table: table from AAC Standard
%   
%   frameFout: converted MDCT coefficients using TNS
%   TNScoeffs: quantized ( 4 bit ) TNS coefficients ( 4 coeefs / frame )
% 
    
%     frameFout = frameFin;
%     TNScoeffs = zeros( 4, 1 );
%     

    %% Constants
    NBANDS = size( std_table, 1 );
    NCOEFFS = length( frameFin );

    %% Calculate Normalization Coefficients
    P = zeros( NBANDS, 1 );
    Sw = zeros( NCOEFFS, 1 );
    for b = 1 : NBANDS

        klow = std_table( b, 2 ) + 1;
        khigh = std_table( b, 3 ) + 1;

        % Band Energy
        P( b ) = sumsqr( frameFin( klow : khigh ) );

        % Normalizing Coefficients for this Band
        Sw( klow : khigh ) = 1 / sqrt( P ( b ) );

    end
    
    %% Smooth Normalization Coefficients
    % Back-Smoothing
    for k = NCOEFFS-1 : -1 : 1
       
        Sw( k ) = 0.5 * ( Sw( k ) + Sw( k + 1 ) );
        
    end
    
    % Forward-Smoothing
    for k = 2 : NCOEFFS
       
        Sw( k ) = 0.5 * ( Sw( k ) + Sw( k - 1 ) );
        
    end
    
    %% Normalize MDCT Coefficients
    Xw = frameFin ./ Sw;
    
    %% Linear Predictor Coefficients
    % Compute directly via lpc
    A = lpc( Xw, 4 );
%     % Calculate auto-correlation matrix
%     r = xcorr( Xw );
%     % Solve normal equations
%     A = levinson( r( length( frameFin ) : end ), 4 );
    
    % Quantize
    TNScoeffs = L2_TNS_QUANTIZER_uniform_midrise( A( 2 : end ), 4, 0.1 );
    
    %% Filter Initial MDCT Coeffs
    % Set numerator denominator coefs
    num = [1; TNScoeffs];
    denom = 1;
    
    % Check if INVERSE filter is stable
    assert( isstable( denom, num ) )
    
    % Perform the actual filtering
    frameFout = filter( num, denom, frameFin );
    
end
