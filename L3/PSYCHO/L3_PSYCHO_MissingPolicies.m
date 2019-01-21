classdef L3_PSYCHO_MissingPolicies
    
    properties (Constant)
        
        Zeros               uint8   = 1;
        SameAsFirst         uint8   = 2;
        FromPreviousFrame   uint8   = 3;
        
        Defer               uint8   = 4;    % Wait until more recent frames 
        % are processed and copy their processing result
        
    end
    
end
