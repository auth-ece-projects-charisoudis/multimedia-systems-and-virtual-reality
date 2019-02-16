function bin = L2_TNS_QUANTIZER_dec2bin( input, b )
%L2_TNS_QUANTIZER_DEC2BIN Summary of this function goes here
%   Detailed explanation goes here

    %% Vector Input
    NINPUTS = length( input );
    if ( NINPUTS > 1 )
       
        bin = strings( NINPUTS, 1 );
        for input_i = 1 : NINPUTS
           
            bin( input_i ) = L2_TNS_QUANTIZER_dec2bin( ...
                input( input_i ), b ...
            );
            
        end
        
        return
        
    end
        
    %% Single Input
    % Cast to unsigned int
    unsigned = typecast( int32( input ), 'uint32' );

    % Convert to binary
    bin = dec2bin( unsigned, b );

    % Keep last b bits
    bin = bin( end - ( b - 1 ) : end );

end

