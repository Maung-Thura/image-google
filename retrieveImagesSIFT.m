function [similar_images, sorted_distances] = retrieveImagesSIFT(query_image, image_database, vocab_size, similarity_threshold)
    % Load the indexed image database
    data = load(image_database); 
    % Extract the cell array of images
    indexed_images = data.indexed_images;
    
    % Build the visual vocabulary
    [vocab, allDescriptors] = buildVocabulary(indexed_images, vocab_size);
    
    % Compute histograms for the database images
    databaseHists = computeImageHistograms(indexed_images, vocab);
   
    queryImage = imread(query_image);
       
    % Retrieve and display the most similar images
    queryDescriptors = extractSIFTFeatures(queryImage);
    [~, visualWords] = pdist2(vocab, queryDescriptors, 'euclidean', 'Smallest', 1);
    queryHist = histcounts(visualWords, 1:size(vocab, 1) + 1);
    
    matched_image_similarity_map = containers.Map('KeyType', 'int32', 'ValueType', 'double');
    
    for i = 1:length(indexed_images)
        similarity = sum(min(queryHist, databaseHists(i, :)));
        if similarity >= similarity_threshold
            matched_image_similarity_map(i) = similarity;
        end
    end

    [similar_images, sorted_distances] = rankAndRetrieveImproved(indexed_images, matched_image_similarity_map);
end

function descriptors = extractSIFTFeatures(image)
    grayImage = rgb2gray(image);
    points = detectSIFTFeatures(grayImage);
    [features, ~] = extractFeatures(grayImage, points);
    descriptors = double(features);
end

function [vocab, allDescriptors] = buildVocabulary(imageFiles, vocabSize)
    allDescriptors = [];
    
    for i = 1:length(imageFiles)
        if ischar(imageFiles{i}) || isstring(imageFiles{i})
            image = imread(imageFiles{i});
        else
            image = imageFiles{i};
        end
        descriptors = extractSIFTFeatures(image);
        allDescriptors = [allDescriptors; descriptors];
    end
    
    [~, vocab] = kmeans(allDescriptors, vocabSize, 'MaxIter', 1000);
end

function histograms = computeImageHistograms(imageFiles, vocab)
    vocabSize = size(vocab, 1);
    histograms = zeros(length(imageFiles), vocabSize);
    
    for i = 1:length(imageFiles)
        if ischar(imageFiles{i}) || isstring(imageFiles{i})
            image = imread(imageFiles{i});
        else
            image = imageFiles{i};
        end
        descriptors = extractSIFTFeatures(image);
        [~, visualWords] = pdist2(vocab, descriptors, 'euclidean', 'Smallest', 1);
        histograms(i, :) = histcounts(visualWords, 1:vocabSize+1);
    end
end
