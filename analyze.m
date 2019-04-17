function analyze(obj, imgOrders)

assert(isa(obj, 'Edf2Mat'), 'Edf2Mat:plot', ...
    'Only objects of type Edf2Mat can be plotted!');

screenSize = get(0,'ScreenSize');
figure( 'Position', [screenSize(3)/4 screenSize(4)/4 2*screenSize(3)/3 2*screenSize(4)/3], ...
    'Name', ['Plotting ' obj.filename], ...
    'NumberTitle', 'off', ...
    'Menubar','none');

% Initialize parameters 
trials= 27;
sampleSize=600;
fixationDuration=1000;
centerX=960;
centerY=540;

% open image orders and extract image name and size
start=obj.Events.Messages.time(1);
r=fopen(imgOrders);
for i= 1:trials
    rline=fgetl(r);
    fileinfo = dir(rline);
    img = imread(fileinfo(1).name);
    imgSize= size(img);
    imgH(i)=imgSize(1);
    imgW(i)=imgSize(2);
    disp(imgH(i));
    disp(imgW(i));
    disp(i);
end


% for every trial, find out the freeviewing period positions and plot it
for i= 1:trials
    startIdx=obj.Events.Messages.time(15+ (i-1)*3) - start  + fixationDuration;
    endIdx= startIdx + sampleSize;
    posX = obj.Samples.posX(startIdx:endIdx);
    posY = obj.Samples.posY(startIdx:endIdx) * -1;
    %set image as plot's background
    min_x=centerX-imgH(i)/2;
    max_y=(-centerY+imgW(i)/2);
    max_x=(centerX+imgH(i)/2);
    min_y=(-centerY-imgW(i)/2);
    img = imread(imgName(i));
    img(:,:,:)=img(:,:,:)*0.5+100;
    imagesc([min_x max_x], [min_y max_y], flipdim(img, 1));

    hold on;
    %plot positions each with a different color ranging red to blue
    red=1;
    blue=0;
    colDif=0;
    for j=1:sampleSize
        %check if data is NaN or missing
        if ~(isnan(posX(j)) || isnan(posY(j)) || posX(j)==-32768 || posY(j)==-32768)
            red=red-colDif;
            blue=blue+colDif;
            color=[red,0, blue];
            colDif= 1/sampleSize;
            %plot
            plot(posX(j), posY(j), 'o', 'color', color);
            hold on;
        end
    end
    set(gca,'ydir','normal'); 
    title(['Plot of the eye movement' imgName(i) obj.filename]);
    axis([min_x max_x min_y max_y])
    xlabel('x-Position');
    ylabel('y-Position');
    hold off;
    disp(i);
end