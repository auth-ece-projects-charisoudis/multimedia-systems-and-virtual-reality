function [ frameFout, TNScoeffs ] = TNS( frameFin, frameType )
%TNS Applies Temporal Noise Shaping to each frame's MDCT coefficients
%   
%   frameFin: input MDCT coefficients
%   frameType: type of the given frame ( one of 'ESH','OLS','LSS','LPS' )
%   
%   frameFout: converted MDCT coefficients using TNS
%   TNScoeffs: quantized ( 4 bit ) TNS coefficients ( 4 coeefs / frame )
%   

%     TNScoeffs = zeros( 32, 1 );
%     frameFout = frameFin;
    
    %% Load Standard's Tables
    %  - B219a: for Long Windows
    %  - B219b: for Short Windows
    global B219a;
    global B219b;
    
    %% Per Frame TNS
    switch frameType
        
        case L1_SSC_Frametypes.EightShort
            
            % Get input frame's dimensions
            frameFin_size = size( frameFin );
            
            % Init output arguments
            frameFout = zeros( frameFin_size );
            TNScoeffs = strings( 4, frameFin_size( 2 ) );
            
            % Apply TNS to each sub-MDCT
            for sub_frame_i = 1 : frameFin_size( 2 )
               
                [ frameFout( :, sub_frame_i ), TNScoeffs( :, sub_frame_i ) ] ...
                    = L2_TNS_tns_mono( frameFin( :, sub_frame_i ), B219b );
                
            end
            
        otherwise
            
            % All long-typed frames
            [ frameFout, TNScoeffs ] = L2_TNS_tns_mono( frameFin, B219a );
            
    end
    
end    


% function [frameFout, TNScoeffs] = TNS(frameFin, frameType)
% %UNTITLED Summary of this function goes here
% %   Detailed explanation goes here
%     load('TableB219.mat');
%     p = 4;
% 
%     frameType = L1_SSC_Frametypes.getShortCode( frameType );
%     
%     if strcmp(frameType,'ESH')
%         S = zeros(128, 8);
%         table = B219b;
%         sub = 8;
%     else
%         S = zeros(1024, 1);
%         table = B219a;
%         sub=1;
%     end
%     bands = max(size(table));
%     b_start = table(:,2)+1;
%     b_end = table(:,3)+1;
%     
% %     maxd = max(table(:,4));
% %     T = zeros(bands, maxd);
% %     P = zeros(bands, sub);
%     Q = frameFin.^2;
% %     index = arrayfun(@(s,f)s:f,b_start,b_end,'UniformOutput',false);
% %      for j=1:bands
% %         P(j,:) = sum(Q(b_start(j):b_end(j),:),1);
% %         S(b_start(j):b_end(j),:) = repmat(sqrt(P(j,:), table(j,4),1));
% %      end
%     
%     for i=1:sub
%         f = frameFin(:,i);
%         P = zeros(bands, 1);
%         Q = f.^2;
% %         Q = sum(Q(b_start(:):b_end(:)));
% 
%         for j=1:bands
%             P(j) = sum(Q(b_start(j):b_end(j)));
%             S(b_start(j):b_end(j),i) = sqrt(P(j));
%         end
%     end
%     S = S(:);
%     for k=1023:-1:1
%         S(k) = (S(k)+S(k+1))/2;
%     end
%     for k=2:1024
%         S(k) = (S(k)+S(k-1))/2;
%     end
%     a = zeros(p, 1);
% %     TNScoeffs = zeros(p,1);
%     if strcmp(frameType,'ESH')
%         S = reshape(S, [128 8]);
%         a = zeros(p, 8);
% %         TNScoeffs = zeros(p,8);
%     end
%     frameout = frameFin./S;
% 
% 
%     for i=1:sub
%         f = frameout(:,i);
%         [c, lags] = xcov(f,4);
%         c = c/c(lags==0);
%         r = c(lags>0);
%         r1 = c(lags>=0);
%         r1 = r1(1:end-1);
%         R = toeplitz(r1);
%         a(:, i) = R\r;
%         
% %         for u =1: length(a(:,i))
% %             quant(u)= max(min((round(a(u,i) * 10)/10), 0.85) , -0.75);
% %         end
% % 
% %         a(:,i) = quant;
% %         coef_res = 4;
% %         iqfac = (2^(coef_res-1) - 0.5) / (pi/2.0);
% %         iqfac_m = (2^(coef_res-1) + 0.5) / (pi/2.0);
% %         for j=1:p
% %             if (a(j,i)>=0)
% %                 index(j,i) = round( real(asin( a(j,i) )) *  iqfac );
% %             else 
% %                 index(j,i) = round( real(asin( a(j,i)) ) *  iqfac_m );
% %             end
% %         end
% %         for j=1:p
% %             if (index(j,i)>=0)
% %                 a(j,i) = sin( index(j,i) /  iqfac );
% %             else 
% %                 a(j,i) = sin( index(j,i) /  iqfac_m );
% %             end
% %         end
% 
%         q = quantizeTNS(a(:,i));
%         TNScoeffs(:,i) = q;
%         a(:,i) = unquantizeTNS(q);
% 
% 
% %         TNScoeffs(:,i) = a(:, i);
%         B = [1 -a(:,i)'];
%         A = 1;
%         r = roots(B);
%         in = find(abs(r)>0.98);
%         flag = isempty(in);%isstable(A, B);
%         if ~flag
%             
% %             in = find(abs(r)>0.95);
% %             r(in) = r(in)./(abs(r(in))+0.05);
% %             in = find(abs(r)>1);
% %             r(in) = 1./r(in);
% %             in = find(abs(r)>0.98);
% 
%             r(in) = r(in)./(abs(r(in))+0.15);
%             
%             B = poly(r);
% %             B = 1./B;
% %             coeffs = - B(2:end);
% %             q = quantizeTNS(coeffs);
% %             TNScoeffs(:,i) = q;
% %             B = [1 -unquantizeTNS(q)];
% %             flag = isstable(A, B);
% 
% %             TNScoeffs(:,i) = - B(2:end);
%         end
%         
%         frameFout(:,i) = filter(B,A, frameFin(:,i));
%     end
% end
            
