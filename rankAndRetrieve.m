function [similar_images, sorted_similarities] = rankAndRetrieve(indexed_images, image_indices, similarity_scores, sort_direction)
    % Convert to arrays for sorting
    similarityArray = similarity_scores;
    imageIndexArray = image_indices;
    
    % Ranking
    [sorted_similarities, sortIndex] = sort(similarityArray, sort_direction);
    
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