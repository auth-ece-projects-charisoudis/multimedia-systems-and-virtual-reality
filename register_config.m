function register_config()
%REGISTER_CONFIG Registers execution configuration struct in the global
%variables' workspace.
%

    global AACONFIG
    
    % Initialize Config Struct
    if ( isempty( AACONFIG ) )
        
        AACONFIG = struct( ...
            'DEBUG', false, ...
            'L1', struct( ...
                'SSC_ONLY_LONG_TEST', false, ...
                'L3_ENCODER_RUNNING', false, ...
                'SNR', struct( ...
                    'COMPUTE_METHOD', 'default', ...
                    'MEAN_METHOD', 'rms' ...
                ) ...
            ), ...
            'L2', struct( ...
                ...
            ), ...
            'L3', struct( ...
                'HUFFMAN_ENCODE', true, ...
                'HUFFMAN_ENCODE_SFCS', false, ...
                'ON_PREV_MISSING_POLICY', L3_PSYCHO_MissingPolicies.SameAsFirst ...
            ) ...
        );
    
    end

end

