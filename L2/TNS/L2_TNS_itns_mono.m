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
%     TNSceffs_hat = unquantizeTNS( TNScoeffs );
    
    % Set numerator denominator coefs
    num = 1;
    denom = [1; -TNSceffs_hat];
        
    % Check if filter is stable, and if not apply stabilization in
    % denominator
    if ( ~isstable( num, denom ) )
                
        % Using MATLAB's builtin polystab()
        denom = polystab( denom );

        % Re-assess filter stability
        assert( isstable( num, denom ) )
        
    end
    
    % Perform the actual reverse-filtering
    frameFout = filter( num, denom, frameFin );
    
end
