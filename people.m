function c=people(video)
% ����һ�����˼����
 detector = peopleDetectorACF;
% ��ȡ��Ƶ֡�����Ҷ�֡�������˼�⴦��
videoFileReader = vision.VideoFileReader(video);
videoFrame      = step(videoFileReader);
% bbox            = step(faceDetector, videoFrame);
[bbox,scores] = detectPeopleACF(videoFrame);

% ������⵽����
videoFrame = insertShape(videoFrame, 'Rectangle', bbox);
% imshow(videoFrame);
 for i=1:size(bbox,1)
% ����һ����ת��Ϊ����4����б�
bboxPoints{1,i}= bbox2points(bbox(i,:));
% ������˵�������
points{1,i} = detectMinEigenFeatures(rgb2gray(videoFrame), 'ROI', bbox(i,:));
% ����������
pointTracker{1,i} = vision.PointTracker('MaxBidirectionalError',i);
%�ó�ʼ��λ�úͳ�ʼ���ʼ������
 points{1,i}= points{1,i}.Location;
initialize(pointTracker{1,i},points{1,i}, videoFrame);
end
videoPlayer  = vision.VideoPlayer('Position',...
    [0 0 [size(videoFrame, 2), size(videoFrame, 1)]]);
% ��һ֡�͵�ǰ֡�еĵ�֮���ת��
for i=1:size(bbox,1)
oldPoints{1,i} = points{1,i};
end
text2=['People Number Is ' num2str(size(bbox,1))];
while ~isDone(videoFileReader)
    % ��ȡ��һ֡
    videoFrame = step(videoFileReader);
    % ������Щ��
    for i=1:size(bbox,1)
   [points{1,i}, isFound{1,i}] = step(pointTracker{1,i}, videoFrame);
    visiblePoints{1,i} = points{1,i}(isFound{1,i}, :);
    oldInliers{1,i} = oldPoints{1,i}(isFound{1,i}, :);
   if size(visiblePoints{1,i}, 1) >= 2 
        [xform{1,i}, oldInliers{1,i}, visiblePoints{1,i}] = estimateGeometricTransform(...
            oldInliers{1,i}, visiblePoints{1,i}, 'similarity', 'MaxDistance', 4);
        bboxPoints{1,i} = transformPointsForward(xform{1,i}, bboxPoints{1,i});
        % ������ٿ�
        bboxPolygon{1,i} = reshape(bboxPoints{1,i}', 1, []);
        videoFrame = insertShape(videoFrame, 'Polygon', bboxPolygon{1,i}, ...
            'LineWidth', 2);
        %�����ı�
        videoFrame = insertText(videoFrame,[ 10 1700],text2,'FontSize',30,'TextColor','red');
        % ��ʾ���ٵĵ�
       videoFrame = insertMarker(videoFrame, visiblePoints{1,i}, 'star', ...
            'Color', 'white');
       % ������Щ��
       oldPoints{1,i} = visiblePoints{1,i};
       setPoints(pointTracker{1,i}, oldPoints{1,i});  
   end
end
    % ʹ����Ƶ���Ŷ�����ʾ��ע�͵���Ƶ��
    step(videoPlayer, videoFrame);
end
% ���
release(videoFileReader);
release(videoPlayer);
release(pointTracker{1,i});