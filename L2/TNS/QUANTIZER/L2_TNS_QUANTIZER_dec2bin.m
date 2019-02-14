function bin = L2_TNS_QUANTIZER_dec2bin( input, b )
%L2_TNS_QUANTIZER_DEC2BIN Summary of this function goes here
%   Detailed explanation goes here

    % Cast to unsigned int
    unsigned = typecast( int32( input ), 'uint32' );
    
    % Convert to binary
    bin = dec2bin( unsigned, b );
    
    % Keep last b bits
    bin = bin( end - ( b - 1 ) : end );

end

