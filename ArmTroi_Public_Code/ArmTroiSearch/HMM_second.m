function [locElbow,locWrist] = HMM_second(rotWrist,accElbow,hiddenState,K,la3,time1,time2,latency)
% ***************functionality***************:
% HMM tracks the elbow's locations in the second-layer search and then the wirst's locations can be calculated
% ***************input***************:
% rotWrist: rotation matrix from the wrist coordinate system to the torso coordinate system
% accElbow: acc of the elbow in the torso coordinate system from sensor measurement for HMM derivation
% hiddenState: the state space for the second-layer seach from the results of the first-layer search
% K: the number of tracked centers after the first-layer search
% la3: the lower arm length
% time1: acc time stamps
% time2: average time stampes between two samples of time1
% latency: the report window
% ***************output***************:
% locElbow: the tracked elbow's location
% locWrist: the tracked wrist's location


% observed acc: 3 x T-2, each row is the acc in x/y/z axis in the torso coordinate system
O = accElbow;

% calculate the number of state for each point cloud
size_state = zeros(1,K);
for i = 1:K
    size_state(i) = size(hiddenState{i},2);
end

Psi = cell(K, 1);
Delta = cell(K, 1);

% initialize the priori probability
Psi{1}  = zeros(1,size_state(1));
Delta{1}  = ones(1,size_state(1)) * (1/size_state(1));
Delta{2}  = ones(1,size_state(2)) * (1/size_state(2));

% the standard variance of the observed accs, which is used to calculate the transition probability
varAccX = std(O(1,:));
varAccY = std(O(2,:));
varAccZ = std(O(3,:));
varAccX = varAccX*5;
varAccY = varAccY*5;
varAccZ = varAccZ*5;

% the optimal path selection based on the first three state spaces
b0 = 1 / (size_state(1) * size_state(2) * size_state(3));
Psi{2}  = zeros(1,size_state(2));
Psi{3}  = zeros(1,size_state(3));
Delta{3}  = zeros(1,size_state(3));
for k = 1 : size_state(3)
    for j = 1 : size_state(2)
        for i = 1 : size_state(1)
            v1 = (hiddenState{2}(:,j) - hiddenState{1}(:,i) ) / time1(1);
            v2 = (hiddenState{3}(:,k)  - hiddenState{2}(:,j) ) / time1(2);
            a1  = (v2-v1)/time2(1);
            b1 = (1/(sqrt(2*pi) * varAccX)) * exp( -(a1(1) - O(1,1))^2 / (2*varAccX*varAccX) ); % probability of acc x
            b2 = (1/(sqrt(2*pi) * varAccY)) * exp( -(a1(2) - O(2,1))^2 / (2*varAccY*varAccY) ); % probability of acc y
            b3 = (1/(sqrt(2*pi) * varAccZ)) * exp( -(a1(3) - O(3,1))^2 / (2*varAccZ*varAccZ) ); % probability of acc z
            p = b0 * b1 * b2 * b3;
            if (p > Delta{3}(k))
                Psi{3}(k) = j;
                Psi{2}(j) = i;
                Delta{3}(k) = p;
            end
        end
    end
end

% calculate the remaining values in Delta step by step
for t = 4:K
    % j: the current state in current state space
    % i: the saved the optimal probability of each state in the former state space using the viterbi algorithm
    Delta_j = zeros();
    for j = 1:size_state(t)
        % the optimal path of the jth state in the tth frame
        for i = 1:size_state(t-1)
            % transition probability: calculate in transition, because the acc can be caculated from the former state to the current state
            % acc calculation
            vi = (hiddenState{t-1}(:,i) - hiddenState{t-2}(:,Psi{t-1}(i)))/time1(t-2);
            vj = (hiddenState{t}(:,j) - hiddenState{t-1}(:,i))/time1(t-1);
            accij = (vj - vi) / time2(t-2);
            b1 = (1/(sqrt(2*pi) * varAccX)) * exp( -(accij(1) - O(1,t-2))^2 / (2*varAccX*varAccX) ); % probability of acc x
            b2 = (1/(sqrt(2*pi) * varAccY)) * exp( -(accij(2) - O(2,t-2))^2 / (2*varAccY*varAccY) ); % probability of acc y
            b3 = (1/(sqrt(2*pi) * varAccZ)) * exp( -(accij(3) - O(3,t-2))^2 / (2*varAccZ*varAccZ) ); % probability of acc z
            Delta_j(i,1) = Delta{t-1}(i) * b1 * b2 * b3;
        end
        [max_delta_j,psi] = max(Delta_j); % find the maximal probability
        Psi{t}(j) = psi; % put the Psi cell
        Delta{t}(j) = max_delta_j; % put the Delta cell
    end
end

%***************************** window results **************************
locElbow_LT = zeros(3,K);
locWrist_LT = zeros(3,K);
num_latency = latency*5;
I_n = zeros();
for n = 1:floor(K/num_latency)
    T = n*num_latency;
    T_former = (n-1)*num_latency;
    [~,psi_n] = max(Delta{T}); 
    I_n(T,1) = psi_n;
    for t = T-1:-1:T_former+1
        I_n(t,1) = Psi{t+1}(I_n(t+1,1)); % path backtracking to get the optimal path
    end
end

for t = 1:floor(K/num_latency)*num_latency
    locElbow_LT(:,t) = hiddenState{t}(:,I_n(t,1));
    locWrist_LT(:,t) = locElbow_LT(:,t) + (rotWrist(:,:,t) * [0;0;-la3]);
end
locElbow_LT = locElbow_LT(:,1:floor(K/num_latency)*num_latency);
locWrist_LT = locWrist_LT(:,1:floor(K/num_latency)*num_latency);

locElbow = locElbow_LT;
locWrist = locWrist_LT;

end