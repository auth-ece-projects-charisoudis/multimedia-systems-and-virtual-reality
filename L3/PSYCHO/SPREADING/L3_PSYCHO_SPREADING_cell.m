function x = L3_PSYCHO_SPREADING_cell( bi, bj )
%L3_PSYCHO_SPREADING_CELL Return the spreading function's value for bands i
%and j and for the given frame type.
% 
%   bval: from std_table ( 5th column )
%   bi: "spreader" band
%   bj: "spreadee" band
%
%   x: spreading function's value for given spreader & spreadee bands
%
    
    %% tmpx
    tmpx = 1.5 * ( bj - bi );
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

