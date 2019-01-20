classdef SNR
    %SNR Class to hold the SNR of each channel and the mean SNR for the
    %audio coding technique used.
    
    properties( Constant )
       
        USE_BUILTIN = false
        
    end
    
    properties
        
        channelLeft
        channelRight
        mean
        
    end
    
    methods
        
        function obj = SNR( original, reconstructed )
            %SNR Construct an instance of this class
            %   1) Compute noise ( reconstructed - original )
            %   2) Compute original-to-noise ratio for each channel
            %   3) Compute mean SNR
            
            % Noise
            noise_left = original( :, 1 ) - reconstructed( :, 1 );
            noise_right = original( :, 2 ) - reconstructed( :, 2 );
            
            % SNR for each channel
            obj.channelLeft = SNR.mono( original( :, 1 ), noise_left );
            obj.channelRight = SNR.mono( original( :, 2 ), noise_right );
            
            % Mean SNR ( using rms: should be polarized towards edge values
            % )
            obj.mean = sign( obj.channelLeft ) * ...
                rms( [ obj.channelLeft; obj.channelRight ] );
            
        end
        
    end
    
    methods (Static)
        
        function mono = mono( original, noise )
            %MONO Computes the SNR for a single channel ( using either
            %MATLAB's builtin snr() or a custom implementation )
            %
            %   original: initial channel samples
            %   noise: reconstructed - original for this channel
            %
            
            if ( SNR.USE_BUILTIN )
                
                mono = snr( original, noise );
            
            else
                
                % power of original signal
                Ps = sum( original .* original / 2);
                % power of noise
                Pn = sum( noise .* noise / 2 );
                % compute snr
                mono = 10 * log10( Ps / Pn );
            
            end
                
        end
        
    end
    
end

