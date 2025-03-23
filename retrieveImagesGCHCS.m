function [similar_images, sorted_distances] = retrieveImagesGCHCS(query_image, image_database, similarity_threshold)
    % Load the indexed image database
    data = load(image_database); 

    % Extract the cell array of images
    indexed_images = data.indexed_images;
    
    % Read the query image
    query_image = imread(query_image);
    
    % Convert the image to HSV color space (Hue, Saturation, Value)
    queryHSV = rgb2hsv(query_image);
    
    % Number of bins for each color channel (Hue, Saturation, Value)
    nBins = 32;
    
    % Extract and normalize the color histogram of the query image
    queryHistH = imhist(queryHSV(:,:,1), nBins) / numel(queryHSV(:,:,1));
    queryHistS = imhist(queryHSV(:,:,2), nBins) / numel(queryHSV(:,:,2));
    queryHistV = imhist(queryHSV(:,:,3), nBins) / numel(queryHSV(:,:,3));
    queryHist = [queryHistH; queryHistS; queryHistV];
    
    % Function to calculate Chi-Square distance between histograms
    chiSquareDistance = @(hist1, hist2) sum(((hist1 - hist2).^2) ./ (hist1 + hist2 + eps));
    
    % Pre-allocate array to store distances
    distances = zeros(1, length(indexed_images));
    matched_image_distance_map = containers.Map('KeyType', 'int32', 'ValueType', 'double');
    
    % Loop through each image in the database and calculate Chi-Square distance
    for i = 1:length(indexed_images)
        image = indexed_images{i};
        imageHSV = rgb2hsv(image);
        imageHistH = imhist(imageHSV(:,:,1), nBins) / numel(imageHSV(:,:,1));
        imageHistS = imhist(imageHSV(:,:,2), nBins) / numel(imageHSV(:,:,2));
        imageHistV = imhist(imageHSV(:,:,3), nBins) / numel(imageHSV(:,:,3));
        imageHist = [imageHistH; imageHistS; imageHistV];
        
        distance = chiSquareDistance(queryHist, imageHist);
        
        % A lower chi-square value indicates greater similarity between the two images.
        if distance <= similarity_threshold
            matched_image_distance_map(i) = distance;
        end
    end
    
    % Convert the map to arrays for sorting and retrieving
    image_indices = cell2mat(keys(matched_image_distance_map));
    similarity_scores = cell2mat(values(matched_image_distance_map));
    
    [similar_images, sorted_distances] = rankAndRetrieve(indexed_images, image_indices, similarity_scores, 'ascend');
end
