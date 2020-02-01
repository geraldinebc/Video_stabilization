function [up, down, left, right] = FindMaxArtifactPenetration(I)
    % allow RGB or grayscale image
    if size(I,3)==3
        I1 = rgb2gray(I);
    else
        I1 = I;
    end

    nonZeroCols = find(any(I1)); % find non-zero cols
    left = min(nonZeroCols); 
    right = max(nonZeroCols); 
    I2 = I1(:, left : right, :);
    nonZeroRows = find(any(I2, 2)); % find non-zero rows
    up = min(nonZeroRows); 
    down = max(nonZeroRows);
end