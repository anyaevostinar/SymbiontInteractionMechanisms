#!/bin/bash --login

## This file runs one experimental condition (i.e. a group of jobs
## that are the same except for their random seed)

## Email settings
#SBATCH --mail-type=ALL
#SBATCH --mail-user=tuckerd@carleton.edu

## Job name settings
#SBATCH --job-name=str-para
#SBATCH -o str-para%A_%a.out

## Time requirement in hours and minutes. You might need to make this
## longer, but try to keep it under 4 hours if possible
## SBATCH --time=0-24

## Memory requirement in megabytes. You might need to make this bigger.
#SBATCH --mem-per-cpu=500M

## Launch an array of jobs.
#SBATCH --array=100-130

#SBATCH --nodes=1

cd /Accounts/zhange2/SymbiontInteractionMechanisms/Data/10-21-25-HealthVerticalTrans
mkdir Parasites-1.0
cd Parasites-1.0

mkdir ${SLURM_ARRAY_TASK_ID}
cd ${SLURM_ARRAY_TASK_ID}

cp /Accounts/zhange2/SymbiontInteractionMechanisms/Data/10-21-25-HealthVerticalTrans/SymSettings.cfg .
cp /Accounts/zhange2/SymbiontInteractionMechanisms/SymbulationEmp/symbulation_sgp .

args=" -START_MOI 1 -FILE_NAME _Parasites-1.0 -SYMBIONT_TYPE 1 -VERTICAL_TRANSMISSION 1.0"
./symbulation_sgp $args -SEED ${SLURM_ARRAY_TASK_ID} > run.log

## Run with sbatch -p facultynode --nodelist=edmonstone2024,margulis2024,carver,lederberg run-parasites-1.0.sh