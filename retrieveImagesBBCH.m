function [similar_images, similarity_scores] = retrieveImagesBBCH(queryImage, image_database, similarity_threshold)
    % Query image path
    queryImage = imread(queryImage);

    % Load the indexed image database
    data = load(image_database); 

    % Extract the cell array of images
    indexed_images = data.indexed_images;
    numImages = length(indexed_images);

    % Parameters
    numBlocks = 4; % Number of blocks per row/column
    numBins = 16; % Number of bins for the histogram
    
    % Compute histogram for the query image
    queryHist = computeBlockHistogram(queryImage, numBlocks, numBins);
    
    % Initialize similarity array
    % similarities = zeros(numImages, 1);
    matched_image_similarity_score_map = containers.Map('KeyType', 'int32', 'ValueType', 'double');
    
    % Loop through each image in the database
    for i = 1:numImages
        % Compute the block-based color histogram
        currentHist = computeBlockHistogram(indexed_images{i}, numBlocks, numBins);
        
        % Compute similarity (e.g., using histogram intersection)
        similarity = histogramIntersection(queryHist, currentHist);

        if similarity >= similarity_threshold
            matched_image_similarity_score_map(i) = similarity;
        end
    end
    
    % Convert to arrays for sorting
    keys = cell2mat(matched_image_similarity_score_map.keys);
    values = cell2mat(matched_image_similarity_score_map.values);

    [similar_images, similarity_scores] = rankAndRetrieve(indexed_images, keys, values, 'descend');
end

function hist = computeBlockHistogram(image, numBlocks, numBins)
    % Convert image to HSV color space
    hsvImage = rgb2hsv(image);
    
    % Get image dimensions
    [height, width, ~] = size(hsvImage);
    
    % Initialize histogram
    hist = zeros(numBlocks * numBlocks, numBins * 3);
    
    % Compute block size
    blockHeight = floor(height / numBlocks);
    blockWidth = floor(width / numBlocks);
    
    % Compute histograms for each block
    for row = 1:numBlocks
        for col = 1:numBlocks
            % Get block coordinates
            rowStart = (row - 1) * blockHeight + 1;
            rowEnd = min(row * blockHeight, height);
            colStart = (col - 1) * blockWidth + 1;
            colEnd = min(col * blockWidth, width);
            
            % Extract block
            block = hsvImage(rowStart:rowEnd, colStart:colEnd, :);
            
            % Compute histogram for the block
            hHist = imhist(block(:,:,1), numBins) / numel(block(:,:,1));
            sHist = imhist(block(:,:,2), numBins) / numel(block(:,:,2));
            vHist = imhist(block(:,:,3), numBins) / numel(block(:,:,3));
            
            % Concatenate histograms
            blockIndex = (row - 1) * numBlocks + col;
            hist(blockIndex, :) = [hHist' sHist' vHist'];
        end
    end
    % Flatten the histogram to a vector
    hist = hist(:)';
end

function similarity = histogramIntersection(hist1, hist2)
    % Compute the intersection of two histograms
    similarity = sum(min(hist1, hist2), 'all');
end
