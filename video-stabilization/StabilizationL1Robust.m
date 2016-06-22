function F = StabilizationL1Robust(imgA,imgB)
    % Step 2. Collect Salient Points from Each Frame
    ptThresh = 0.1;
    pointsA = detectFASTFeatures(imgA, 'MinContrast', ptThresh);% pointsA.Location=(row,col)=position of salient pts in imgA
    pointsB = detectFASTFeatures(imgB, 'MinContrast', ptThresh);

%     % Display corners found in images A and B.
%     figure; imshow(imgA); hold on;
%     plot(pointsA);
%     title('Corners in A');
% 
%     figure; imshow(imgB); hold on;
%     plot(pointsB);
%     title('Corners in B');

    %!!! >>> paper use other descriptors?
    % Step 3. Select Correspondences Between Points
    % Extract FREAK descriptors for the corners
    % feature of imgA at position
    % =pointA.Location(i,:)=featuresA.Features(i,:)
    [featuresA, pointsA] = extractFeatures(imgA, pointsA);
    [featuresB, pointsB] = extractFeatures(imgB, pointsB);

    %     pAL=pointsA.Location;
    %     pBL=pointsB.Location;
    %     pointA1=pAL(:,1)<size(imgA,1)/4  & pAL(:,2)<size(imgA,2)/4;
    %     indexPairs2 = FeatMatcher(featuresA.Features, featuresB.Features,0.7);

    indexPairs = matchFeatures(featuresA, featuresB);% match pairs
    pointsAL=double(pointsA.Location);
    pointsBL=double(pointsB.Location);
    F=RANSAC(pointsAL, pointsBL, indexPairs);
    F=F.';
    
%     % if the below is used, 
%     % then the part,"% limit skew,non-uniform scale"in
%     % ComputeAffineMatrix.m can be truncated
%     %
%     % Remove skew and nonuniform scale
%     R = F(1:2,1:2);
%     % Compute theta from mean of two possible arctangents
%     theta = mean([atan2(R(2),R(1)) atan2(-R(3),R(4))]);%atan2(R(2),R(1))=arctan(b/a), R(3),R(4)=c,d
%     % Compute scale from mean of two stable mean calculations
%     scale = mean(R([1 4])/cos(theta));
%     % Translation remains the same:
%     translation = F(3, 1:2);
%     % Reconstitute new s-R-t transform:
%     F= [[scale*[cos(theta) -sin(theta); sin(theta) cos(theta)];translation], [0 0 1]'];% transposed trnsformation

    
end