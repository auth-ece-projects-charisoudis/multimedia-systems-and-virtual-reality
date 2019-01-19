function wn = L1_FILTERBANK_WINDOW_oaa( window_shape, window_size, window_param )
%L1_FILTERBANK_SAMPLE returns window of defined shape and size ( Normalized
%windows for Overlap-and-Add perfect reconstraction )
%   
%   window_shape: window type ( one of 'KBD', 'SIN' )
%   window_size: total window ( block ) size
%   window_param: if parametric, the window parameter ( e.g. alpha in KBD )
%
%   wn: the window function ( discrete time )
%

    switch ( window_shape )
        
        case 'KBD'
            
            % Kaiser-Bessel-derived (KBD) window function ( alpha = {window_param} )
            wn = kaiser( window_size / 2 + 1, window_param * pi );
            tmp = cumsum(  wn(  1 : window_size / 2 )  );
            wn = sqrt( [ tmp; tmp( window_size / 2 : -1 : 1 ) ] ./ sum( wn ) );
            
        case 'SIN'
            
            % Sine Window ( for OaA perfect recontruction )
            wn = 0 : window_size - 1;
            wn = wn';
            wn = sin( pi * ( wn + 0.5 ) / window_size );
            
    end


end

