function buildIndexedImageDatabase(image_folder, database_name)
    % Get a list of all image files in the folder
    image_files = dir(fullfile(image_folder, '*.jpeg'));
    
    % Initialize cell array to store images
    indexed_images = cell(numel(image_files), 1);
    
    % Loop through each image file
    for i = 1:numel(image_files)
        % Read the image
        image_path = fullfile(image_folder, image_files(i).name);
        image = imread(image_path);
        
        
        % Store the image in the cell array
        indexed_images{i} = image;
    end
    
    % Save the cell array to a MAT file
    save(database_name, 'indexed_images');
end