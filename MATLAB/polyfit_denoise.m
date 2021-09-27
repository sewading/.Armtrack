function y=polyfit_denoise(x,range,intensity,exponential,repressive_rate)
    y=x;
    [a,b]=size(x);
    if (a-1)*(b-1)
        disp('Error')
        fprintf('Input for denoise is not a 1-d array, instead the shape is %d × %d.\n',a,b)
        disp('Press enter to continue and try to debug, or Ctrl-C to exit.')
        pause()
    end
    L=length(x);
    range=floor(max(4,range));
        for o1=4:min(range,L)
            a=polyfit(1:(o1-1),x(1:o1-1),2);
            y(o1)=y(o1)*(1-intensity)+(a(1)*power(o1,2)+a(2)*o1+a(3))*intensity;
        end
    for o1=range+1:L
        x_trend=x((o1-range):(o1-1));
        y_trend=y((o1-range):(o1-1));
        a=polyfit(1:range,(x_trend*(1+repressive_rate)-repressive_rate*y_trend),exponential);
        t=0;
        for o2=1:exponential+1
            t=t+a(o2)*power(range+1,exponential-o2+1);
        end
        y(o1)=y(o1)*(1-intensity)+t*intensity;
    end
%     plot(x)
%     hold on 
%     plot(y)
end