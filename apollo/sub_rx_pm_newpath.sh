#!/bin/bash

npathper=25
npathchunk=25
nsubper=$((npathper/npathchunk))
jobfile=~/rx_curjobs.txt

if [ -f $jobfile ]
then
    rm $jobfile
fi

starti=0
#`cat $jobfile | wc -l`
i=0

readarray arenas < ~/curdrosproj/wharenas.txt

for whpath in $(seq 1 $nsubper)
do
pst=$(( (whpath-1)*npathchunk + 1 ))
pend=$(( whpath*npathchunk ))

for arena in ${arenas[@]}
do

#hires lores R2 R4 Rx
for viewtype in hires lores R2nt R4nt Rxnt
do

for startposi in {1..90}
do

fname=`printf %s_%s_st%02d_%04dto%04d.mat $arena$drum $viewtype $startposi $pst $pend`
ffname=~/curdrosproj/data/rx_neurons/paths/$fname
if [ ! -f $ffname -a ! -f ~/curdrosproj/data/rx_neurons/figpreprocess/paths/paths_$arena.mat_$viewtype.mat ]
then
    cparams="$arena $viewtype $startposi $pst $pend $RANDOM"
    echo $cparams $fname | tee --append $jobfile
    (( i++ ))
fi

done
done
done
done

if [ $i -gt 1 ]
then
    module add sge
    qsub -t $(( starti + 1 ))-$(( starti + i )) rx_pm_newpath.sh
fi

echo .
echo $i jobs submitted.
