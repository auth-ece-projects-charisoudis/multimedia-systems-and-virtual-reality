function [ S, sfc, G ] = AACquantizer( frameF, frameType, SMR )
%AACQUANTIZER Quantizer Stage of AAC Encoder.
% 
%   Calculates auditity threshold and quantizes MDCT coefficients based on
%   the results of the psychocoustic model being applied to this frame.
% 
%   Scalefactors define quantizer quality ( and thus quantization noise )
%   in each of the quantizer bands ( same for our naive AAC codec with the
%   psychoacoustic bands ). Therefore, via sfcs we can move quantization
%   noise to bands with high auditity threshold and produce no audible
%   artiface, whereas in other bands with lower tb quantizer should be more
%   accurate to maintain SNR ( 'N' is the quantization noise ).
% 
%   frameF: MDCT coefficients ( 1024x1 for long frame or 128x8 for short
%   ones )
%   frameType: frame's type
%   SMR: Signal-to-Masking Ratio as outputed from psycho()
%   
%   S: quantized MDCT symbols ( 1024x1 for all frame types )
%   sfc: scalefactors for each band ( DPCM'ed )
%   G: global scalefactor gain ( sfc( 0 ) or a( 0 ) )
% 

    %% Constants
    NBANDS = length( SMR );
    
    %% Load Standard's Tables
    %  - B219a: for Long Windows
    %  - B219b: for Short Windows
    global B219a;
    global B219b;

    %% Check Frame Type
    if ( frameType == L1_SSC_Frametypes.EightShort )
       
        % Prepare output argument
        S = zeros( size( frameF ) );
        sfc = zeros( NBANDS - 1, 8 );
        G = zeros( 1, 8 );
        
        % Loop through all sub-frames
        for subframe_i = 1 : 8
            
            [ S( :, subframe_i ), sfc( :, subframe_i ), G( :, subframe_i ) ] = ...
                L3_AACQUANTIZER_quantizer_mono( ...
                    frameF( :, subframe_i ), ...
                    SMR( :, subframe_i ), ...
                    B219b ...
                );
            
        end
        
        % Linearize S, because output needs to be 1024x1
        S = S( : );
        
    else
        
        [ S, sfc, G ] = L3_AACQUANTIZER_quantizer_mono( ...
            frameF, SMR, B219a ...
        );
        
    end

end


% function [S, sfc, G] = AACquantizer(frameF, frameType, SMR)
% %UNTITLED5 Summary of this function goes here
% %   Detailed explanation goes here
% 
%     frameType = L1_SSC_Frametypes.getShortCode( frameType );
% 
%     load('TableB219.mat');
%     if strcmp(frameType,'ESH')
%         N = 128;
%         sub = 8;
%         table = B219b;
%     else
%         N = 1024;
%         sub = 1;
%         table = B219a;
%     end
%     bands = max(size(table));
%     b_start = table(:,2)+1;
%     b_end = table(:,3)+1;
%     P = zeros(bands, sub);
%     for j = 1:bands
%         P(j,:) = sum(frameF(b_start(j):b_end(j),:).^2, 1);
%     end
% 
%     T = P./SMR;
%     
%     MagicNumber = 0.4054;
%     MQ = 8191;
%     a = zeros(bands,sub);
%     S = zeros(N, sub);
%     X = zeros(N,sub);
%     for i=1:sub
%         m = max(frameF(:,i));
%         m = m^(3/4);
%         ex = 0;
%         a(:,i) = 16/3*log2(m/MQ);
%         completed = zeros(bands,1);
%         for j=1:bands
%             for k=b_start(j):b_end(j)
%                 S(k,i) = sign(frameF(k,i))*floor((abs(frameF(k,i))*2^(-a(j,i)/4))^(3/4) + MagicNumber);
%                 X(k,i) = sign(S(k,i))*abs(S(k,i))^(4/3)*(2^(a(j,i)/4));
%             end
%         end
%         
%         while 1
%            
%             for j=1:bands
%       
%                 P(j,i) = sum((frameF(b_start(j):b_end(j),i) - X(b_start(j):b_end(j),i)).^2);
% 
%                 if ((P(j,i) < T(j,i)) && completed(j)==0)
%                     a(j,i) = a(j,i) + 1;
%                     for k=b_start(j):b_end(j)
%                         S(k,i) = sign(frameF(k,i))*floor((abs(frameF(k,i))*2^(-a(j,i)/4))^(3/4) + MagicNumber);
%                         X(k,i) = sign(S(k,i))*abs(S(k,i))^(4/3)*(2^(a(j,i)/4));
%                     end
%                 else
%                     if (completed(j)==0)
%                         a(j,i) = a(j,i) - 1;
%                         for k=b_start(j):b_end(j)
%                             S(k,i) = sign(frameF(k,i))*floor((abs(frameF(k,i))*2^(-a(j,i)/4))^(3/4) + MagicNumber);
%                             X(k,i) = sign(S(k,i))*abs(S(k,i))^(4/3)*(2^(a(j,i)/4));
%                         end
%                     end
%                     completed(j)=1;
%                 end
%                 if (isequal(completed, ones(bands,1)))
%                     ex =1;
%                     break
%                 end
%                 if max(abs(diff(a(:,i))))>59
%                     ex=1;
%                     break
%                 end
%             end
%             
%             if ex==1
%                 break
%             end
%         end
%     end
%     
% %     sfc(1,:) = a(1,:);
%     G = a(1,:);
%     sfc = diff(a);
% %     sfc(2:bands,:) = diff(a);
%     S = S(:);
%             
% end
