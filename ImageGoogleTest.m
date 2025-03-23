classdef ImageGoogleTest < matlab.unittest.TestCase
    
    properties
        image_folder = 'images';
        database_name = 'indexed_image_database.mat';
        query_image = '';
    end

    methods(TestClassSetup)
        function setupOnce(testCase)
            buildIndexedImageDatabase(testCase.image_folder, testCase.database_name);

            [file, location] = uigetfile('*.*');
            testCase.query_image = fullfile(location, file);

            figure('Name', 'Query Image');
            imshow(imread(testCase.query_image));
            title('Query Image');

        end
    end
    
    methods(Test)
        % Test methods
        function testRetrieveImagesGCHCS(testCase)
            similarity_threshold = 1250000;
            [similar_images, sorted_distances] = retrieveImagesGCHCS(testCase.query_image, testCase.database_name, similarity_threshold);

            displayImages('GCHCS', similarity_threshold, testCase.query_image, similar_images, sorted_distances)
        end
        function testRetrieveImagesGCHNHI(testCase)
            similarity_threshold = 0;
            [similar_images, sorted_distances] = retrieveImagesGCHNHI(testCase.query_image, testCase.database_name, similarity_threshold);

            displayImages('GCHNHI', similarity_threshold, testCase.query_image, similar_images, sorted_distances)
        end
        function testRetrieveImagesBBCH(testCase)
            similarity_threshold = 0;
            [similar_images, sorted_distances] = retrieveImagesBBCH(testCase.query_image, testCase.database_name, similarity_threshold);

            displayImages('BBCH', similarity_threshold, testCase.query_image, similar_images, sorted_distances)
        end
        function testRetrieveImagesSIFT(testCase)
            similarity_threshold = 0;
            vocab_size = 500;
            [similar_images, sorted_distances] = retrieveImagesSIFT(testCase.query_image, testCase.database_name, vocab_size, similarity_threshold);

            displayImages('SIFT', similarity_threshold, testCase.query_image, similar_images, sorted_distances)
        end
    end
    
end

function displayImages(test_name, similarity_threshold, query_image, similar_images, sorted_distances)
    % Display the top similar images
    top_k = length(similar_images); % Number of top similar images to display
    
    figure('Name', strcat(test_name ,' Matched Images, Similarity Threshold: ', num2str(similarity_threshold)));
    for i = 1:top_k
        subplot(6, 5, i);
        imshow(similar_images{i});
        title(sprintf(strcat(test_name,' Similarity: %.2f'), sorted_distances(i)));
    end
end