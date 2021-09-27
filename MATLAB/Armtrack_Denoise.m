function y=Armtrack_Denoise(x,range,exponential,repressive_rate,intensity,iteration)
%     range=50;
%     exponential=[ 1   ,  4   ,   16   ,   20   ,   6   ,   3   ];
%     repressive_rate=1;
%     intensity=.35;
%     I
    y=x;
    for o1=1:iteration
        y1=polyfit_denoise(y,range,intensity,1,repressive_rate);
        y2=polyfit_denoise(y,range,intensity,2,repressive_rate);
        y3=polyfit_denoise(y,range,intensity,3,repressive_rate);
        y4=polyfit_denoise(y,range,intensity,4,repressive_rate);
        y5=polyfit_denoise(y,range,intensity,5,repressive_rate);
        y6=polyfit_denoise(y,range,intensity,6,repressive_rate);
        y=[y1,y2,y3,y4,y5,y6]*exponential'/sum(exponential);
    end
end