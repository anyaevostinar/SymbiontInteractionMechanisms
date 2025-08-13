#!/bin/bash --login

## This file runs one experimental condition (i.e. a group of jobs
## that are the same except for their random seed)

## Email settings
#SBATCH --mail-type=ALL
#SBATCH --mail-user=vostinar@carleton.edu

## Job name settings
#SBATCH --job-name=sn-diff
#SBATCH -o sn-diff%A_%a.out


## SBATCH --time=0-12

## Memory requirement in megabytes. You might need to make this bigger.
#SBATCH --mem-per-cpu=500M

## Launch an array of jobs.
#SBATCH --array=100-130

#SBATCH --nodes=1


cd /Accounts/vostinar/SymbiontInteractionMechanisms/Data/8-13-25-StressDiffTaskValues

mkdir NoSyms
cd NoSyms

mkdir ${SLURM_ARRAY_TASK_ID}
cd ${SLURM_ARRAY_TASK_ID}

cp /Accounts/vostinar/SymbiontInteractionMechanisms/Data/8-13-25-StressDiffTaskValues/SymSettings.cfg .
cp /Accounts/vostinar/SymbiontInteractionMechanisms/SymbulationEmp/symbulation_sgp .

args=" -START_MOI 0 -FILE_NAME _NoSyms "
./symbulation_sgp $args -SEED ${SLURM_ARRAY_TASK_ID} > run.log

## Run with sbatch -p facultynode --nodelist=edmonstone2024,margulis2024,carver,lederberg run-nosyms.sh