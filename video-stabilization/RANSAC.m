function H = RANSAC(p1, p2, match, maxIter, seedSetSize, maxInlierError, goodFitThresh )
%RANSACFit Use RANSAC to find a robust affine transformation
% Input:
%   p1: N1 * 2 matrix, each row is a point
%   p2: N2 * 2 matrix, each row is a point
%   match: M * 2 matrix, each row represents a match [index of p1, index of p2]
%   maxIter: the number of iterations RANSAC will run
%   seedNum: The number of randomly-chosen seed points that we'll use to fit
%   our initial circle
%   maxInlierError: A match not in the seed set is considered an inlier if
%                   its error is less than maxInlierError. Error is
%                   measured as sum of Euclidean distance between transformed 
%                   point1 and point2. You need to implement the
%                   ComputeCost function.
%
%   goodFitThresh: The threshold for deciding whether or not a model is
%                  good; for a model to be good, at least goodFitThresh
%                  non-seed points must be declared inliers.
%   
% Output:
%   H: a robust estimation of affine transformation from p1 to p2
%

    N = size(match, 1);
    if N<3
        error('not enough matches to produce a transformation matrix')
    end
    if ~exist('maxIter', 'var'),
        maxIter = 200;
    end
    if ~exist('seedSetSize', 'var'),
        seedSetSize = ceil(0.2 * N);% split size
    end
    seedSetSize = max(seedSetSize,3);
    if ~exist('maxInlierError', 'var'),
        maxInlierError = 30;
    end
    if ~exist('goodFitThresh', 'var'),
        goodFitThresh = floor(0.7 * N);
    end
    H = eye(3);
    
    % [Reference] https://en.wikipedia.org/wiki/RANSAC#Algorithm
    besterr = Inf;
    alpha = seedSetSize;% split size
    for i = 1 : maxIter
        % step1. Random sample a subset of data
        [trainSet, testSet] = part(match, alpha);
        % trainSet:maybeinliers
        % step2. Compute the model(thisH) by trainSet
        thisH =ComputeAffineMatrix(p1(trainSet(:, 1), :), p2(trainSet(:, 2), :));
        % step3. Find the inliers in testSet: Add those points to alsoinliers
        testSetErr = ComputeError(thisH, p1, p2, testSet);% error of "testSet" fitting to the model "thisH"
        alsoinliers = (testSetErr <= maxInlierError);
        % step4. Repeat the above steps till we have enough inliers
        if sum(alsoinliers(:)) + alpha >= goodFitThresh 
            % if the number of thisInliers(union of trainSet and alsoinliers)>threshold 
            % may have find a good model
            % compute a better model from thisInliers
            thisInliers = [trainSet; testSet(alsoinliers, :)];
            thisH = ComputeAffineMatrix(p1(thisInliers(:, 1), :), p2(thisInliers(:, 2), :));
            thiserr = sum(ComputeError(thisH, p1, p2, thisInliers));
            if thiserr < besterr
                H = thisH;% bestfit = bettermodel
                besterr = thiserr;
            end
        end
    end

    if sum(sum((H - eye(3)).^2)) == 0,
        disp('No RANSAC fit was found.')
    end
end
function dists = ComputeError(H, pt1, pt2, match)
% Compute the error using transformation matrix H to 
% transform the point in pt1 to its matching point in pt2.
%
% Input:
%   H: 3 x 3 transformation matrix where H * [x; y; 1] transforms the point
%      (x, y) from the coordinate system of pt1 to the coordinate system of
%      pt2.
%   pt1: N1 x 2 matrix where each ROW is a data point [x_i, y_i]
%   pt2: N2 x 2 matrix where each ROW is a data point [x_i, y_i]
%   match: M x 2 matrix, each row represents a match [index of pt1, index of pt2]
%
% Output:
%    dists: An M x 1 vector where dists(i) is the error of fitting the i-th
%           match to the given transformation matrix.
%           Error is measured as the Euclidean distance between (transformed pt1)
%           and pt2 in homogeneous coordinates.

    % Convert the input points to homogeneous coordintes.
    P1 = horzcat(pt1,ones(size(pt1,1),1));% N1x3
    P2 = horzcat(pt2,ones(size(pt2,1),1));% N2x3
    P1_H=P1*H';
    P2_M=P2(match(:, 2),:); % Mx3
    P1_HM=P1_H(match(:, 1),:);% Mx3
    dists=sqrt(sum((P2_M-P1_HM).^2,2));% Mx1
    % sum(A,2) is a column vector containing the sum of each row of matrix A
    
    if size(dists,1) ~= size(match,1) || size(dists,2) ~= 1
        error(['wrong format: dists row--' num2str(size(dists,1)) 'match row--'  num2str(size(match,1)) 'dists col--'  num2str(size(dists,2))]);
    end
end

function [D1, D2] = part(D, splitSize)
    idx = randperm(size(D, 1));% random order of the set {1,2,... # of matches}
    D1 = D(idx(1:splitSize), :);% splitSize default=ceil(0.2 * (# of matches))
    D2 = D(idx(splitSize+1:end), :);
end


