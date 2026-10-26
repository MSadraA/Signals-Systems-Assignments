function [L, Ne] = mysegmentation(image)
    cc = bwconncomp(image);
    L = zeros(size(image));
    Ne = cc.NumObjects;
    for i = 1:Ne
        L(cc.PixelIdxList{i}) = i;
    end
end