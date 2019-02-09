function output = L2_TNS_QUANTIZER_uniform_midrise( input, R, Delta )
%L2_TNS_QUANTIZER_UNIFORM_MIDRISE Uniform midrise quantizer with R bits and
% Delta  bin range.
% 
%   input: the number to be quantized
%   R: quantizer bits ( bits / sample )
%   Delta : bin width ( range )
% 
%   output: number quantized with R bits
%

    %% Vector Input
    NINPUTS = length( input );
    if ( NINPUTS > 1 )
       
        output = zeros( NINPUTS, 1 );
        
        for input_i = 1 : NINPUTS
           
            output( input_i ) = L2_TNS_QUANTIZER_uniform_midrise( ...
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

            output = number_sign * ( 0.5 + ( N - 1 ) ) * Delta;

        end

        % Normal Quantization
        for bin = 0 : N - 1

            if ( bin * Delta <= number_abs && number_abs < ( bin + 1 ) * Delta )

                output = number_sign * ( 0.5 + bin ) * Delta;
                break

            end

        end
    
    end
    
end

