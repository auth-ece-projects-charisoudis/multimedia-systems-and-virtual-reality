function Xk = L1_FILTERBANK_MDCT_mdct( xn )
% MDCT Calculates the Modified Discrete Cosine Transform
%   Xk = mdct( xn )
%
%   The signal frame is assumed to be windowed beforehand.
%   Note: Even though the algoritmh utilized yields O( N*lgN + N )
%   complexity by using N-point FFT there are quicker ways to calculate
%   result by expoloiting:
%       1) that the signal is real values ( half values
%   as real and half as imaginary before FFT -> N/2 FFT ) 
%       2) that values are symmetrical ( ends up using N/4 point DFT and
%       thus FFT ) which eventually yields complexity Θ( N/4*lg(N/4) + O(N)
%       ). For more info, see M.Bosi, "Analysis/synthesis system with efficient 
%       oddly stacked single-band TDAC", Patent No. 5,890,106, March 1999
%
%   xn: input signal frame ( length of x must be a integer multiple of 4 )     
%   Xk: MDCT of  xn
%
% ------- mdct.m ------------------------------------------
% Thanos Charisoudis, achariso@ece.auth.gr
% Credits: Marina Bosi
%       - Introduction to Digital Audio Coding and Standards
%       - Chapter 5: Time to Frequency Mapping: MDCT
%          ( algo described @ page 142 - 143 )
% ----------------------------------------------------------
%

%% Check if Marios Athineos's method selected
global AACONFIG
if ( ~isempty( AACONFIG ) && strcmp( AACONFIG.L1.MDCT_METHOD, 'marios' ) )
   
    Xk = mdct4( xn );
    return
    
end

%% Constants
N = size( xn, 1);
K = N/2;
n0 = ( N/2 + 1 ) / 2;
n = 0 : N -1;      % time samples' index
k = 0 : K - 1;     % frequency samples' index

n = n';
k = k';

% Complex Exponentials
c1 = exp( ( -1i * pi * n ) / N );
c2 = exp( ( ( -1i * 2*pi * n0 ) / N ) * (k + 0.5 ) );

%% Pre-twiddle ( multiplication with complex term )
xn_pre_twjddled = c1 .* xn;

%% N-point FFT
Xk_untwiddled = fft( xn_pre_twjddled );

%% Post-twiddle
Xk_post_twiddled = c2 .* Xk_untwiddled( 1:K );

%% Real
Xk = real( Xk_post_twiddled );

end
