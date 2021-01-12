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

    global scalarDequantizer

    %% DeQuantizer Data
    %   - Number of Bins ( N to the left + N to the right of y-axis )
    N = 2 ^ ( R - 1 );

    %   - Range ( -xmax to xmax )
    xmax =  Delta  * N;

    % Builtin method's args
    output_codebook = -xmax + Delta: Delta : xmax;
    output_codebook = output_codebook - Delta * 0.5;

    %% Quantize
    % Get dec value
    indices = int32( bin2dec( symbol ) );
        
    % Initialize Quantizer
    if ( isempty( scalarDequantizer ) )
        
        scalarDequantizer = dsp.ScalarQuantizerDecoder;

        % Set params
        scalarDequantizer.CodebookSource = 'Property';
        scalarDequantizer.Codebook = output_codebook;
        
    end

    % Execute
    output = scalarDequantizer( indices );
    
end

