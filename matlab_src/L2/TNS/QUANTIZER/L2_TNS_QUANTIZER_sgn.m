function number_sign = L2_TNS_QUANTIZER_sgn( input )
%L2_TNS_QUANTIZER_SGN Similar to sign but converts zero output to one (
%treats zero as positive )
%   
%   input: input signed number
%   
%   number_sign: the sign ( 1 for non-negatives, -1 for negatives )
% 

    % Get original output
    number_sign = sign( input );

    % Fix built in sing() for zero value ( midrise quantizers have no
    % zero ouput level )
    number_sign( number_sign == 0 ) = 1;

end

