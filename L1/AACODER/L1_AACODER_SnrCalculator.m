classdef L1_AACODER_SnrCalculator
    %SNR Class to hold the SNR of each channel and the mean SNR for the
    %audio coding technique used.
    
    properties( Constant )
       
        meanMethod = 'rms'
        
    end
    
    properties
        
        computeMethod
        
        channelLeft
        channelRight
        mean
        
    end
    
    methods
        
        function obj = L1_AACODER_SnrCalculator( original, reconstructed, method )
            %SNR Construct an instance of this class
            %   1) Compute noise ( reconstructed - original )
            %   2) Compute original-to-noise ratio for each channel
            %   3) Compute mean SNR
            %
            %   original: original 2-channel signal's samples
            %   reconstructed: reconstructed 2-channel signal's samples
            %   method: method used ( either 'builtin' or 'default' )
            %
            
            % Set compute method
            if ( nargin == 2 )
                
                obj.computeMethod = 'default';
                
            else
                
                switch ( method )
                    
                    case 'builtin'
                        
                        obj.computeMethod = 'builtin';
                        
                    otherwise
                        
                        obj.computeMethod = 'default';
                        
                end
                
            end
            
            % Noise
            noise_left = original( :, 1 ) - reconstructed( :, 1 );
            noise_right = original( :, 2 ) - reconstructed( :, 2 );
            
            % SNR for each channel
            obj.channelLeft = L1_AACODER_SnrCalculator.mono( ...
                original( :, 1 ), noise_left, obj.computeMethod ...
            );
            obj.channelRight = L1_AACODER_SnrCalculator.mono( ...
                original( :, 2 ), noise_right, obj.computeMethod ...
            );
            
            % Mean SNR ( using rms: should be polarized towards edge values
            % )
            obj.mean = sign( obj.channelLeft ) * feval( ...
                L1_AACODER_SnrCalculator.meanMethod, ...
                [ obj.channelLeft; obj.channelRight ] ...
            );
            
        end
        
    end
    
    methods (Static)
        
        function mono = mono( original, noise, method )
            %MONO Computes the SNR for a single channel ( using either
            %MATLAB's builtin snr() or a custom implementation )
            %
            %   original: initial channel samples
            %   noise: reconstructed - original for this channel
            %
            
            if ( strcmp( method, 'builtin' ) )
                
                mono = snr( original, noise );
            
            else
                
                % power of original signal ( doubled )
                Ps = sumsqr( original );
                % power of noise ( doubled )
                Pn = sumsqr( noise );
                % compute snr
                mono = 10 * log10( Ps / Pn );
            
            end
                
        end
        
    end
    
end

