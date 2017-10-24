#!/bin/bash

nsub=0

readarray arenas < ~/curdrosproj/wharenas.txt

for arena in ${arenas[@]}
do

if [ ! -f ~/curdrosproj/data/rx_neurons/snaps/rx_pm_snaps_hires_$arena.mat ]
then
    echo $arena 
    (( nsub++ ))
fi

done

module add sge
qsub -t 1-$nsub ./rx_pm_gensnaps.sh
