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
    % Set numerator denominator coefs
    num = 1;
    denom = [1; TNScoeffs];
    
    % Perform the actual reverse-filtering
    frameFout = filter( num, denom, frameFin );
    
end
