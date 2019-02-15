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
    
    persistent MQ
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
    
    % Initialize band indices
    band_indices = 1 : NBANDS;
    completed = false( NBANDS, 1 );
    
    % Initial Approximation Step
    a0 = ( 16 / 3 ) * log2( max( frame ) ^ 0.75 / MQ );
    a( : ) = a0;
    
    % Optimization Step
    %   In each calculation step, we compute the quantization noise power
    %   for each band. After that, the respective sfc is either incremented
    %   or decremented by 1. The procedure continues until either all band
    %   powers have become greater than band's auditity threshold or the
    %   diff( sfcs ) is greater than or equal to 60.
    while ~all( completed )
        
        for b = band_indices( ~completed )

            % Band Limits
            wlow = std_table( b, 2 ) + 1;
            whigh = std_table( b, 3 ) + 1;
            
            % Quantization-noise power in band
            Sb = L3_AACQUANTIZER_quantize( frame( wlow : whigh ), a( b ) );
            Pe = sumsqr( frame( wlow : whigh ) - ...
                L3_AACQUANTIZER_dequantize( Sb, a( b ) ) ...
            );
        
            % If above power is below auditity threshold, incement a( b )
            % else decrement a( b ) and mark this band as completed
            if ( Pe < T( b ) )
                
                % Increment sfc ( lowers quantizer's quality in this band )
                a( b ) = a( b ) + 1;
                
            else
                
                % Revert back sfc
                a( b ) = a( b ) - 1;
                
                % Quantize MDCT coeffs for this band
                S( wlow : whigh ) = L3_AACQUANTIZER_quantize( frame( wlow : whigh ), a( b ) );
                
                % Mark band as completed
                completed( b ) = 1;
                
            end
        
            % 2ND TERMNATION CASE: max( abs( diff( a ) ) ) > 60
            if ( max( abs( diff( a ) ) ) > 59 )

                % Quantize MDCT coeffs for this band
                S( wlow : whigh ) = Sb;
                
                % Set all bands to completed state: QUANTIZER FINISHED
                completed( : ) = true;
                
                % Break bands loop
                break;

            end

        end
    
    end
    
    %% Scalefactors
    G = a( 1 );
    sfc = diff( a );

    %% Experiment: Set all sfcs equal to zero
%     G = 0;
%     sfc = zeros( size( sfc ) );

end
