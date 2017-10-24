#!/bin/bash
#$ -S /bin/bash
#$ -j y
#$ -o logs
#$ -q serial.q,inf.q,inf_amd.q,eng-inf_parallel.q

jobfile=~/rx_genviews.txt

#SGE_TASK_ID=1
arena=`awk "NR==$SGE_TASK_ID" ~/rx_genviews.txt`

module add matlab
matlab -nodisplay -singleCompThread -r "cd ~/curdrosproj;rx_gendata_getviews('$arena');exit"

./jobdone