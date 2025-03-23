function image_database_indexing_color_histogram(image_folder, query_image_path)
    % Step 1: Load images from the directory
    image_files = dir(fullfile(image_folder, '*.jpeg'));
    num_images = length(image_files);
    
    % Step 2: Extract color histograms from each image
    image_histograms = cell(num_images, 1);
    for i = 1:num_images
        img = imread(fullfile(image_folder, image_files(i).name));
        image_histograms{i} = compute_color_histogram(img);
    end
    
    % Save histograms to use them in the search function
    save('image_histograms.mat', 'image_histograms', 'image_files');
    
    % If a query image is provided, search for similar images
    if nargin > 1
        search_similar_images_color_histogram(query_image_path);
    end
end

function hist = compute_color_histogram(img)
    % Convert the image to HSV color space
    hsv_img = rgb2hsv(img);
    % Compute the histogram for each channel
    h_hist = imhist(hsv_img(:,:,1), 50);
    s_hist = imhist(hsv_img(:,:,2), 50);
    v_hist = imhist(hsv_img(:,:,3), 50);
    % Concatenate the histograms to form a feature vector
    hist = [h_hist; s_hist; v_hist];
    % Normalize the histogram
    hist = hist / sum(hist);
end

function search_similar_images_color_histogram(query_image_path)
    % Load the previously saved histograms and image files
    load('image_histograms.mat', 'image_histograms', 'image_files');
    num_images = length(image_files);
    
    % Load and compute the color histogram of the query image
    query_img = imread(query_image_path);
    query_hist = compute_color_histogram(query_img);
    
    % Compute similarity between query image histogram and database image histograms
    similarity_scores = zeros(num_images, 1);
    for i = 1:num_images
        similarity_scores(i) = sum(min(query_hist, image_histograms{i}));
    end
    
    % Sort images based on similarity scores
    [sorted_scores, sorted_indices] = sort(similarity_scores, 'descend');
    
    % Display the top 5 most similar images
    top_n = 5;
    fprintf('Top %d similar images to %s:\n', top_n, query_image_path);
    for i = 1:min(top_n, num_images)
        fprintf('%s with similarity score: %f\n', image_files(sorted_indices(i)).name, sorted_scores(i));
        imshow(imread(fullfile(image_files(sorted_indices(i)).folder, image_files(sorted_indices(i)).name)));
        title(sprintf('Similarity score: %f', sorted_scores(i)));
        pause(1);
    end
end

image_database_indexing_color_histogram('images', 'query_images/coccoon_tower.jpeg')
