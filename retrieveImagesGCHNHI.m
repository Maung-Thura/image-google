function [similar_images, similarity_scores] = retrieveImagesGCHNHI(queryimage, image_database, similarity_threshold)
    % Load the indexed image database
    data = load(image_database); 
    % Extract the cell array of images
    indexed_images = data.indexed_images;

    % Load the query image
    query_image = imread(queryimage); 

    % Store similarity scores and corresponding image indices
    image_indices = [];
    similarity_scores = [];
    
    for i = 1:size(indexed_images, 1)
        similarity_score = compareHistograms(indexed_images{i}, query_image);

        % for normalized histogram, 1 is most similar and 0 is no similar
        if similarity_score >= similarity_threshold
            image_indices = [image_indices; i];
            similarity_scores = [similarity_scores; similarity_score];
        end
    end

    % Rank and retrieve similar images
    [similar_images, similarity_scores] = rankAndRetrieve(indexed_images, image_indices, similarity_scores, 'descend');
end

function similarity = compareHistograms(image1, image2)
    % Compute the histograms for each color channel
    numBins = 256;

    hist1_r = imhist(image1(:,:,1), numBins);
    hist1_g = imhist(image1(:,:,2), numBins);
    hist1_b = imhist(image1(:,:,3), numBins);

    hist2_r = imhist(image2(:,:,1), numBins);
    hist2_g = imhist(image2(:,:,2), numBins);
    hist2_b = imhist(image2(:,:,3), numBins);
    
    % Normalize the histograms
    hist1_r = hist1_r / sum(hist1_r);
    hist1_g = hist1_g / sum(hist1_g);
    hist1_b = hist1_b / sum(hist1_b);

    hist2_r = hist2_r / sum(hist2_r);
    hist2_g = hist2_g / sum(hist2_g);
    hist2_b = hist2_b / sum(hist2_b);
    
    % Calculate the histogram intersection
    similarity_r = sum(min(hist1_r, hist2_r));
    similarity_g = sum(min(hist1_g, hist2_g));
    similarity_b = sum(min(hist1_b, hist2_b));
    
    % Average similarity for the three channels
    similarity = (similarity_r + similarity_g + similarity_b) / 3;
end
