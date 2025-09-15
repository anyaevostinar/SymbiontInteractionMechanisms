#!/bin/bash --login

## This file runs one experimental condition (i.e. a group of jobs
## that are the same except for their random seed)

## Email settings
#SBATCH --mail-type=ALL
#SBATCH --mail-user=vostinar@carleton.edu

## Job name settings
#SBATCH --job-name=sm-1k
#SBATCH -o sm-1k%A_%a.out

## Time requirement in hours and minutes. You might need to make this
## longer, but try to keep it under 4 hours if possible
## SBATCH --time=0-12

## Memory requirement in megabytes. You might need to make this bigger.
#SBATCH --mem-per-cpu=500M

## Launch an array of jobs.
#SBATCH --array=100-129

#SBATCH --nodes=1

cd /Accounts/mendozac/SymbiontInteractionMechanisms/Data/9-12-25-StressDiffFreq-Time
mkdir Parasites150Safe1500
cd Parasites150Safe1500

mkdir ${SLURM_ARRAY_TASK_ID}
cd ${SLURM_ARRAY_TASK_ID}

cp /Accounts/mendozac/SymbiontInteractionMechanisms/Data/9-12-25-StressDiffFreq-Time/SymSettings.cfg .
cp /Accounts/mendozac/SymbiontInteractionMechanisms/SymbulationEmp/symbulation_sgp .

args=" -START_MOI 1 -FILE_NAME _Parasites150Safe1500 -SYMBIONT_TYPE 1 -VERTICAL_TRANSMISSION 1.0 -SAFE_TIME 1500 -DATA_INT 10 -UPDATES 100000 -EXTINCTION_FREQUENCY 150"
./symbulation_sgp $args -SEED ${SLURM_ARRAY_TASK_ID} > run.log

## Run with sbatch -p facultynode --nodelist=edmonstone2024,margulis2024,carver,lederberg run-parasites150safe1500.sh