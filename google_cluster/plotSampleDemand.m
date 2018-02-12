clc; close all; clear;

[VarName1,cpu_requested,mem_requested,time] = importSampledDemand('samples_df.csv');
time = time/(10^6*3600);

plot(time, cpu_requested, 'LineWidth' , 2);
hold on;
plot(time, 6603*ones(size(time)));
hold on;
plot(time, mem_requested,'LineWidth' , 2);
hold on;
plot(time, 5903*ones(size(time)));

legend('cpu','cpu capacity', 'mem', 'mem capacity');

xlabel('hours');
ylabel('resource');
ylim([0 max(cpu_requested)]);
