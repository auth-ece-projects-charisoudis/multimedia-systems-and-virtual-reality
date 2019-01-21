function sf = L3_PSYCHO_spreading( frameType )
%L3_PSYCHO_SPREADING Returns the spreading function Nb x Nb array where Nb
%is the total number of bands ( Table B.2.1.x from ISO/IEC specification )
% 
%   frameType: frame's type
%
%   sf: array with spreding function between i to j bands ( Nb x Nb )
%

    global B219a
    global B219b
    
    % Total Bands, Nb
    if ( frameType == L1_SSC_Frametypes.EightShort )
        
        Nb = length( B219b );
        bval = B219b( :, 5 );
        
    else
        
        Nb = length( B219a );
        bval = B219a( :, 5 );
        
    end
    
    %% Compute Matrix
    sf = zeros( Nb );
    for bi = 1 : Nb
        
        for bj = 1 : Nb
        
            sf( bi, bj ) = L3_PSYCHO_SPREADING_cell( bval, bi, bj );
            
        end
        
    end
    
end
