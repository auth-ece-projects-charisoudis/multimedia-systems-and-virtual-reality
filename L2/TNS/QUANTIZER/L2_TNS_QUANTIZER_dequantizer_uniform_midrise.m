function output = L2_TNS_QUANTIZER_dequantizer_uniform_midrise( symbol, R, Delta )
%L2_TNS_QUANTIZER_UNIFORM_MIDRISE Uniform midrise quantizer with R bits and
% Delta  bin range.
% 
%   symbol: quantizer's symbol: the bin
%   R: quantizer bits ( bits / sample )
%   Delta : bin width ( range )
% 
%   output: number quantized with R bits
%

    %% Vector Input
    NINPUTS = size( symbol, 1 );
    if ( NINPUTS > 1 )
       
        output = zeros( NINPUTS, 1 );
        
        for symbol_i = 1 : NINPUTS
           
            output( symbol_i ) = L2_TNS_QUANTIZER_dequantizer_uniform_midrise( ...
                symbol( symbol_i, : ), R,  Delta ...
            );
            
        end
        
    else
        % Get dec value
        symbol = L2_TNS_QUANTIZER_bin2dec( symbol, 4 );
        
        %% DeQuantize
        number_sign = sign( symbol );
        bin = ( symbol - number_sign ) / number_sign + 0.0;
        output = number_sign * ( 0.5 + bin ) * Delta;
    
    end
    
end

