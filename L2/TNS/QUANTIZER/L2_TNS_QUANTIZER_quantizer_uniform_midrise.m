function symbol = L2_TNS_QUANTIZER_quantizer_uniform_midrise( input, R, Delta )
%L2_TNS_QUANTIZER_UNIFORM_MIDRISE Uniform midrise quantizer with R bits and
% Delta  bin range.
% 
%   input: the number to be quantized
%   R: quantizer bits ( bits / sample )
%   Delta : bin width ( range )
% 
%   symbol: quantizer's output is a symbol, denoting the bin the input 
%   belongs to
%

    %% Vector Input
    NINPUTS = length( input );
    if ( NINPUTS > 1 )
       
%         symbol = char( NINPUTS, 1 );
        
        for input_i = 1 : NINPUTS
           
            symbol( input_i, : ) = L2_TNS_QUANTIZER_quantizer_uniform_midrise( ...
                input( input_i ), R,  Delta ...
            );
            
        end
        
    else
        
        %% Quantizer Data
        %   - Number of Bins ( N to the left + N to the right of y-axis )
        N = 2 ^ ( R - 1 );

        %   - Range ( -xmax to xmax )
        xmax =  Delta  * N;

        %% Quantize
        number_abs = abs( input );
        number_sign = L2_TNS_QUANTIZER_sgn( input );

        % Check if outsite of range
        if ( number_abs >= xmax )

            symbol = number_sign * ( N - 1 ) + number_sign;

        end

        % Normal Quantization
        for bin = 0 : N - 1

            if ( bin * Delta <= number_abs && number_abs < ( bin + 1 ) * Delta )
                
                symbol = number_sign * bin + number_sign;
                break

            end

        end
        
        % Convert to binary string
        symbol = L2_TNS_QUANTIZER_dec2bin( symbol, 4 );
    
    end
    
end




































