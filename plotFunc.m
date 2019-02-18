function plotFunc(obj, eye ,imgOrders)
%plots Eye Heatmap

% eye=1 for right and eye=2 for left
if ~exist('eye', 'var')
    eye = 1;
end

%number of trials
trials= 27;

% read imgOrders.txt
r=fopen(imgOrders);

for i=1:trials
    rline=fgetl(r);
    trialInfo=strsplit(rline,{'/'});
    imgName(i)=trialInfo(end);
end

fclose(r);


%calculate start and end positions of the tracking part of each trial

for i= 1:trials
    startIdx(i)=floor((obj.Events.Messages.time(15+ (i-1)*3) - obj.Events.Messages.time(1))/1000 + 1)*1000;
    endIdx(i)=floor((obj.Events.Messages.time(17+ (i-1)*3) - obj.Events.Messages.time(1))/1000)*1000;
end


screenSize = get(0,'ScreenSize');
figure( 'Position', [screenSize(3)/4 screenSize(4)/4 2*screenSize(3)/3 2*screenSize(4)/3], ...
    'Name', ['Plotting Eye ' num2str(eye) ' ' obj.filename], ...
    'NumberTitle', 'off', ...
    'Menubar','none');


% Ploting heatmap
for i= 1:trials
    [heatmap, ~, axisRange] = EyeHeatmap(obj,eye,startIdx(i), endIdx(i));
    imagesc(heatmap);
    axis(axisRange);
    
    title('HeatMap');
    xlabel('x-Position');
    ylabel('y-Position');
end


for i= 1:trials
    plot(obj.Samples.posX(startIdx(i):endIdx(i)), obj.Samples.posY(startIdx(i):endIdx(i)), 'o');
    imagesc(heatmap);
    axis(axisRange);
    
    title('Fixations');
    xlabel('x-Position');
    ylabel('y-Position');
end
end

