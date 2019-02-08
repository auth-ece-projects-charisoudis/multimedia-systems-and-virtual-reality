function [ S, sfc, G ] = L3_AACQUANTIZER_quantizer_mono( frame, SMR, std_table )
%L3_AACQUANTIZER_QUANTIZER_MONO Quantizes a single frame or sub-frame
% 
%   frame: MDCT coefficients
%   SMR: Signa-to-Masking Ratio
%   std_table: table from AAC Standard
% 
%   S: quantized frame MDCT coefficients
%   sfc: scalefactors ( Nb x 1 )
%   G: global gain ( sfc( 0 ) )
% 
    
    %% Constants
    FRAME_LENGTH = length( frame );
    NBANDS = length( SMR );
    
    persistent MQ MagicNumber
    MagicNumber = 0.4054;
    MQ = 8191;

    %% MDCT Coefficients' Energy
    P = zeros( NBANDS, 1 );
    for b = 1 : NBANDS
        
        wlow = std_table( b, 2 ) + 1;
        whigh = std_table( b, 3 ) + 1;
        
        P( b ) = sumsqr( frame( wlow : whigh ) );
        
    end
    
    %% Auditity Threshold ( for each band )
    T = P ./ SMR;
    
    %% Quantize
    % Initialize Scalefactors
    S = zeros( FRAME_LENGTH, 1 );
    a = zeros( NBANDS, 1 );
    
    % Initial Approximation Step
    a0 = ( 16 / 3 ) * log2( max( frame ) ^ 0.75 / MQ );
    a( : ) = a0;
    
    % Optimization Step
    for b = 1 : NBANDS
        
        % Band Limits
        wlow = std_table( b, 2 ) + 1;
        whigh = std_table( b, 3 ) + 1;
        
        Pe = T( b ) - 1;
        while ( Pe <= T( b ) && max( abs( diff( a ) ) ) <= 60 )
            
            % Increment sfc ( lowers quantizer's quality in this band )
            a( b ) = a( b ) + 1;

            % Quantize frame coefficients        
            Sb_q = ...
                L2_TNS_QUANTIZER_sgn( frame( wlow : whigh ) ) .* ...
                floor( ...
                    ( 2^( -0.25 * a( b ) ) * abs( frame( wlow : whigh ) ) ) ...
                    .^ 0.75 + MagicNumber ...
                ) ...
            ;
        
            % Calculate Quntization Noise Power
            Pe = sumsqr( ...
                frame( wlow : whigh ) - ...
                ( L2_TNS_QUANTIZER_sgn( Sb_q ) .* (  abs( Sb_q ) .^ (4 / 3) ) ) ...
                * 2^( 0.25 * a( b ) ) ...
            );
            
        end
        
        % Revert to last a( b ) & re-calculate quantized frequency samples
        a( b ) = a( b ) - 1;
        S( wlow : whigh ) = ...
            L2_TNS_QUANTIZER_sgn( frame( wlow : whigh ) ) .* ...
            floor( ...
                ( 2^( -0.25 * a( b ) ) * abs( frame( wlow : whigh ) ) ) ...
                .^ 0.75 + MagicNumber ...
            ) ...
        ;
        
    end
    
    %% Scalefactors
    G = a( 1 );
    sfc = [ G; diff( a ) ];

    % Experiment: Set all sfcs equal to zero
%     G = 0;
%     sfc = zeros( size( sfc ) );

end
