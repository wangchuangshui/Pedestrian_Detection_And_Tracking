function c=people(video)
% 创建一个行人检测器
 detector = peopleDetectorACF;
% 读取视频帧，并且对帧进行行人检测处理
videoFileReader = vision.VideoFileReader(video);
videoFrame      = step(videoFileReader);
% bbox            = step(faceDetector, videoFrame);
[bbox,scores] = detectPeopleACF(videoFrame);

% 画出检测到的人
videoFrame = insertShape(videoFrame, 'Rectangle', bbox);
% imshow(videoFrame);
 for i=1:size(bbox,1)
% 将第一个框转换为包含4点的列表
bboxPoints{1,i}= bbox2points(bbox(i,:));
% 检测行人的特征点
points{1,i} = detectMinEigenFeatures(rgb2gray(videoFrame), 'ROI', bbox(i,:));
% 创建跟踪器
pointTracker{1,i} = vision.PointTracker('MaxBidirectionalError',i);
%用初始点位置和初始点初始化跟踪
 points{1,i}= points{1,i}.Location;
initialize(pointTracker{1,i},points{1,i}, videoFrame);
end
videoPlayer  = vision.VideoPlayer('Position',...
    [0 0 [size(videoFrame, 2), size(videoFrame, 1)]]);
% 上一帧和当前帧中的点之间的转换
for i=1:size(bbox,1)
oldPoints{1,i} = points{1,i};
end
text2=['People Number Is ' num2str(size(bbox,1))];
while ~isDone(videoFileReader)
    % 获取下一帧
    videoFrame = step(videoFileReader);
    % 跟踪这些点
    for i=1:size(bbox,1)
   [points{1,i}, isFound{1,i}] = step(pointTracker{1,i}, videoFrame);
    visiblePoints{1,i} = points{1,i}(isFound{1,i}, :);
    oldInliers{1,i} = oldPoints{1,i}(isFound{1,i}, :);
   if size(visiblePoints{1,i}, 1) >= 2 
        [xform{1,i}, oldInliers{1,i}, visiblePoints{1,i}] = estimateGeometricTransform(...
            oldInliers{1,i}, visiblePoints{1,i}, 'similarity', 'MaxDistance', 4);
        bboxPoints{1,i} = transformPointsForward(xform{1,i}, bboxPoints{1,i});
        % 插入跟踪框
        bboxPolygon{1,i} = reshape(bboxPoints{1,i}', 1, []);
        videoFrame = insertShape(videoFrame, 'Polygon', bboxPolygon{1,i}, ...
            'LineWidth', 2);
        %插入文本
        videoFrame = insertText(videoFrame,[ 10 1700],text2,'FontSize',30,'TextColor','red');
        % 显示跟踪的点
       videoFrame = insertMarker(videoFrame, visiblePoints{1,i}, 'star', ...
            'Color', 'white');
       % 重置这些点
       oldPoints{1,i} = visiblePoints{1,i};
       setPoints(pointTracker{1,i}, oldPoints{1,i});  
   end
end
    % 使用视频播放对象显示带注释的视频框
    step(videoPlayer, videoFrame);
end
% 清除
release(videoFileReader);
release(videoPlayer);
release(pointTracker{1,i});