function SMR = psycho( frameT, frameType, frameTprev1, frameTprev2 )
%PSYCHO Applies psychoaccoustic model to this frame ( needs previous time
%frames for predicting the frequency coefficients.
% 
%   When applying prediction we donot care about previous frames's types
%   just their samples's values ( which will then be transformed with DFT
%   and used by the predictor ).
% 
%   LONG Frames:
%   If both previous frames are not available, then the current frame
%   should be given for the previous and pre-previous.
%   If only previous frame is available, then psycho model should be fed
%   with the previous frame two times. 
% 
%   SHORT Frames:
%   If any of the previous sub-frames is not available, then model should
%   be fed with the last respective samples of the previous frame ( even if
%   the previous frame is a long one, we virtually cut it and extract last
%   one or two sub-frames ).
% 
%   frameT: frame in time samples
        
        % Check if previous frames exist
        % ...
%   frameType: frame's type
%   frameTprev1: previous frame ( time samples )
%   frameTprev2: pre-previous frame ( time samples )
% 
%   SMR: resulting Signal-to-Masking Ratio by applying the psycho-acoustic
%   model to this frame
% 

    %% Constants
    FRAME_LENGTH = length( frameT );
    global AACONFIG
    
    % Previous frame for ESH frames
    global ESH_frameTprev1 ESH_frameTprev2
    
    %% Load Standard's Tables
    %  - B219a: for Long Windows
    %  - B219b: for Short Windows
    global B219a
    global B219b

    %% Compute Sreading Function Matrix ( once for each frame type )
    global spreading_matrix_short
    global spreading_matrix_long
    if ( frameType == L1_SSC_Frametypes.EightShort )
        
        if ( isempty( spreading_matrix_short ) )
           
            spreading_matrix_short = L3_PSYCHO_spreading( L1_SSC_Frametypes.EightShort );
            
        end
        spreading_matrix = spreading_matrix_short;
        
    else
        
        if ( isempty( spreading_matrix_long ) )
           
            spreading_matrix_long = L3_PSYCHO_spreading( L1_SSC_Frametypes.OnlyLong );
            
        end
        spreading_matrix = spreading_matrix_long;
        
    end
    
    %% Compute Hanning window ( once for each frame type )
    % Note: this is the left half of the hanning window
    global hann_window_short
    global hann_window_long
    if ( frameType == L1_SSC_Frametypes.EightShort )
        
        if ( isempty( hann_window_short ) )
           
            N = FRAME_LENGTH / 8;
            hann_window_short = ...
                0.5 - 0.5 * cos( pi * ( ( 0 : N-1 )' + 0.5 ) / N );
            
        end
        hann_window = hann_window_short;
        
    else
        
        if ( isempty( hann_window_long ) )
           
            N = FRAME_LENGTH;
            hann_window_long = ...
                0.5 - 0.5 * cos( pi * ( ( 0 : N-1 )' + 0.5 ) / N );
            
        end
        hann_window = hann_window_long;
        
    end
    
    %% Check Frame Type
    if ( frameType == L1_SSC_Frametypes.EightShort )
       
        % Prepare output argument
        SMR = zeros( length( spreading_matrix ), 8 );
        
        % Extract Sub-Frames ( for current )
        subframes = buffer( frameT( 449 : end - 448 ), 256, 128 );
        
        % Initial Assignment of previous frames
        switch( AACONFIG.L3.ON_PREV_MISSING_POLICY )
            
            case L3_PSYCHO_MissingPolicies.Defer
                % Defer computation of first 2 subframes until 3rd's SMR
                % has been computed. Then copy this result for the
                % preceding two subframes.
                % ATTENTION: This strategy is used ONLY for the 1st ESH
                % frame in the song. For the following ESH frames, the last
                % two subframes of the previous ESH frame are used.
                if ( isempty( ESH_frameTprev1 ) )
                
                    frameTprev1 = subframes( :, 2 );
                    frameTprev2 = subframes( :, 1 );
                    subframe_i_start = 3;
                    
                else
                    
                    frameTprev1 = ESH_frameTprev1;
                    frameTprev2 = ESH_frameTprev2;
                
                end
                
            case L3_PSYCHO_MissingPolicies.Zeros
                
                if ( isempty( ESH_frameTprev1 ) )
                    
                    frameTprev1 = zeros( FRAME_LENGTH / 8, 1 );
                    frameTprev2 = zeros( FRAME_LENGTH / 8, 1 );
                    
                else
                    
                    frameTprev1 = ESH_frameTprev1;
                    frameTprev2 = ESH_frameTprev2;
                
                end
                    
                subframe_i_start = 1;
        	
            case L3_PSYCHO_MissingPolicies.SameAsFirst
                
                if ( isempty( ESH_frameTprev1 ) )
                    
                    frameTprev1 = subframes( :, 1 );
                    frameTprev2 = subframes( :, 1 );
                    
                else
                    
                    frameTprev1 = ESH_frameTprev1;
                    frameTprev2 = ESH_frameTprev2;
                
                end
                
                subframe_i_start = 1;
                
        end
        
        if ( AACONFIG.DEBUG )
            
            sprintf( '\t\tbefore ESH loop' )
            
        end
        
        % Loop through all sub-frames
        for subframe_i = subframe_i_start : 8
            
            % Get one new subframe
            frameT = subframes( :, subframe_i );
            
            % Compute SMR
            SMR( :, subframe_i ) = L3_PSYCHO_psycho_mono( ...
                [ frameT, frameTprev1, frameTprev2 ], ...
                spreading_matrix, hann_window, B219b ...
            );
        
            % Slide previous frames
            frameTprev2 = frameTprev1;
            frameTprev1 = frameT;
            
        end
        
        if ( AACONFIG.DEBUG )
            
            sprintf( '\t\after ESH loop' )
            
        end
        
        % Check if Defered execution has been selected
        if ( AACONFIG.L3.ON_PREV_MISSING_POLICY == L3_PSYCHO_MissingPolicies.Defer )
           
            SMR( :, 1 ) = SMR( :, 3 );
            SMR( :, 2 ) = SMR( :, 3 );
            
        end
        
        % Save last two frames for next ESH frame
        ESH_frameTprev1 = subframes( :, 8 );
        ESH_frameTprev2 = subframes( :, 7 );
        
    else
        
        % Compute SMR
        SMR = L3_PSYCHO_psycho_mono( ...
            [ frameT frameTprev1 frameTprev2 ], ...
            spreading_matrix, hann_window, B219a ...
        );
        
    end

end


% function SMR = psycho(frameT, frameType, frameTprev1, frameTprev2)
% %UNTITLED2 Summary of this function goes here
% %   Detailed explanation goes here
%     %load tables
%     load('TableB219.mat');
%     load('spreadingTables.mat');
%     
%     frameType = L1_SSC_Frametypes.getShortCode( frameType );
%     
%     % initialize parameters
%     if strcmp(frameType,'ESH')
%         N = 256;
%         sub = 8;
%         start = 449;
%         finish = 1600;
%         table = B219b;
%         spr = short;
%     else
%         N= 2048;
%         sub = 1;
%         start = 1;
%         finish = N;
%         table = B219a;
%         spr = long;
%     end
%     %Hann window
%     n = 0:N-1;
%     w = 0.5 - 0.5*cos(pi*(n+0.5)/N);
%     w = w(:);
%     
%     sw(:,1) = w.*frameTprev2;
%     sw(:,2) = w.*frameTprev1;
%     
%     sub_frames = buffer(frameT(start:finish), N, N/2);
%     sw(:,3:2+sub) = diag(sparse(w))*sub_frames(:, 2:end);
%     
%     frameF = fft(sw);
%     
%     f = angle(frameF);
%     r = abs(frameF);
%     
%     f = f(1:N/2+1, :);
%     r = r(1:N/2+1, :);
%     
%     rpred = 2*r(:,2:sub+1) - r(:,1:sub);
%     fpred = 2*f(:,2:sub+1) - f(:,1:sub);
% 
%     t1 = r(:,3:end).*cos(f(:,3:end)) - rpred.*cos(fpred);
%     t2 = r(:,3:end).*sin(f(:,3:end)) - rpred.*sin(fpred);
%         
%     ac = r(:,3:end).*exp(1j*f(:,3:end));
%     rr = rpred.*exp(1j*fpred);
%     tt = abs(rr-ac);
%     cw1 = tt./(r(:,3:end)+abs(rpred));
%     cw = sqrt(t1.^2 + t2.^2)./(r(:,3:end)+abs(rpred));
%         
%     bands = max(size(table));
%     b_start = table(:,2)+1;
%     b_end = table(:,3)+1;
%             
%     e = zeros(bands, sub);
%     c = e;
%     
%     r_sq = r(:,3:sub+2).^2;
%     a = cw.*r_sq;
%     
%     for j=1:bands
%         e(j,:) = sum(r_sq(b_start(j):b_end(j),:),1);
%         c(j,:) = sum(a(b_start(j):b_end(j),:),1);
%     end
%     
%     ecb = (spr')*e;
%     ct = (spr')*c;
% 
%     sumsp = sum(spr, 1);
% 
%     sumspread = sumsp(:);
%     sumspread = ones(bands,1)./sumspread;
% 
%     cb = ct./ecb;
%     en = diag(sparse(sumspread))*ecb;
%     
%     tb = -0.299 - 0.43*log(cb);
% %     tb(tb>1) = 1;
% %     tb(tb<0) = 0;
% 
%     nmt = 6;
%     tmn = 18;
%     SNR = tb*tmn + (1-tb)*nmt;
%     
%     bc = 10.^(-SNR/10);
%     
%     nb = en.*bc;
%     
%     qthr = eps()*N/2*10.^(table(:,6)/10);
%     
%     npart = zeros(bands,sub);
% 
%     for i=1:sub        
%             npart(:,i) = max(nb(:,i), qthr);
%     end
%     
%     SMR = e./npart;
%     
% end