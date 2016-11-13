% refer figure 1 DRF paper
%https://www.cs.berkeley.edu/~alig/papers/drf.pdf

% number of jobs
clear; close all; clc;
numJobs = 200;

MAP_VCORES_RANGE = [6 5 4 3 2 1 2 3 4 5 6 7];
RED_VCORES_RANGE = [6 5 4 3 2 1 2 3 4 5 6 7];
MAP_MEM_RANGE = [6*1024:-1:1*1024 1*1024:7*1024];
RED_MEM_RANGE = [6*1024:-1:1*1024 1*1024:7*1024];

MAP_VCORES_MIN = 1;
MAP_VCORES_MAX = 12;
MAP_MEM_MAX = 3*1024;
MAP_MEM_MIN = 2*1024;

REDUCE_VCORES_MIN = 1;
REDUCE_VCORES_MAX = 12;

REDUCE_MEM_MAX = 11*1024;
REDUCE_MEM_MIN = 1;

%% for map stages

map_cpu_demand_idx = randomFunction( MAP_VCORES_MAX, MAP_VCORES_MIN, numJobs);
map_mem_demand_idx  = randomFunction( MAP_MEM_MAX, MAP_MEM_MIN, numJobs);

%% for reduce stages
red_cpu_demand_idx  = randomFunction( REDUCE_VCORES_MAX, REDUCE_VCORES_MIN, numJobs);
red_mem_demand_idx  = randomFunction( REDUCE_MEM_MAX, REDUCE_MEM_MIN, numJobs);

fileToWrite ='resource_demand.txt';

fileID = fopen(fileToWrite,'w');
fprintf(fileID,'MAP CPU: ');

for i=1:numJobs
    map_cpu_demand(i) = MAP_VCORES_RANGE(map_cpu_demand_idx(i));
    fprintf(fileID,',%d',map_cpu_demand(i));
end
fprintf(fileID,'\n MAP MEM:');
for i=1:numJobs
    map_mem_demand(i)=MAP_MEM_RANGE(map_mem_demand_idx(i));
    fprintf(fileID,',%d',map_mem_demand(i));
end

fprintf(fileID,'\n RED CPU: ')
for i=1:numJobs
    red_cpu_demand(i)=RED_VCORES_RANGE(red_cpu_demand_idx(i));
    fprintf(fileID,',%d',red_cpu_demand);
end
fprintf(fileID,'\n RED MEM: ');
for i=1:numJobs
    red_mem_demand(i)=RED_MEM_RANGE(red_mem_demand_idx(i));
    fprintf(fileID,',%d',red_mem_demand(i));
end
fprintf(fileID,'\n');
fclose(fileID);


scatter(map_mem_demand/1024,map_cpu_demand,'filled');
hold on;
scatter(red_mem_demand/1024,red_cpu_demand,'filled');
xlabel('GB');
ylabel('cores');

print ('-depsc', ['/home/tanle/projects/EuroSys17/fig/' 'resource_demand.eps']);

