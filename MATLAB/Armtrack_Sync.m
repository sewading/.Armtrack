function [drift,Ao,Bo]=Armtrack_Sync(A,B,sampling_dt,estimated_error_range,initial_search_dt)
%     A & B are two arrays to be synchronized
%     We are going to drfit the timestamps of B
%     in order make B synchronize with the timestamp of A
%     in which case, their curves overlap the most.

%     Make sure A and B has the same amount of columns 
%     with the first column representing time.

%     sampling_dt stands for the sampling distance. 
%     The smaller sampling_dt is, the more accurate the result would be.
%     Vice versa, The smaller sampling_dt is, the longer it will take.


    LA=length(A);
    LB=length(B);
    for o1=1:LA-1
        if A(o1,1)>=A(o1+1,1)
            disp('Error, time sequence not in increasing order.')
            pause()
        end
    end
    for o1=1:LB-1
        if B(o1,1)>=B(o1+1,1)
            disp('Error, time sequence not in increasing order.')
            pause()
        end
    end
    T1=max(A(1,1),B(1,1));
    T2=min(A(LA,1),B(LB,1));
    i1=1;
    while B(i1,1)<T1+estimated_error_range
        i1=i1+1;
    end
    i2=LB;
    while B(i2,1)>T2-estimated_error_range
        i2=i2-1;
    end
    clear z
    C=B(i1:i2,:);
    LC=length(C);
    i=0; i1=1;
    D=zeros(length(C(1,1):sampling_dt:C(LC,1)-1),2);
    for t=C(1,1):sampling_dt:C(LC,1)-1
        i=i+1;
        while C(i1+1,1)<t
            i1=i1+1;
        end
        t1=C(i1,1);
        t2=C(i1+1,1);
        if t1>t || t2<t
            disp('error')
            disp(i1)
            disp('C')
            pause
        end
        D(i,:)=[  t  ,  (C(i1,2)*(t2-t)+C(i1+1,2)*(t-t1))/(t2-t1)  ];
    end
    LD=length(D);
    
%     searcher agent D is prepared
%     We now move D across A
%     E denotes the moving agent D with different time drift
    drift=0;
    drift_range_min=T1-C(1,1);
    drift_range_max=T2-C(LC,1);
    search_dt=initial_search_dt;
    search_range_left=drift_range_min;
    search_range_right=drift_range_max;
    
    while(search_dt>=1)
        mini=Inf;
        for t_drift=  search_range_left+search_dt: search_dt : search_range_right-search_dt
            E=[D(:,1)+t_drift,D(:,2)];
            i1=1;
            for o2=1:LD
                tt=E(o2,1);
                while A(i1+1,1)<tt
                    i1=i1+1;
                end
                t1=A(i1,1);
                t2=A(i1+1,1);
                if t1>tt || t2<tt
                    disp('error')
                    disp(i1)
                    disp('E')
                    pause
                end
                E(o2,3)=(A(i1,2)*(t2-tt)+A(i1+1,2)*(tt-t1))/(t2-t1);
%                 disp(strcat(num2str(t1),32,num2str(tt),32,num2str(t2)))
            end
%             Already acquired E with E(:,1) is timestamp
%             E(:,2) is the drifting searcher's value on each timestamp of E(:,1)
%             E(:,3) is A's value on each timestamp of E(:,1)
%             Now we calculate the loss using E(:,2) & E(:,3)
            loss=sum(power(E(:,2) - E(:,3),2));
            if loss<mini
                mini=loss;
                drift_recorder=t_drift;
            end
        end
%         Now we have the minimal loss and the according drift
        fprintf('Searching from %d to %d , with step length %d,optimal drift=%d\n',search_range_left,search_range_right,search_dt,drift_recorder)
        drift=drift_recorder;
%         Updating searching_step for next round
        if search_dt/10<1 && search_dt>1
            search_dt=1;
        else
            search_dt=search_dt/10;
        end
        search_range_left=drift-10*search_dt;
        search_range_right=drift+10*search_dt;
    end
%     Bloody Hell, we finally acquired this optimal Drift
    Ao=A;
    Bo=[B(:,1)+drift,B(:,2)];
    
%     Rendering Demonstration
    t1=max([A(1,1),B(1,1),Bo(1,1)]);
    t2=min([A(length(A),1),B(length(B),1),Bo(length(Bo),1)]);
    section_length=6000;
    t1=rand()*(t2-t1-section_length)+t1;
    t2=t1+section_length;
    i=1;
    while A(i,1)<t1
        i=i+1;
    end
    Ai1=i;
    i=length(A);
    while A(i,1)>t2
        i=i-1;
    end
    Ai2=i;
    while B(i,1)<t1
        i=i+1;
    end
    Bi1=i;
    i=length(B);
    while B(i,1)>t2
        i=i-1;
    end
    Bi2=i;
    i=1;
    while Bo(i,1)<t1
        i=i+1;
    end
    Boi1=i;
    i=length(Bo);
    while Bo(i,1)>t2
        i=i-1;
    end
    Boi2=i;
    p=plot(A(Ai1:Ai2,1),A(Ai1:Ai2,2));
    p.LineWidth=2;
    p.Color=[0,0,0];
    hold on
    p=plot(Bo(Boi1:Boi2,1),Bo(Boi1:Boi2,2));
    p.LineWidth=1;
    p.Color=[0,1,0];
    hold on
    plot(B(Bi1:Bi2,1),B(Bi1:Bi2,2),'r')
%     plot([B(sum((1:length(B))'.*(B(:,2)==max(B(:,2)))),1),Bo(sum((1:length(Bo))'.*(Bo(:,2)==max(B(:,2)))),1)],[max(B(:,2)),max(Bo(:,2))],'b')
    disp('Check the Synchronization Result:')
    disp('Press ENTER to Exit Viewing......')
    pause()
    close
end
    
%     x=E(:,[1,2]);
%     y=E(:,[1,3]);
%     plot(x(:,1),x(:,2))
%     hold on
%     plot(y(:,1),y(:,2),'r--o')