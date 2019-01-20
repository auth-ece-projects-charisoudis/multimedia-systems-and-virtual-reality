classdef L1_SSC_Frametypes
    
    properties (Constant)
        OnlyLong    uint8   = 1;
        EightShort  uint8   = 2;
        LongStart   uint8   = 3;
        LongStop    uint8   = 4;
        Other       uint8   = 5;
    end
    
    methods ( Static )
    
        function shortCode = getShortCode( obj )
            
            switch obj
                case L1_SSC_Frametypes.OnlyLong
                    shortCode = 'OLS';
                case L1_SSC_Frametypes.EightShort
                    shortCode = 'ESH';
                case L1_SSC_Frametypes.LongStart
                    shortCode = 'LSS';
                case L1_SSC_Frametypes.LongStop
                    shortCode = 'LPS';
                otherwise
                    shortCode = 'OTHER';
            end
            
        end
        
    end
    
end