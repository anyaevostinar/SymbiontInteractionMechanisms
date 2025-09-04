#!/bin/bash --login

## This file runs one experimental condition (i.e. a group of jobs
## that are the same except for their random seed)

## Email settings
#SBATCH --mail-type=ALL
#SBATCH --mail-user=vostinar@carleton.edu

## Job name settings
#SBATCH --job-name=sp-750
#SBATCH -o sp-750%A_%a.out

## Time requirement in hours and minutes. You might need to make this
## longer, but try to keep it under 4 hours if possible
## SBATCH --time=0-24

## Memory requirement in megabytes. You might need to make this bigger.
#SBATCH --mem-per-cpu=500M

## Launch an array of jobs.
#SBATCH --array=100-129

#SBATCH --nodes=1

cd /Accounts/vostinar/SymbiontInteractionMechanisms/Data/9-02-25-StressIntervalSweep

mkdir Parasites750
cd Parasites750

mkdir ${SLURM_ARRAY_TASK_ID}
cd ${SLURM_ARRAY_TASK_ID}

cp /Accounts/vostinar/SymbiontInteractionMechanisms/Data/9-02-25-StressIntervalSweep/SymSettings.cfg .
cp /Accounts/vostinar/SymbiontInteractionMechanisms/SymbulationEmp/symbulation_sgp .

args=" -START_MOI 1 -FILE_NAME _Parasites750 -SYMBIONT_TYPE 1 -VERTICAL_TRANSMISSION 0.0 -EXTINCTION_FREQUENCY 750"
./symbulation_sgp $args -SEED ${SLURM_ARRAY_TASK_ID} > run.log

## Run with sbatch -p facultynode --nodelist=edmonstone2024,margulis2024,carver,lederberg run-parasites750.sh