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
%     return

    %% Calculate Band Energies
    NBANDS = size( std_table, 1 );
    P = zeros( NBANDS, 1 );
    for j = 1:NBANDS
       
        P( j ) = sumsqr( frameFin( ...
                std_table( j, 2 ) + 1 : std_table( j, 3 ) + 1 ...
            ) ...
        );
        
    end

    %% Normalization Coefficients
    NCOEFFS = length( frameFin );
    Sw = zeros( NCOEFFS, 1 );
    for k = 1:NCOEFFS
       
        % 1) Find the band  of the coefficient
        [ ~, j ] = min( abs( std_table( :, 2 ) - ( k - 1 ) ) );
        
        % 2) Calculate coefficient
        Sw( k ) = 1 / sqrt( P ( j ) );
        
    end
    
    % Back-Smoothing
    for k = NCOEFFS-1:-1:1
       
        Sw( k ) = ( Sw( k ) + Sw( k + 1 ) ) / 2;
        
    end
    
    % Forward-Smoothing
    for k = 2:NCOEFFS
       
        Sw( k ) = ( Sw( k ) + Sw( k - 1 ) ) / 2;
        
    end
    
    %% Normalize MDCT Coefficients
    Xw = frameFin ./ Sw;
    
    %% Linear Predictor Coefficients
    % Compute
    A = lpc( Xw, 4 );
    
    % Quantize
    TNScoeffs = L2_TNS_QUANTIZER_uniform_midrise( A( 2 : end ), 4, 0.1 );
    
    %% Filter Initial MDCT Coeffs
    % Check if filter is stable
    assert( isstable( 1, [1; TNScoeffs] ) )
    
    % Perform the actual filtering
    frameFout = filter( 1, [1; TNScoeffs], frameFin );
    
end

