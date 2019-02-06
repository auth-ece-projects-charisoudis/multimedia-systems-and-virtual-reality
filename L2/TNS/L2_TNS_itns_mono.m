function frameFout = L2_TNS_itns_mono( frameFin, TNScoeffs )
%L2_TNS_INVERSE_MONO Inverse TNS for a single frame
%   
%   frameFin: input MDCT coefficients
%   TNScoeffs: quantized ( 4 bit ) TNS coefficients ( 4 coeefs / frame )
%   
%   frameFout: reconstructed MDCT coefficients
%
    
%     frameFout = frameFin;
%     return

    %% Un-Filter produced MDCT Coeffs to reconstruct original
    % Check if filter is stable
    assert( isstable( [1; TNScoeffs], 1 ) )
    
    % Perform the actual reverse-filtering
    frameFout = filter( [1; TNScoeffs], 1, frameFin );    
    
end
