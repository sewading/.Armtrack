function [locElbow,locWrist] = ArmTroiSearch(gameRotWatchNature,gameRotWatch,accWatch,pointCloudFirst,pointCloudSecond,latency,la3)
% ***************functionality***************:
% the basic workflow of arm tracking with one-second report window (in real time) in ArmTroi
% ***************input***************:
% gameRotWatchNature: the original watch's orientation in world coordinate system (the first several samples of the sensor data from gamerotationvector)
% gameRotWatch: the sensor data from gamerotationvector
% accWatch: the sensor data from acclerometer
% pointCloudFirst: point clouds for the first-layer search
% pointCloudSecond: point clouds for the second-layer search
% latency: the report window (one second)
% la3: the lower arm length
% ***************output***************:
% locElbow: the tracked elbow's locations
% locWrist: the tracked wrist's locations

tic;

% the calculation before HMM
[rotWristEuler,rotWrist,accElbow,time1,time2] = armTrack(gameRotWatchNature,gameRotWatch,accWatch,la3);

% HMM tracks the elbow's locations in the first-layer search
[locElbowCenter,keyCenter] = HMM_first(rotWristEuler,accElbow,pointCloudFirst,time1,time2,latency);

% HMM tracks the elbow's locations in the second-layer search and then the wirst's locations can be calculated
num = size(locElbowCenter,2);
hiddenState = cell(num,1); % calculate from the first location
for i = 1:num
    keyFirst = matrix2str(keyCenter(:,i)); % in tracking process, a series of wrist's orientations
    mapFirst = pointCloudSecond(keyFirst); % return type: map; each returned map has center (key) and the points in the range corresponding to the center (keyValue)
    keySecond = matrix2str(locElbowCenter(:,i)); % find the chosen center (key)
	hiddenState{i} = mapFirst(keySecond); % the points in the range corresponding to the center (keyValue)
end
[locElbow,locWrist] = HMM_second(rotWrist(:,:,1:num),accElbow(:,1:num-2),hiddenState,num,la3,time1(1:num-1),time2(1:num-2),latency);

toc;

end