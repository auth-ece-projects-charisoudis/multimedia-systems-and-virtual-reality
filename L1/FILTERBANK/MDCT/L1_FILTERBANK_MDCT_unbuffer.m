function y = L1_FILTERBANK_MDCT_unbuffer( frames )
%UNBUFFER Summary of this function goes here
%   Detailed explanation goes here

%% Constants
[WINDOW_LENGTH, NFRAMES] = size( frames );
OVERLAP_LENGTH = WINDOW_LENGTH / 2;

% Length of final vector
NSAMPLES = NFRAMES*OVERLAP_LENGTH + OVERLAP_LENGTH;

%% Overlap-and-Add Loop ( Using original technique - described in M.Bosi's book )
% % f1 = frames( :, 1 );
% f1 = zeros( WINDOW_LENGTH, 1 );
% y = [f1; zeros( NSAMPLES, 1 )];
% for frame_i = 1:NFRAMES - 1
%     
%     % get write position
%     y_pos_start = ( frame_i - 1 ) * OVERLAP_LENGTH + 1;
%     y_pos_stop = y_pos_start + WINDOW_LENGTH - 1;
%     
%     % get new frame
%     frame = frames( :, frame_i + 1 );
%     
%     % add 1st half and copy 2nd half
%     y( y_pos_start:y_pos_stop ) = y( y_pos_start:y_pos_stop )  + frame;
%     
% end
% 
% y( y_pos_start + OVERLAP_LENGTH:end ) = frames( :, NFRAMES );
% y( 1:WINDOW_LENGTH ) = y( 1:WINDOW_LENGTH ) + frames( :, NFRAMES );

%% Using Marios Athineos' techinque ( linunframe.m )
% Advance length used in the sparse() trick
adv  = NFRAMES*OVERLAP_LENGTH;
% Sample index
sidx = (1:(NFRAMES*WINDOW_LENGTH)).';
% Frame index
fidx = adv*(0:(NFRAMES-1));
fidx = fidx(ones(WINDOW_LENGTH,1),:);

% This is our linear index
lidx = sidx + fidx(:);
clear sidx fidx;
% Create 2D subscripts based on NSAMPLES
%[i,j] = ind2sub2(NSAMPLES,lidx); %(my version is faster)
[i,j] = ind2sub(NSAMPLES,lidx); %(built-in)
clear lidx;

% Don't try this with full matrices !!! :)
sp = sparse(i,j,frames,NSAMPLES,NFRAMES);

% This, believe or not, is overlap add (OLA) !!!
y = full(sum(sp,2));

%% Extract Useful Samples
y = y( OVERLAP_LENGTH + 1:end - OVERLAP_LENGTH );

end
