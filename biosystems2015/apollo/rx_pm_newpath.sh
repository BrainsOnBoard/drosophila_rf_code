#!/bin/bash
#$ -S /bin/bash
#$ -j y
#$ -o logs
#$ -q serial.q,inf.q,inf_amd.q,eng-inf_parallel.q

#SGE_TASK_ID=1
jobfile=~/rx_curjobs.txt

#cdatafn=~/curdrosproj/data/rx_neurons/paths/`awk 'NR=='$SGE_TASK_ID' { print $7 }' $jobfile`
#echo $cdatafn
#exit

echo running on $QUEUE
cmd=`awk 'NR=='$SGE_TASK_ID' { printf "rx_gendata_pm_newpath(%s,%s,%d,%d:%d,%d)", "'\''"$1"'\''", "'\''"$2"'\''", $3, $4, $5, $6 }' $jobfile`
echo $cmd

module add matlab
#(arenafname,viewtype,startposi,whpaths,randseed)
matlab -nodisplay -singleCompThread -r "cd ~/curdrosproj;$cmd;exit"

#njob=`ssh apollo-login "env MODULEPATH=/cm/local/modulefiles:/cm/shared/modulefiles SGE_ROOT=/cm/shared/apps/sge/current /cm/shared/apps/sge/current/bin/lx-amd64/qstat -u ad374 | grep ${JOB_NAME:0:10} | wc -l"`
#if [ $njob == 1 ]
#then

#ssh apollo-login "mail -s 'all $JOB_NAME jobs done ($JOB_ID)' a.dewar@sussex.ac.uk < /dev/null"

#cd ~/curdrosproj/data/rx_neurons/paths/
#fn=~/rx_paths_`date +%Y%m%d_%H%M`.zip
#awk '{ print $7 }' $jobfile | zip -@ $fn && scp $fn alex@infro900007.inf.sussex.ac.uk:sync/code+data/curdrosproj

#fi
