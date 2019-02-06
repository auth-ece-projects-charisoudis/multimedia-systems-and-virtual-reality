function xn = L1_FILTERBANK_MDCT_imdct( Xk )
% Inverse MDCT: Calculates the Inverse Modified Discrete Cosine Transform
%   xn = imdct( Xk )
%
%   Use either a Sine or a Kaiser-Bessel Derived window (KBDWin) with 
%   50% overlap for perfect TDAC reconstruction.
%   Remember that MDCT coefs are symmetric: y(k)=-y(N-k-1) so the full
%   matrix (N) of coefs is: yf = [y;-flipud(y)];
% 
%   Xk: MDCT of  xn ( langth N/2 )
%   xn: output signal frame ( length N )    
%
% ------- imdct.m ------------------------------------------
% Thanos Charisoudis, achariso@ece.auth.gr
%  
% ----------------------------------------------------------
%

%% Check if Marios Athineos's method selected
global AACONFIG
if ( ~isempty( AACONFIG ) && strcmp( AACONFIG.L1.MDCT_METHOD, 'marios' ) )
   
    xn = imdct4( Xk );
    return
    
end

%% Constants
K = size( Xk, 1);
N = K * 2;
n0 = ( N/2 + 1 ) / 2;
n = 0 : N -1;       % time samples' index
% k = 0 : K -1;       % frequency samples' index

n = n';

% Complex Exponentials
c1 = exp( ( ( 1i * 2*pi * n0 ) / N ) * n );
c2 = exp( ( ( 1i * pi ) / N ) * ( n + n0 ) );

%% Pre-twiddle ( multiplication with complex term )
Xk_extended = [ Xk; -flipud( Xk ) ];
Xk_pre_twjddled = c1 .* Xk_extended;

%% N-point Inverse FFT
xn_untwiddled = ifft( Xk_pre_twjddled );

%% Post-twiddle
xn_post_twiddled = c2 .* xn_untwiddled;

%% Real
xn = 2 * real( xn_post_twiddled );

end
