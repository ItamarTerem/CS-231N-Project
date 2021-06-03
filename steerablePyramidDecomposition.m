function [filterResponse] = steerablePyramidDecomposition(im,varargin)
 
    %% Parse Input
    p = inputParser();

    pyrTypes = {'octave', 'halfOctave', 'smoothHalfOctave', 'quarterOctave'}; 
    checkPyrType = @(x) find(ismember(x, pyrTypes));
    defaultPyrType = 'octave';
    defaultSigma = 0;
    defaultScale = 1;
    
    addOptional(p, 'pyrType', defaultPyrType, checkPyrType);
    addOptional(p,'sigma', defaultSigma, @isnumeric);   
    addOptional(p, 'scaleImage', defaultScale);
    
    parse(p, varargin{:});

    pyrType            = p.Results.pyrType;
    sigma              = p.Results.sigma;
    scaleImage         = p.Results.scaleImage;

    %% Compute spatial filters        
    [h,w] = size(im);
    ht = maxSCFpyrHt(zeros(h,w));
    switch pyrType
        case 'octave'
            filters = getFilters([h w], 2.^[0:-1:-ht],4);
            fprintf('Using octave bandwidth pyramid\n');        
        case 'halfOctave'            
            filters = getFilters([h w], 2.^[0:-0.5:-ht], 16,'twidth', 0.75);
            fprintf('Using half octave bandwidth pyramid\n'); 
        case 'smoothHalfOctave'
            filters = getFiltersSmoothWindow([h w], 8, 'filtersPerOctave', 2);           
            fprintf('Using half octave pyramid with smooth window.\n');
        case 'quarterOctave'
            filters = getFiltersSmoothWindow([h w], 8, 'filtersPerOctave', 4);
            fprintf('Using quarter octave pyramid.\n');
        otherwise 
            error('Invalid Filter Types');
    end
    
    
    buildLevel = @(im_dft, k) ifft2(ifftshift(filters{k}.*im_dft));
  
    numLevels = numel(filters);        
    imdFFT = fftshift(fft2(im));
    
    for level = 1:numLevels-1
        filterResponse(:,:,level)= buildLevel(imdFFT,level);    
    end
 
     filterResponse(:,:,numLevels) =  ifft2(ifftshift(imdFFT.*filters{end}.^2));
     
end





