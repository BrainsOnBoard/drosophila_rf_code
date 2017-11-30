#!/bin/bash
#$ -S /bin/bash
#$ -j y
#$ -o logs
#$ -q serial.q,inf.q,inf_amd.q,eng-inf_parallel.q

#SGE_TASK_ID=1
arena=`awk "NR==$SGE_TASK_ID" ~/rx_gensnaps.txt`

module add matlab
matlab -nodisplay -singleCompThread -r "cd ~/curdrosproj;rx_pm_gensnaps('$arena');exit"

#ssh apollo-login "mail -s 'all $JOB_NAME jobs done' a.dewar@sussex.ac.uk < /dev/null"
#ssh apollo-login "env MODULEPATH=/cm/local/modulefiles:/cm/shared/modulefiles SGE_ROOT=/cm/shared/apps/sge/current /cm/shared/apps/sge/current/bin/lx-amd64/qsub "

./jobdone