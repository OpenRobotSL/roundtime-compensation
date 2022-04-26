%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%严格按照时间插补，时间圆整算法
t=t_out;
et=zeros(1,7); 
eg=zeros(1,7);
eall=zeros(1,7);

%首先判断有没有单独一段的时间不足一个0.001差不周期，优先级最高。
for i=1:7
    if t(i)<1e-3&&t(i)>0 %程序里t判断了<1e-6为0，如果出现1e-5,则实际不为0.并且如果当前段t=0.00001,理论是0，但是会多一步插补，所以优先级最高的是这个补偿
        et(i)=1;%按理说应该从最大开始选，这里没加判断是因为后面e=e+et; 已经筛选出最大的了，et同时+1则会选出最大的那个做为补偿步数时间段
    end
end

for i=1:7
    e(i)=rem(t(i)*1000,1); %先扩大插补周期倍数到整数，计算缺少步数，原理是扩大最小周期倒数倍数，然后取小数
end

all=find(e>0);%全部非0段
es=sum(e);%

if es-floor(es)<1e-6  %判断补多少步
    compensate=floor(es);
else
    compensate=ceil(es);%需要补偿几个周期,然后在e最大得X个时间段上补偿,目前精度还有问题
end
%然后吧优先级最高的带入
e=e+et;
[e1,e2]=sort(e);%误差递增排序
e3=e2(7-compensate+1:7);%找出误差最大的段
for i=1:length(e3)
    eg(e3(i))=1;  %在哪些时间段进行补偿为1
end
for i=1:length(all)
    eall(all(i))=1;  %所有非0段
end
eag=eall-eg; %不需要补偿，但是需要吧当前段最后一个时间赋值给当前最后插补时间
et(e3)=0;%已经被补偿步数的时间段 还原为0；et中剩下为1的就是 当前段只有一个插补，且小于一个插补周期；那么这些应该直接赋值，不占用插补步数
fg=t>0;


%精度补偿，最终误差等分到每一步,为了修正速度误差，从插补第二步开始，也就是第三个点，第一个点是初始位置，到最后一个点
dis_error=q1-dis(end);
interp_step=totalstep-1;
diss(1)=dis(1);
diss(2)=dis(2);
for j=1:totalstep-2
     
    diss(j+2)=dis(j+2)+j*(dis_error)/(interp_step-1);
    
end
%根据速度vel_aver区间积分等于dis_error，速度从第一个插补点补也就是第二个点，到倒数第二个点
vel_aver=(dis_error/(interp_step-1))/0.001;
vell=[vel(1),vel(2:end-1)+vel_aver,vel(end)];