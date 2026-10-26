function TRAIN = load_mapset(folderName)
    files = [dir(fullfile(folderName, '*.bmp')); dir(fullfile(folderName, '*.png'))];
    len = length(files);
    TRAIN = cell(2, len);
    for i = 1:len
       img = imread(fullfile(folderName, files(i).name));
       if size(img, 3) == 3
           img = rgb2gray(img);
       end
       if ~islogical(img)
           img = imbinarize(img);
       end
       TRAIN{1, i} = img;
       
       [~, name, ~] = fileparts(files(i).name);
       splitName = split(name, ' '); 
       TRAIN{2, i} = splitName{1}; 
    end
end