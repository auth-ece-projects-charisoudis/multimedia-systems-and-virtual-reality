function [ SNR, SNR_L, SNR_R ] = L1_AACORDER_snr( original, reconstructed )
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

    %% Split Channels
    % original
    origianl_left_channel = original( :, 1 );
    origianl_right_channel = original( :, 2 );
    % reconstructed
    reconstructed_left_channel = reconstructed( :, 1 );
    reconstructed_right_channel = reconstructed( :, 2 );    

    %% Left Channel
%     % power of original signal
%     Ps = sum( origianl_left_channel .* origianl_left_channel / 2);
%     % power of noise
%     noise = reconstructed_left_channel - origianl_left_channel;
%     Pn = sum( noise .* noise / 2 );
%     % signal to noise ratio
%     SNR_L = 10 * log( Ps / Pn );
    SNR_L = snr( origianl_left_channel, reconstructed_left_channel - origianl_left_channel );

    %% Right Channel
%     % power of original signal
%     Ps = sum( origianl_right_channel .* origianl_right_channel / 2);
%     % power of noise
%     noise = reconstructed_right_channel - origianl_right_channel;
%     Pn = sum( noise .* noise / 2 );
%     % signal to noise ratio
%     SNR_R = 10 * log( Ps / Pn );
    SNR_R = snr( origianl_right_channel, reconstructed_right_channel - origianl_right_channel );
    
    %% Mean SNR
    SNR = sqrt( sumsqr( [SNR_L, SNR_R] ) );
    
end

