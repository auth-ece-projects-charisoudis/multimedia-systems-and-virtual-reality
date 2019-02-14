function output = L2_TNS_QUANTIZER_bin2dec( bin, b )
%L2_TNS_QUANTIZER_DEC2BIN Summary of this function goes here
%   Detailed explanation goes here

    % Expand sign
    bin = [repmat( bin(1), 1, 32 - b ) bin];

    % Convert to dec
    output = bin2dec( bin );
    
    % Cast to signed int
    output = typecast( uint32( output ), 'int32' );
    output = double( typecast( int64( output ), 'int64' ) );
    
end

