classdef L1_SSC_Frametypes
    
    properties (Constant)
        OnlyLong    uint8   = 0;
        EightShort  uint8   = 1;
        LongStart   uint8   = 2;
        LongStop    uint8   = 3;
        Other       uint8   = -1;
    end
    
    methods ( Static )
    
        function shortCode = getShortCode( intCode )
            
            switch intCode
                
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
        
        function intCode = getIntCode( shortCode )
            
            switch shortCode
                
                case 'OLS'
                    intCode = L1_SSC_Frametypes.OnlyLong;
                
                case 'ESH'
                    intCode = L1_SSC_Frametypes.EightShort;
                
                case 'LSS'
                    intCode = L1_SSC_Frametypes.LongStart;
                
                case 'LPS'
                    intCode = L1_SSC_Frametypes.LongStop;
                
                otherwise
                    intCode = L1_SSC_Frametypes.Other;
            
            end
            
        end
        
    end
    
end