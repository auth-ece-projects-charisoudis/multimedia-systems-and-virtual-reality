function frameType = L1_SSC_combineFrameTypes( leftFrameType, rightFrameType )
%L1_SSC_COMBINEFRAMETYPES Combines left & right channel frames' types into
%one frame type based on given algorithm.
%   
%   leftFrameType: frame type for left channel's frame
%   rightFrameType: frame type for right channel's frame
% 
%   frameType: the resulting common frame type
% 

    %% Left OLS || Left == Right
    if ( leftFrameType == L1_SSC_Frametypes.OnlyLong || leftFrameType == rightFrameType  )
        
        frameType = rightFrameType;
        return
        
    end
    
    %% Left ESH
    if ( leftFrameType == L1_SSC_Frametypes.EightShort )
        
        frameType = L1_SSC_Frametypes.EightShort;
        return
        
    end
    
     %% Left LSS || Left LSP
     if ( rightFrameType == L1_SSC_Frametypes.OnlyLong )
            
        frameType = leftFrameType;
        return

    else

        frameType = L1_SSC_Frametypes.EightShort;
        return

     end

end
