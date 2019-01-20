function x = L3_PSYCHO_SPREADING_cell( frameType, bi, bj  )
%L3_PSYCHO_SPREADING_CELL Return the spreading function's value for bands i
%and j and for the given frame type.
% 
%   frameType: frame's type
%   bi: "spreader" band
%   bj: "spreadee" band
%
%   x: spreading function's value for given spreader & spreadee bands
%

    global B219a
    global B219b
    
    if ( frameType == L1_SSC_Frametypes.EightShort )
        
        bval = B219b( :, 5 );
        
    else
        
        bval = B219a( :, 5 );
        
    end
    
    %% tmpx
    tmpx = 1.5 * bval( bj ) - bval( bi );
    if ( bi >= bj )
       
        tmpx = 2 * tmpx;
        
    end
    
    %% tmpy
    tmpy = 15.811389 + 7.5 * ( tmpx + 0.474 ) - 17.5 * sqrt( 1 + ( tmpx + 0.474 ) ^ 2 );
    
    %% tmpz
    tmpz = 8 * min( ( tmpx - 0.5) * ( tmpx - 2.5 ), 0 );
    
    %% Compute
    if ( tmpy < -100 )
       
        x = 0;
        
    else
        
        x = 10 ^ ( 0.1 * ( tmpz + tmpy ) );
        
    end
    
end

