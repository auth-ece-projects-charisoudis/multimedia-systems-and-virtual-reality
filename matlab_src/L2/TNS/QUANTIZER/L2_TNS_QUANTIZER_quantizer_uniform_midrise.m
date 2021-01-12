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

    global scalarQuantizer

    %% Quantizer Data
    %   - Number of Bins ( N to the left + N to the right of y-axis )
    N = 2 ^ ( R - 1 );

    %   - Range ( -xmax to xmax )
    xmax =  Delta  * N;

    % Builtin method's args
    codebook = -N : N - 1;
    boundary = -xmax : Delta : xmax;

    %% Quantize
    % Initialize Quantizer
    if ( isempty( scalarQuantizer ) )
        
        scalarQuantizer = dsp.ScalarQuantizerEncoder;

        % Set params
        scalarQuantizer.BoundaryPoints = boundary;
        scalarQuantizer.CodewordOutputPort = true;
        scalarQuantizer.Codebook = codebook;
        
    end

    % Execute
    [indices, ~] = scalarQuantizer( input );

    % Convert to binary string
    symbol = dec2bin( indices, 4 );
    
end
