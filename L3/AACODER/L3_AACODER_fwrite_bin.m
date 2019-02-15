function L3_AACODER_fwrite_bin( binSeq, fNameBin )
%L3_AACODER_FWRITE_BIN Summary of this function goes here
%   Detailed explanation goes here

    %% Create file
    fBin = fopen( fNameBin, 'w' );
    
    %% Compressed Struct Data
    %   Per frame:
    %   - frameType:        bin( 2 )
    %   - winType:          bin( 1 )
    %
    %   Per frame channel:
    %   - ch{c}.stream:     bin( ~ )
    %   - ch{c}.codebook:   bin( 4 )
    %   - ch{c}.sfc:        bin( ~ )
    %   - ch{c}.G:          sinble( 32 )
    %   - ch{c}.TNScoeffs:  bin( 16 )
    
    STREAM_PART_NBITS = 32;
    
    %% Begin writing process
    %   - each new frame is written in a new line
    for frame_i = 1 : length( binSeq )
       
        %   - frameType
        fwrite( fBin, bin2dec( binSeq( frame_i ).frameType ), 'ubit2' );
        
        %   - winType
        fwrite( fBin, bin2dec( binSeq( frame_i ).winType ), 'ubit1' );
        
        for channel = 'lr'
           
            %%   - stream: split into uint32 numbers and write them to file
            %       i) write stream's total length ( 12 bits - bin( 12 ) )
            stream_len = length( binSeq( frame_i ).(['ch' channel]).stream );
            fwrite( fBin, stream_len, 'ubit12' );
            %       ii) write stream as unsigned integers ( uint{STREAM_PART_NBITS} )
            stream_len_trimmed = floor( stream_len / STREAM_PART_NBITS ) * STREAM_PART_NBITS;
            stream_parts = reshape( ...
                binSeq( frame_i ).(['ch' channel]).stream( 1 : stream_len_trimmed ), ...
                [stream_len_trimmed / STREAM_PART_NBITS, STREAM_PART_NBITS] ...
            );
            for stream_part_i = 1 : size( stream_parts, 1 )
               
                fwrite( fBin, bin2dec( stream_parts( stream_part_i, : ) ), ['ubit' num2str( STREAM_PART_NBITS )] );
                
            end            
            %       iii) write remaining stream bits
            if ( stream_len > stream_len_trimmed )
            
                fwrite( fBin, bin2dec( binSeq( frame_i ).(['ch' channel]).stream( stream_len_trimmed + 1 : stream_len ) ), ['ubit' num2str( stream_len - stream_len_trimmed )] );
                
            end
            
            %%   - sfc: split into uint32 numbers and write them to file
            % for Long: [len][sfc]
            % for ESH : [len1][sfc1] ... [len8][sfc8]
            for subframe_i = 1 : size( binSeq( frame_i ).(['ch' channel]).sfc, 1 )
                
                %       i) write sfc's total length ( 10 bits - bin( 10 ) )
                sfc = char( binSeq( frame_i ).(['ch' channel]).sfc( subframe_i, : ) );
                sfc_len = length( sfc );
                fwrite( fBin, sfc_len, 'ubit10' );
                
                %       ii) write sfc as unsigned integers ( uint{STREAM_PART_NBITS} )
                sfc_len_trimmed = floor( sfc_len / STREAM_PART_NBITS ) * STREAM_PART_NBITS;
                sfc_parts = reshape( ...
                    sfc( 1 : sfc_len_trimmed ), ...
                    [sfc_len_trimmed / STREAM_PART_NBITS, STREAM_PART_NBITS] ...
                );
                for sfc_part_i = 1 : size( sfc_parts, 1 )

                    fwrite( fBin, bin2dec( sfc_parts( sfc_part_i, : ) ), ['ubit' num2str( STREAM_PART_NBITS )] );

                end            
                %       iii) write remaining sfc bits
                if ( sfc_len > sfc_len_trimmed )
                
                    fwrite( fBin, bin2dec( sfc( sfc_len_trimmed + 1 : sfc_len ) ), ['ubit' num2str( sfc_len - sfc_len_trimmed )] );
                    
                end
            
            end
            
            %%binSeq( frame_i ).(['ch' channel]).TNScoeffscodebook: bin( 4 )
            fwrite( fBin, bin2dec( binSeq( frame_i ).(['ch' channel]).codebook ), 'ubit4' );
            
            %%    - G: signle( 32 )
            for subframe_i = 1 : length( binSeq( frame_i ).(['ch' channel]).G )
                
                fwrite( fBin, binSeq( frame_i ).(['ch' channel]).G( subframe_i ), 'single' );
                
            end
                
            %%    - TNS Coefficients: either bin( 16 ) or bin( 128 )
            % write as one or eight consecutive 16bit unsigned integers
            tns_len = length( binSeq( frame_i ).(['ch' channel]).TNScoeffs );
            tns_parts = reshape( ...
                binSeq( frame_i ).(['ch' channel]).TNScoeffs, ...
                [tns_len / 16, 16] ...
            );
            for tns_part_i = 1 : size( tns_parts, 1 )
               
                fwrite( fBin, bin2dec( tns_parts( tns_part_i, : ) ), 'ubit16' );
                
            end
            
        end
        
        % Write end-of-frame delimiter ( \r\n )
        fwrite( fBin, '\r', 'char*1' );
        fwrite( fBin, '\n', 'char*1' );
        
    end
    
    %% Close file
    fclose( fBin );
    
end

