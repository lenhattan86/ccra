date --rfc-3339=seconds >> workGenLogs/interactives.csv
./run-interactive-0.sh 
sleep 15
date --rfc-3339=seconds >> workGenLogs/interactives.csv
./run-interactive-1.sh 
sleep 15
wait $interactives 
