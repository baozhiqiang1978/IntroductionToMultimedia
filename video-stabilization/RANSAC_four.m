function H = RANSAC_four(p1, p2, p3, p4, match1,match2,match3,store_H1, store_H2,output1,output2,output3,output4,maxIter, seedSetSize, maxInlierError, goodFitThresh)
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

    N = size(match3, 1);
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
        maxInlierError = 30;% default: 30
    end
    if ~exist('goodFitThresh', 'var'),
        goodFitThresh = floor(0.4* N);% default :0.7*N
    end
    H = eye(3);
    
    % [Reference] https://en.wikipedia.org/wiki/RANSAC#Algorithm
    besterr = Inf;
    alpha = seedSetSize;% split size
    size_match3  = size(match3);
    for i = 1 : maxIter
        % step1. Random sample a subset of data
        [trainSet, testSet] = part(match3, alpha);
        %alpha
        % trainSet:maybeinliers
        % step2. Compute the model(thisH) by trainSet
        thisH =ComputeAffineMatrix(p3(trainSet(:, 1), :), p4(trainSet(:, 2), :));
        % step3. Find the inliers in testSet: Add those points to alsoinliers

        %output3
        for i = 1:length(testSet(:,1))
            final(i,:) = p3(testSet(i,1),:);
            %pointsAL(indexPairs1(i,2),:)
        end
        
        testSetErr = ComputeError(thisH,store_H1,store_H2, p1, p2, p3, p4,match1,match2,testSet,output1,output2,output3,final);% error of "testSet" fitting to the model "thisH"
%         size(testSet)
%         size(testSetErr)
        alsoinliers = (testSetErr <= maxInlierError);
        % step4. Repeat the above steps till we have enough inliers
        if sum(alsoinliers(:)) + alpha >= goodFitThresh 
            % if the number of thisInliers(union of trainSet and alsoinliers)>threshold 
            % may have find a good model
            % compute a better model from thisInliers
            thisInliers = [trainSet; testSet(alsoinliers, :)];
            thisH = ComputeAffineMatrix(p3(thisInliers(:, 1), :), p4(thisInliers(:, 2), :));
            %disp(['size p3=' num2str(size(p3))]);
            %disp([' size p4=' num2str(size(p4))]);
            %disp([' thisH= ' num2str(size(thisH))]);
            %disp([' thisInliers= ' num2str(size(thisInliers))]);
            thiserr = sum( ComputeError(thisH,store_H1,store_H2, p1, p2, p3, p4,match1,match2,testSet,output1,output2,output3,final));
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
function dists = ComputeError(H,store_H1,store_H2, pt1, pt2,pt3, pt4,match1,match2,testSet,output1,output2,output3,output4)
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
    %disp(['size=' num2str(size(pt2))]);
    %disp(pt2);
    P2 = horzcat(pt2,ones(size(pt2,1),1));% N2x3
    P3 = horzcat(pt3,ones(size(pt3,1),1));% N1x3
    P4 = horzcat(pt4,ones(size(pt4,1),1));% N2x3
    %
    P1_H=P1*store_H1';
    P2_M=P2(match1(:, 2),:); % Mx3
    P1_HM=P1_H(match1(:, 1),:);% Mx3
    dists1=sqrt(sum((P2_M-P1_HM).^2,2));% Mx1
    
    P2_H=P2*store_H2';
    P3_M=P3(match2(:, 2),:); % Mx3
    P2_HM=P2_H(match2(:, 1),:);% Mx3
    dists2=sqrt(sum((P3_M-P2_HM).^2,2));% Mx1
    

    P3_H=P3*H';
    P4_M=P4(testSet(:, 2),:); % Mx3
    P3_HM=P3_H(testSet(:, 1),:);% Mx3
    dists3=sqrt(sum((P4_M-P3_HM).^2,2));% Mx1
    % sum(A,2) is a column vector containing the sum of each row of matrix A
    
    size(match1);
    size(match2);
    size(testSet);
	%  indexPairs1(1,:)
    %A = pointsAL(indexPairs1(1,1),:)
    %B = pointsBL(indexPairs1(1,2),:)
	%
% 	output1;
%     output2;
%     size(dists2)
%     size(dists3)
%     size(output4)
    size(testSet);
    size(dists3);
    size(output3);
    size(output4);
    
   w1 = 10;
   w2  = 1;
   w3 = 100;
    
    for i = 1:length(testSet(:,1))
        index12 = find(output4(i,1)==output3(:,1) & output4(i,2)==output3(:,2),1);
        %index12 = find(output1(i,1)==output2(:,1) & output1(i,2)==output2(:,2),1)
		if isempty(index12) ~= 1
			index23 = find(output2(index12,1)==output1(:,1) & output2(index12,2)==output1(:,2),1);
%              output3(index12,1);
%              output4(index23,1);
			if isempty(index23) ~= 1
                size(dists3);
				%dists(i) = (dists3(index23,1) - dists2(index12,1)) - (dists2(index12,1) - dists1(i,1));
                dists(i) = w3*((dists3(i,1) - dists2(index12,1)) - (dists2(index12,1) - dists1(index23,1)))+w1*dists3(i,1)+w2*((dists3(i,1) - dists2(index12,1)));
			else
% 				dists(i) = (10-dists2(index12,1)) - (dists2(index12,1) - dists1(i,1));
%                 dists(i) = (dists3(i,1)-dists2(index12,1)) - (dists2(index12,1) - 10);
                dists(i) = w3*((dists3(i,1) - dists2(index12,1)) - 10)+w1*dists3(i,1)+w2*((dists3(i,1) - dists2(index12,1)));
            end
        else
            dists(i) = 10;
        end
        
    end
  
        %size(match1)
        
%         if isempty(index) == 1
%             
%         end
        %index2 = find(match3(:,1)==match2(index,2),1);
        %final(i,:) = [match1(i,:), match2(index,:), match3(index2,:)];
        %dists(i,:) = (dists3(index2,1)-dists2(index,1))-(dists2(index,1)-dists1(i,1));

%     if size(dists,1) ~= size(match3,1) || size(dists,2) ~= 1
%         error(['wrong format: dists row--' num2str(size(dists,1)) 'match row--'  num2str(size(match3,1)) 'dists col--'  num2str(size(dists,2))]);
%     end
end

function [D1, D2] = part(D, splitSize)
    %if(splitSize)
    idx = randperm(size(D, 1));% random order of the set {1,2,... # of matches}
    D1 = D(idx(1:splitSize), :);% splitSize default=ceil(0.2 * (# of matches))
    D2 = D(idx(splitSize+1:end), :);
end


