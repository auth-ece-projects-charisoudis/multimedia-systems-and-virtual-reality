function output = L2_TNS_QUANTIZER_bin2dec( bin, b )
%L2_TNS_QUANTIZER_DEC2BIN Summary of this function goes here
%   Detailed explanation goes here

    %% Vector Input
    NINPUTS = size( char( bin ), 1 );
    if ( NINPUTS > 1 )
       
        output = zeros( NINPUTS, 1 );
        for bin_i = 1 : NINPUTS
           
            output( bin_i ) = L2_TNS_QUANTIZER_bin2dec( ...
                char( bin( bin_i ) ), b ...
            );
            
        end
        
        return
        
    end
    
    %% Single Input
    % Expand sign
    bin = [repmat( bin(1), 1, 32 - b ) bin];

    % Convert to dec
    output = bin2dec( bin );
    
    % Cast to signed int
    output = typecast( uint32( output ), 'int32' );
    output = double( typecast( int64( output ), 'int64' ) );
    
end

