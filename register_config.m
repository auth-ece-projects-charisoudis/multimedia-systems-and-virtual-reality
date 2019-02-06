function register_config( confset )
%REGISTER_CONFIG Registers execution configuration struct in the global
%variables' workspace.
% 
%   confset: one of the pre-selected run configurations:
%               - 1: default in all, no huffman encode
%               - 2: default in all, huffman encode
%               - 3: marios mdct, zeros missing policy, no huffman encode
%               - 4: marios mdct, zeros missing policy, huffman encode
%            If no confset selected ( nargin = 0 ) then the 1st is
%            automatically selected.
% 

    global AACONFIG AACONFSET

    % Configuration set
    if ( nargin ==0 || isempty( confset ) )

        if ( isempty( AACONFSET ) )
        
            confset = 1; 
            
        else
            
            confset = AACONFSET; 
            
        end

    end
    
    % Initialize Config Struct
    if ( isempty( AACONFIG ) )
        
        AACONFIG = struct( ...
            'DEBUG', false, ...
            'L1', struct( ...
                'MDCT_METHOD', 'default', ...           % default or marios
                'SSC_ONLY_LONG_TEST', false, ...
                'L3_ENCODER_RUNNING', false, ...
                'SNR', struct( ...
                    'COMPUTE_METHOD', 'default', ...    % default or builtin
                    'MEAN_METHOD', 'mean' ...           % mean or rms
                ) ...
            ), ...
            'L2', struct( ...
                ...
            ), ...
            'L3', struct( ...
                'HUFFMAN_ENCODE', false, ...
                'HUFFMAN_ENCODE_SFCS', false, ...
                'ON_PREV_MISSING_POLICY', L3_PSYCHO_MissingPolicies.SameAsFirst ...
            ) ...
        );
    
        % Per configuration-set settings
        switch confset

            case 1
                AACONFIG.L1.MDCT_METHOD = 'default';
                AACONFIG.L1.SNR.COMPUTE_METHOD = 'default';
                AACONFIG.L3.HUFFMAN_ENCODE = false;
                AACONFIG.L3.ON_PREV_MISSING_POLICY = L3_PSYCHO_MissingPolicies.SameAsFirst;

            case 2
                AACONFIG.L1.MDCT_METHOD = 'default';
                AACONFIG.L1.SNR.COMPUTE_METHOD = 'default';
                AACONFIG.L3.HUFFMAN_ENCODE = true;
                AACONFIG.L3.ON_PREV_MISSING_POLICY = L3_PSYCHO_MissingPolicies.SameAsFirst;

            case 3
                AACONFIG.L1.MDCT_METHOD = 'marios';
                AACONFIG.L3.HUFFMAN_ENCODE = false;
                AACONFIG.L3.ON_PREV_MISSING_POLICY = L3_PSYCHO_MissingPolicies.Defer;

            case 4
                AACONFIG.L1.MDCT_METHOD = 'marios';
                AACONFIG.L3.HUFFMAN_ENCODE = true;
                AACONFIG.L3.ON_PREV_MISSING_POLICY = L3_PSYCHO_MissingPolicies.Defer;

        end
        
        % Save configuration-set
        AACONFSET = confset;
        
    end

end

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

