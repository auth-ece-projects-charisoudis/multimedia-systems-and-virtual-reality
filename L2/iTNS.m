function frameFout = iTNS( frameFin, frameType, TNScoeffs )
%TNS Applies Inverse Temporal Noise Shaping
%   
%   frameFin: input MDCT TNS'ed coefficients
%   frameType: type of the given frame ( one of 'ESH','OLS','LSS','LPS' )
%   TNScoeffs: quantized ( 4 bit ) TNS coefficients ( 4 coeefs / frame )
%   
%   frameFout: original MDCT coefficients
%   

%     frameFout = frameFin;

    %% Per Frame Inverse TNS
    switch frameType
        
        case L1_SSC_Frametypes.EightShort
            
            % Get input frame's dimensions
            frameFin_size = size( frameFin );
            
            % Init output arguments
            frameFout = zeros( frameFin_size );
            
            % Apply TNS to each sub-MDCT
            for sub_frame_i = 1 : frameFin_size( 2 )
               
                frameFout( :, sub_frame_i ) = ...
                    L2_TNS_itns_mono( ...
                        frameFin( :, sub_frame_i ), ...
                        TNScoeffs( :, :, sub_frame_i ) ...
                    );
                
            end
            
        otherwise
            
            % All long-type frames
            frameFout = L2_TNS_itns_mono( frameFin, TNScoeffs );
            
    end
    
end



% function frameFout = iTNS(frameFin, frameType, TNScoeffs)
% %UNTITLED3 Summary of this function goes here
% %   Detailed explanation goes here
%     
%     frameType = L1_SSC_Frametypes.getShortCode( frameType );
% 
%     B = 1;
%     if strcmp(frameType,'ESH')
%         sub = 8;
%     else
%         sub=1;
%     end
%     
%     
%     for i=1:sub
% %         
%         A = [1 -unquantizeTNS(TNScoeffs(:,i))'];
% %         flag = isstable(B, A);
%         r = roots(A);
%         in = find(abs(r)>0.98);
%         flag = isempty(in);
%         if ~flag
% %             r = roots(A);
% %             in = find(abs(r)>0.95);
% %             r(in) = r(in)./(abs(r(in))+0.05);
% %             in = find(abs(r)>1);
% %             r(in) = 1./r(in);
% %             in = find(abs(r)>0.98);
%             r(in) = r(in)./(abs(r(in))+0.15);
%             A = poly(r);
%         end
% 
% %         A = [1 -TNScoeffs(:,i)'];
%         f = frameFin(:,i);
%         frameFout(:,i) = filter(B,A,f);
%     end
% end
