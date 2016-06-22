function F = StabilizationL1Robust_four(imgA,imgB,imgC, imgD,store_H1, store_H2)
    % Step 2. Collect Salient Points from Each Frame
    ptThresh = 0.1;
    pointsA = detectFASTFeatures(imgA, 'MinContrast', ptThresh);% pointsA.Location=(row,col)=position of salient pts in imgA
    pointsB = detectFASTFeatures(imgB, 'MinContrast', ptThresh);
    pointsC = detectFASTFeatures(imgC, 'MinContrast', ptThresh);% pointsA.Location=(row,col)=position of salient pts in imgA
    pointsD = detectFASTFeatures(imgD, 'MinContrast', ptThresh);

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
    [featuresC, pointsC] = extractFeatures(imgC, pointsC);
    [featuresD, pointsD] = extractFeatures(imgD, pointsD);
    

    
    %     pAL=pointsA.Location;
    %     pBL=pointsB.Location;
    %     pointA1=pAL(:,1)<size(imgA,1)/4  & pAL(:,2)<size(imgA,2)/4;
    %     indexPairs2 = FeatMatcher(featuresA.Features, featuresB.Features,0.7);

    indexPairs1 = matchFeatures(featuresA, featuresB);% match pairs
    indexPairs2 = matchFeatures(featuresB, featuresC);% match pairs
    indexPairs3 = matchFeatures(featuresC, featuresD);% match pairs
    %indexPairs1(1,1).Location
    %double(pointsA.Location(1))
    %double(pointsB.Location)
    pointsAL=double(pointsA.Location);
    pointsBL=double(pointsB.Location);
    pointsCL=double(pointsC.Location);
    pointsDL=double(pointsD.Location);
    indexPairs1(1,:);
	
    %A = pointsAL(indexPairs1(1,1),:)
    %B = pointsAL(indexPairs1(1,2),:)
    %len = length(indexPairs1(:,1))
	for i = 1:length(indexPairs1(:,1))
      output1(i,:) = pointsBL(indexPairs1(i,2),:);
      %pointsAL(indexPairs1(i,2),:)
    end  
	%output1
    for i = 1:length(indexPairs2(:,1))
      output2(i,:) = pointsBL(indexPairs2(i,1),:);
      %pointsAL(indexPairs1(i,2),:)
    end
    %output2
	for i = 1:length(indexPairs2(:,1))
      output3(i,:) = pointsCL(indexPairs2(i,2),:);
      %pointsAL(indexPairs1(i,2),:)
    end
    %output3
	for i = 1:length(indexPairs3(:,1))
      output4(i,:) = pointsCL(indexPairs3(i,1),:);
      %pointsAL(indexPairs1(i,2),:)
    end
    %output4

    %for i = 1:length(indexPairs2(:,1))
    %   output3(i,:) = pointsBL(indexPairs2(i,1),:);
    %   output4(i,:) = pointsBL(indexPairs2(i,2),:);
    %end
    %indexPairs2
    % for i = 1:length(indexPairs3(:,1))
	%   output5(i,:) = pointsCL(indexPairs3(i,1),:);
    %   output6(i,:) = pointsCL(indexPairs3(i,1),:);
    %end
	%output1
	%indexPairs3
  
    F=RANSAC_four(pointsAL, pointsBL, pointsCL, pointsDL,indexPairs1,indexPairs2,indexPairs3,store_H1, store_H2,output1,output2,output3,output4);
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