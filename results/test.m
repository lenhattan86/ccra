%%
close all;
clear;
bar_input=rand(2,3)/2+0.5;
errorbar_input=rand(2,3)/8;
errorbar_groups(bar_input,errorbar_input, ...
    'bar_width',0.75,'errorbar_width',20, ...
    'optional_bar_arguments',{'LineWidth',1.5}, ...
    'optional_errorbar_arguments',{'LineStyle','none','Marker','none','LineWidth',1.5});
%%  
close all;
clear;

D = randi(10, 5, 3);
figure(1)
hBar = bar(D, 'stacked');
xt = get(gca, 'XTick');
set(gca, 'XTick', xt, 'XTickLabel', {'Machine 1' 'Machine 2' 'Machine 3' 'Machine 4' 'Machine 5'})
yd = get(hBar, 'YData');
yjob = {'Job A' 'Job B' 'Job C'};
barbase = cumsum([zeros(size(D,1),1) D(:,1:end-1)],2);
joblblpos = D/2 + barbase;
for k1 = 1:size(D,1)
    text(xt(k1)*ones(1,size(D,2)), joblblpos(k1,:), yjob, 'HorizontalAlignment','center')
end

%%
get(gca,'colororder')
figure;
colours = permute(get(gca, 'colororder'), [1 3 2]);
colours_resize = imresize(colours, 50.0, 'nearest');
imshow(colours_resize);

%%
 barChart = bar(0,0,'k') %make dummy plot with the right linestyle

axis([10,11,10,11]) %move dummy points out of view
legend('black line','red dot','Orientation','horizontal')
axis off %hide axis
ax = gca;
ax.YColor = 'none';