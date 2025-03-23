function [similar_images, sorted_similarities] = rankAndRetrieveImproved(indexed_images, matched_image_similarity_map)
    % Convert to arrays for sorting
    similarityArray = cell2mat(values(matched_image_similarity_map));
    imageIndexArray = cell2mat(keys(matched_image_similarity_map));
    
    % Ranking
    [sorted_similarities, sortIndex] = sort(similarityArray, 'descend');
    
    % Retrieve the sorted images
    sorted_image_indexes = imageIndexArray(sortIndex);
    
    similar_images = cell(1, length(sorted_image_indexes));
    
    % Retrieval limit
    limit = length(sorted_image_indexes);
    
    for i = 1:limit
        similar_images{i} = indexed_images{sorted_image_indexes(i)};
    end
    
    % Return only the top sorted similarities
    sorted_similarities = sorted_similarities(1:limit);
end
