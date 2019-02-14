function frameFout = L2_TNS_itns_mono( frameFin, TNScoeffs )
%L2_TNS_INVERSE_MONO Inverse TNS for a single frame
%   
%   frameFin: input MDCT coefficients
%   TNScoeffs: quantized ( 4 bit ) TNS coefficients ( 4 coeefs / frame )
%   
%   frameFout: reconstructed MDCT coefficients
%
% 
%   frameFout = frameFin;
% 

    %% Un-Filter produced MDCT Coeffs to reconstruct original    
    % Dequantize TNScoeffs
    TNSceffs_hat = L2_TNS_QUANTIZER_dequantizer_uniform_midrise( TNScoeffs, 4, 0.1 );
    
    % Set numerator denominator coefs
    num = 1;
    denom = [1; -TNSceffs_hat];
        
    if ( ~isstable( num, denom ) )
        
        r = roots( denom );
        in = find( abs( r ) > 0.98 );
        
        r( in ) = r( in ) ./ ( abs( r( in ) ) + 0.15 );
        denom = poly( r );
        
    end
    
    % Perform the actual reverse-filtering
    assert( isstable( num, denom ) )
    frameFout = filter( num, denom, frameFin );
    
end
