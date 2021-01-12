function wn = L1_FILTERBANK_WINDOW_window( frameType, window_size, window_shape )
%L1_FILTERBANK_WINDOW_window Get window for current frame or sub-frame
%   Returns an overlap-and-add perfect reconstruction window ( either a normal or a transition one )
%
%   frameType: frame's type ( one of L1_SSC_Frametypes.OnlyLong, L1_SSC_Frametypes.EightShort, L1_SSC_Frametypes.LongStart, L1_SSC_Frametypes.LongStop )
%   window_size: total window ( block ) size
%   window_shape: window type ( one of 'KBD', 'SIN' )
%
%   wn: the window function ( discrete time )
%

    switch ( frameType )
        
        case L1_SSC_Frametypes.OnlyLong
            
            wn = L1_FILTERBANK_WINDOW_oaa( window_shape, window_size, 6 );
            
        case L1_SSC_Frametypes.EightShort
            
            wn = L1_FILTERBANK_WINDOW_oaa( window_shape, window_size, 4 );
            
        case L1_SSC_Frametypes.LongStart
            
            % Left half is identical to OLS
            wn = L1_FILTERBANK_WINDOW_window( L1_SSC_Frametypes.OnlyLong, window_size, window_shape );
            
            % Ones in 1025:1472
            wn( window_size/2 + 1:window_size/2 + 448 ) = 1;
            
            % Right half of ESH window
            tmp = L1_FILTERBANK_WINDOW_window( L1_SSC_Frametypes.EightShort, 256, window_shape );
            wn( window_size/2 + 449:window_size/2 + 448 + 128 ) = tmp( 129:end );
            
            % 448 zeros at the end
            wn( window_size-448+1:end ) = 0; 
            
        case L1_SSC_Frametypes.LongStop
            
            % Right half is identical to OLS
            wn = L1_FILTERBANK_WINDOW_window( L1_SSC_Frametypes.OnlyLong, window_size, window_shape );
            
            % Ones in 577:1024
            wn( window_size/2 -448 + 1:window_size/2 ) = 1;
            
            % Left half of ESH window
            tmp = L1_FILTERBANK_WINDOW_window( L1_SSC_Frametypes.EightShort, 256, window_shape );
            wn( 449:window_size/2 - 448 ) = tmp( 1:128 );
            
            % 448 zeros at the end
            wn( 1:448 ) = 0; 
            
    end

end

