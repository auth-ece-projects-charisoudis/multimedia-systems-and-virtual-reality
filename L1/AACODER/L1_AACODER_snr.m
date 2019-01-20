function [ SNR, SNR_L, SNR_R ] = L1_AACODER_snr( original, reconstructed )
%L1_AACORDER_SNR calculates SNR between the original and the reconstructed
%signal.
% 
%   original: original ( input ) signal as a vector of samples
%   reconstructed: the signal after the encoding / decoding process as a
%   vector of samples
% 
%   SNR: SNR in decibels ( mean of L, R channel )
%   SNR_L: left channel SNR
%   SNR_R: left channel SNR
%

    % SNR Class Object
    snrOb = Snr( original, reconstructed );
    
    % Parse result
    SNR_L = snrOb.channelLeft;
    SNR_R = snrOb.channelRight;
    SNR = snrOb.mean;
    
end

