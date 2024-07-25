#!/bin/bash
# runs SIBAK Sim/Inversion with local matlab pool (16 cores) on arton11 with a 
# fast SSD scratch disk to accelerate read/write ops

echo "NOTE: in SIBAK_main_simulate, make sure to open a local parpool" 

qsub -q *@arton11 -l h_vmem=32G -l h_rt=6:00:00 -pe multicore 16 \
Toolboxes/generalRunParallel/batch_local_run_parallel.sh SIBAK_main_simulate
