function register_config()
%CONFIG Summary of this function goes here
%   Detailed explanation goes here

    global AACONFIG
    
    % Initialize Config Struct
    if ( isempty( AACONFIG ) )
        
        AACONFIG = struct( ...
            'DEBUG', true, ...
            'L1', struct( ...
                'SSC_ONLY_LONG_TEST', false, ...
                'L3_ENCODER_RUNNING', false ...
            ), ...
            'L2', struct( ...
                ...
            ), ...
            'L3', struct( ...
                'HUFFMAN_ENCODE', false, ...
                'HUFFMAN_ENCODE_SFCS', false, ...
                'ON_PREV_MISSING_POLICY', L3_PSYCHO_MissingPolicies.Defer ...
            ) ...
        );
    
    end

end

