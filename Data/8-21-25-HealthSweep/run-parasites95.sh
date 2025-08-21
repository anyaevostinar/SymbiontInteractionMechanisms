#!/bin/bash --login

## This file runs one experimental condition (i.e. a group of jobs
## that are the same except for their random seed)

## Email settings
#SBATCH --mail-type=ALL
#SBATCH --mail-user=vostinar@carleton.edu

## Job name settings
#SBATCH --job-name=hp95
#SBATCH -o hp95%A_%a.out

## Time requirement in hours and minutes. You might need to make this
## longer, but try to keep it under 4 hours if possible
## SBATCH --time=0-24

## Memory requirement in megabytes. You might need to make this bigger.
#SBATCH --mem-per-cpu=500M

## Launch an array of jobs.
#SBATCH --array=100-109

#SBATCH --nodes=1


cd /Accounts/vostinar/SymbiontInteractionMechanisms/Data/8-21-25-HealthSweep

mkdir Parasites95
cd Parasites95

mkdir ${SLURM_ARRAY_TASK_ID}
cd ${SLURM_ARRAY_TASK_ID}

cp /Accounts/vostinar/SymbiontInteractionMechanisms/Data/8-21-25-HealthSweep/SymSettings.cfg .
cp /Accounts/vostinar/SymbiontInteractionMechanisms/SymbulationEmp/symbulation_sgp .


args=" -START_MOI 1 -FILE_NAME _Parasites85 -SYMBIONT_TYPE 1 -CPU_TRANSFER_CHANCE 0.95 -VERTICAL_TRANSMISSION 0.0 "
./symbulation_sgp $args -SEED ${SLURM_ARRAY_TASK_ID} > run.log

## Run with sbatch -p facultynode --nodelist=edmonstone2024,margulis2024,carver,lederberg run-parasites.sh