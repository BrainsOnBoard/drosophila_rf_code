#!/bin/bash

jobfile=~/rx_genviews.txt
if [ -f $jobfile ]
then
    rm $jobfile
fi

nsub=0
readarray arenas < ~/curdrosproj/wharenas.txt

for arena in ${arenas[@]}
do

if [ ! -f ~/curdrosproj/data/rx_neurons/views/rx_views_$arena.mat ]
then
    echo $arena | tee --append $jobfile
    (( nsub++ ))
fi

done

module add sge
qsub -t 1-$nsub ./rx_genviews.sh
