#!/bin/bash --login
#SBATCH -A ecode

## This file runs one experimental condition (i.e. a group of jobs
## that are the same except for their random seed)

## Email settings
#SBATCH --mail-type=ALL
#SBATCH --mail-user=vostinar@carleton.edu

## Job name settings
#SBATCH --job-name=health-mut
#SBATCH -o health-mut%A_%a.out

## Time requirement in hours and minutes. You might need to make this
## longer, but try to keep it under 4 hours if possible
#SBATCH --time=0-12

## Memory requirement in megabytes. You might need to make this bigger.
#SBATCH --mem-per-cpu=500M

## Launch an array of jobs.
#SBATCH --array=100-130


cd /Accounts/vostinar/SymbiontInteractionMechanisms/Data/8-11-25-HealthMode

mkdir Mutualists
cd Mutualists

mkdir ${SLURM_ARRAY_TASK_ID}
cd ${SLURM_ARRAY_TASK_ID}

cp /Accounts/vostinar/SymbiontInteractionMechanisms/Data/8-11-25-HealthMode/symbulation_sgp .
cp /Accounts/vostinar/SymbiontInteractionMechanisms/Data/8-11-25-HealthMode/SymSettings.cfg .

args=" -START_MOI 1 -FILE_NAME _Mutualists -SYMBIONT_TYPE 0 -CPU_TRANSFER_CHANCE 0.65 -VERTICAL_TRANSMISSION 1.0 "
./symbulation_sgp $args -SEED ${SLURM_ARRAY_TASK_ID} > run.log