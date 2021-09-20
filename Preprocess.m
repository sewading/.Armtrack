% 还差一个磁力计的初始态消除
format long
% Acc Gryo Mag Pos Ori
list=dir('D:\Files\.Armtrack\data');
dt=20; % Sampling time step length
batch_size=1024;
frequency=1000/dt;
fprintf('Sampling Frequency = %d Hz \n',frequency);
A=[];
for o1=3:length(list)
    sublist=dir(strcat(list(o1).folder,'\',list(o1).name));
%     Accelerometer data read in
    disp(strcat('Loading:',sublist(1).folder,'\accelerometer.csv'))
    acc=xlsread(strcat(sublist(1).folder,'\accelerometer.csv'));
    acc(:,[1,2,3,8])='';
    for o2=1:length(acc)-1
        if acc(o2,1)>=acc(o2+1,1)
            disp('Error: Time stamp not in increasing order')
            disp(strcat(sublist(1).folder,'\accelerometer.csv'))
            pause
        end
    end
%     Gryoscope data read in
    disp(strcat('Loading:',sublist(1).folder,'\gyroscope.csv'))
    gyro=xlsread(strcat(sublist(1).folder,'\gyroscope.csv'));
    gyro(:,[1,2,3,8])='';
    for o2=1:length(gyro)-1
        if gyro(o2,1)>=gyro(o2+1,1)
            disp('Error: Time stamp not in increasing order')
            disp(strcat(sublist(1).folder,'\gyroscope.csv'))
            pause
        end
    end
%     Magnetometer data read in
    disp(strcat('Loading:',sublist(1).folder,'\magnetometer.csv'))
    mag=xlsread(strcat(sublist(1).folder,'\magnetometer.csv'));
    mag(:,[1,2,3,8])='';
    for o2=1:length(mag)-1
        if mag(o2,1)>=mag(o2+1,1)
            disp('Error: Time stamp not in increasing order')
            disp(strcat(sublist(1).folder,'\magnetometer.csv'))
            pause
        end
    end
%     Oculus data read in
    time_drift=textread(strcat(sublist(1).folder,'\sync.txt'),'%d');
    disp(strcat('Loading:',sublist(1).folder,'\oculus_data.csv'))
    oculus=xlsread(strcat(sublist(1).folder,'\oculus_data.csv'));
    oculus=oculus(:,1:8);
    oculus(:,1)=oculus(:,1)-time_drift;
    for o2=1:length(oculus)-1
        if oculus(o2,1)>=oculus(o2+1,1)
            disp('Error: Time stamp not in increasing order')
            disp(strcat(sublist(1).folder,'\oculus_data.csv'))
            disp(o2)
            pause
        end
    end
    disp('Data loaded------')
    pause(2)
    
    t1=max([acc(1,1),gyro(1,1),mag(1,1),oculus(1,1)]);
    t2=min([acc(length(acc),1),gyro(length(gyro),1),mag(length(mag),1),oculus(length(oculus),1)]);
    i1=1; i2=1; i3=1; i4=1; i5=0;
    clear X
    X(floor((t2-t1)/dt)+1,1 +3+3+3 +3+4)=0;
    for t=t1 : dt : t2
        i5=i5+1;
        while acc(i1+1,1)<t
            i1=i1+1;
        end
        while gyro(i2+1,1)<t
            i2=i2+1;
        end
        while mag(i3+1,1)<t
            i3=i3+1;
        end
        while oculus(i4+1,1)<t
            i4=i4+1;
        end
        T1acc=acc(i1,1); T2acc=acc(i1+1,1);
        T1gyro=gyro(i2,1); T2gyro=gyro(i2+1,1);
        T1mag=mag(i3,1); T2mag=mag(i3+1,1);
        T1oculus=oculus(i4,1); T2oculus=oculus(i4+1,1);
        if T1acc>t || T2acc<t
            disp('error')
            disp(i1)
            disp('acc')
            pause
        end
        if T1gyro>t || T2gyro<t
            disp('error')
            disp(i2)
            disp('gyro')
            pause
        end
        if T1mag>t || T2mag<t
            disp('error')
            disp(i3)
            disp('mag')
            pause
        end
        if T1oculus>t || T2oculus<t
            disp('error')
            disp(i4)
            disp('ocu')
            pause
        end
        data_acc=(acc(i1,2:4)*(T2acc-t)+acc(i1+1,2:4)*(t-T1acc))/(T2acc-T1acc);
        data_gryo=(gyro(i2,2:4)*(T2gyro-t)+gyro(i2+1,2:4)*(t-T1gyro))/(T2gyro-T1gyro);
        data_mag=(mag(i3,2:4)*(T2mag-t)+mag(i3+1,2:4)*(t-T1mag))/(T2mag-T1mag);
        data_oculus=(oculus(i4,2:8)*(T2oculus-t)+oculus(i4+1,2:8)*(t-T1oculus))/(T2oculus-T1oculus);
        X(i5,:)=[t-t1,data_acc,data_gryo,data_mag,data_oculus];
        
        if ~(i5-10000*floor(i5/10000))
            fprintf('Processing......%d\n',i5);
        end
    end
    eval(strcat('data_',list(o1).name,'=X;'))
    X(floor(length(X)/batch_size)*batch_size+1:length(X),:)='';
    A=[A;X];
end
% Magnetometer data normalization
A(:,8:10)=A(:,8:10)./power(sum(power(A(:,8:10),2),2),.5);
% Quaternion transformation into 3-d rotation vector
for o1=1:length(A)
    if sum(abs(A(o1,15:17)))
        A(o1,15:17)=(A(o1,15:17)/power(sum(power(A(o1,15:17),2),2),.5))*acos(A(o1,14))*2;
    end
end
A(:,14)='';
% xlsx file write in
disp('Writing data into data.txt & data.xlsx')
if exist('D:\Files\.Armtrack\data.xlsx')
    delete('D:\Files\.Armtrack\data.xlsx')
end
if exist('D:\Files\.Armtrack\data.txt')
    delete('D:\Files\.Armtrack\data.txt')
end
csvwrite('D:\Files\.Armtrack\data.txt',A)
xlswrite(('D:\Files\.Armtrack\data.xlsx'),A);
