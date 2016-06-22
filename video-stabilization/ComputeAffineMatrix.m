function H = ComputeAffineMatrix( Pt1, Pt2 )
%ComputeAffineMatrix 
%   Computes the transformation matrix that transforms a point from
%   coordinate frame 1 to coordinate frame 2
%Input:
%   Pt1: N * 2 matrix, each row is a point in image 1 
%       (N must be at least 3)
%   Pt2: N * 2 matrix, each row is the point in image 2 that 
%       matches the same point in image 1 (N should be more than 3)
%Output:
%   H: 3 * 3 affine transformation matrix, 
%       such that H*pt1(i,:).' = pt2(i,:).'
% 
    N = size(Pt1,1);
    if size(Pt1, 1) ~= size(Pt2, 1),
        error('Dimensions unmatched.');
    elseif N<3
        error('At least 3 points are required.');
    end
    
    % Convert the input points to homogeneous coordintes.
    P1 = [Pt1';ones(1,N)];% P1=[x1 x2 ... xN; y1 y2 ... yN; 1 1 ...1]
    P2 = [Pt2';ones(1,N)];
    
    % Now, we must solve for the unknown H that satisfies H*P1=P2
    % But MATLAB needs a system in the form Ax=b, and A\b solves for x.
    % Take the transpose of both sides of H*P1=P2 yield P1'*H'=P2'. 
    % Then MATLAB can solve for H'
    % Transpose the result to produce H. : (H')' = H
    
    H=((P1.')\(P2.')).';%P1'*H'=P2'
    
    %***0616 start
    % To preserbe the intent of the original video
    % limit range of change in zoom & rotation
    lowerB=[0.9, -0.1;-0.1,0.9];%lower bound
    upperB=[1.1, 0.1;0.1,1.1];
    smaller=H(1:2,1:2)<lowerB;
    larger=H(1:2,1:2)>upperB;
    original=~(smaller+larger);% ~:inverse(NOT)
    H(1:2,1:2)=original.*H(1:2,1:2)+smaller.*lowerB+larger.*upperB;
    
    % limit skew,non-uniform scale
    skewMax=0.01;%***0616
    nonUScale=0.1;%***0616
    a=H(1,1);
    b=H(1,2);
    c=H(2,1);
    d=H(2,2);
    if(b+c>skewMax)
        shiftbc=(skewMax-b-c)/2;
        H(1,2)=b+shiftbc;
        H(2,1)=c+shiftbc;
        %disp(['b+c=' num2str(H(1,2)+H(2,1))]);
    elseif(b+c<-skewMax)
        shiftbc=(-skewMax-b-c)/2;
        H(1,2)=b+shiftbc;
        H(2,1)=c+shiftbc;
        %disp(['b+c=' num2str(H(1,2)+H(2,1))]);
    end
    
    if(a-d>nonUScale)
        mean=(a+d)/2;
        if(a>d)
            a=mean+nonUScale/2;
            d=mean-nonUScale/2;
        else
            a=mean-nonUScale/2;
            d=mean+nonUScale/2;
        end
        H(1,1)=a;
        H(2,2)=d;
        %disp(['a=' num2str(a) 'd=' num2str(d)]);
        %disp(['a-d=' num2str(H(1,1)-H(2,2))]);
    elseif(a-d<-nonUScale)
        mean=(a+d)/2;
        if(a>d)
            a=mean+nonUScale/2;
            d=mean-nonUScale/2;
        else
            a=mean-nonUScale/2;
            d=mean+nonUScale/2;
        end
        H(1,1)=a;
        H(2,2)=d;
        %disp(['a=' num2str(a) 'd=' num2str(d)]);
        %disp(['a-d=' num2str(H(1,1)-H(2,2))]);
    end
    %***0616 end
    
        
    % Sometimes numerical issues cause least-squares to produce a bottom
    % row which is not exactly [0 0 1], which confuses some of the later
    % code. So we'll ensure the bottom row is exactly [0 0 1].
    H(3,:) = [0 0 1];
end
