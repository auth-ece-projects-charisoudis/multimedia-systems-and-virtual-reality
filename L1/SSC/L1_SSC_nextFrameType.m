function frame_type = L1_SSC_nextFrameType( frame )
%L1_SSC_NEXTFRAMETYPE Predicts next frame's type by seeing the energy
%contained in the frame as well as its derivative.
%   
%   frame: the next frame as a vector of time samples
%   frame_type: result type ( either 'ESH' or 'ELSE' )   
%

    %% Create Filter ( remove edge frequency compoenents )
    % filter coefficients
    b = 0.7548 * [1 -1];
    a = [1 -0.5095];

    % filter the frame
    frame_filtered = filter( b, a, frame );
    
    %% Split frame to Sub-Regions
    sub_regions = buffer( ...
        frame_filtered( 448 + 129 : 2048 - 448 ),  ...
        128 ...
    );

    %% Estimate each Region's Energy
    region_energies = rssq( sub_regions ) .^ 2;
    
    region_energies_cumsum = cumsum( region_energies ) - region_energies;
    region_energies_cumsum( 1 ) = region_energies( 1 );
    region_attack_values = ( ( 1:length( region_energies  ) ) .* region_energies ) ./ region_energies_cumsum;

    %% Decide based on boundaries
    if ( ...
        isempty ( find( ( ...
            ( region_energies > 1e-3 ) .* ...
            ( region_attack_values > 10 ) ...
        ), 1 ) ) ...
    ) 
        frame_type = L1_SSC_Frametypes.Other;
    else
        frame_type = L1_SSC_Frametypes.EightShort;        
    end

    clear sub_regions;
    clear frame_filtered;
    
end

