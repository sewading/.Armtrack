disp('Columns of the Dataset:')
disp('1: Timestamp')
disp('2-4: Accelerometer')
disp('5-7: Gyroscope')
disp('8-10: Magnetometer Normalized')
disp('11-13: Position Groundtruth')
disp('14-16: Orientation Groundtruth in the Form of Rotation Vector')
disp('17-20: Orientation Groundtruth in the Form of Quaternion')
for o=1:9
    t1=round(rand()*(length(A)-10000));
    t2=t1+800;
    x=A(t1:t2,9);
    range=35;
    plot(A(t1:t2,1)/1000,x(1:t2-t1+1),'g')
    hold on
    exps=[ 1   ,  2   ,   5   ,   4   ,   2   ,   1   ];
    repress=0.2;
    intense=.2;
    for o1=1:5
        y1=polyfit_denoise(x,range,intense,1,repress);
        y2=polyfit_denoise(x,range,intense,2,repress);
        y3=polyfit_denoise(x,range,intense,3,repress);
        y4=polyfit_denoise(x,range,intense,4,repress);
        y5=polyfit_denoise(x,range,intense,5,repress);
        y6=polyfit_denoise(x,range,intense,6,repress);
        x=[y1,y2,y3,y4,y5,y6]*exps'/sum(exps);
    end
    plot(A(t1:t2,1)/1000,x(1:t2-t1+1),'r')
    xlabel('Time(s)');
    pause()
    clf
end
close
