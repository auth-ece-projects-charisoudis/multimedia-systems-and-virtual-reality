function frameType = SSC( frameT, nextFrameT, prevFrameType )
%SSC Sequence Segmentatio Control
%   Finds the frame type for each frame in the frame sequence
% 

    %% Global Settings
    global AACONFIG
    register_config()
    
    if ( AACONFIG.L1.SSC_ONLY_LONG_TEST )
       
        frameType = L1_SSC_Frametypes.OnlyLong;
        return
        
    end

    %% FIX: permute input frames ( 2048x1x2 --> 2048x2 )
    frameT = permute( frameT, [1, 3, 2] );
    nextFrameT = permute( nextFrameT, [1, 3, 2] );
    
    %% Trivial Cases
    if ( prevFrameType == L1_SSC_Frametypes.LongStop )
        
        frameType = L1_SSC_Frametypes.OnlyLong;
        return
        
    elseif ( prevFrameType == L1_SSC_Frametypes.LongStart )
        
        frameType = L1_SSC_Frametypes.EightShort;
        return
        
    end
    
    %% Next Frame Type
    nextLeftFrameType = L1_SSC_nextFrameType( nextFrameT( :, 1) );
    nextRightFrameType = L1_SSC_nextFrameType( nextFrameT( :, 2) );
    nextFrameType = L1_SSC_combineFrameTypes( nextLeftFrameType, nextRightFrameType );
    
    %% Previous Frame Type
    if ( prevFrameType == L1_SSC_Frametypes.OnlyLong )
        
        if ( nextFrameType == L1_SSC_Frametypes.EightShort )
        
            frameType = L1_SSC_Frametypes.LongStart;
            return

        else

            frameType = L1_SSC_Frametypes.OnlyLong;
            return
        
        end
        
    elseif ( prevFrameType == L1_SSC_Frametypes.EightShort )
        
        if ( nextFrameType == L1_SSC_Frametypes.EightShort )
        
            frameType = L1_SSC_Frametypes.EightShort;
            return

        else

            frameType = L1_SSC_Frametypes.LongStop;
            return
        
        end
        
    end

end
