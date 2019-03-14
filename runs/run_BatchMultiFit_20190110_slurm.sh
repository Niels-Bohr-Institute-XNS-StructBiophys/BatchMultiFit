#!/bin/bash

jobname=test
#SBATCH --job-name=$jobname
#SBATCH --time=48:00:00
#SBATCH --partition=SB3
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --sockets-per-node=1
#SBATCH --cores-per-socket=8
#SBATCH --threads-per-core=2 

echo "Running MathKernel $SLURM_CPUS_ON_NODE CPU cores"

echo "SLURM_NNODES=$SLURM_NNODES"
echo "SLURM_NTASKS=$SLURM_NTASKS"
echo "SLURM_NTASKS_PER_NODE=$SLURM_NTASKS_PER_NODE"
echo "SLURM_NPROCS=$SLURM_NPROCS"
echo "SLURM_CPUS_ON_NODE=$SLURM_CPUS_ON_NODE"
echo "SLURM_JOB_CPUS_PER_NODE=$SLURM_JOB_CPUS_PER_NODE"
echo "SLURM_JOB_NUM_NODES=$SLURM_JOB_NUM_NODES"


# does not help
#SLURM_CPUS_ON_NODE=16
#echo "Running MathKernel $SLURM_CPUS_ON_NODE CPU cores"


# mpirun (-np 8,16,...) `cmd` option only causes to run always 16 tasks on one core, i.e. 2 CPUs (12.5%)
# same for srun (-n 8,16,...) `cmd`

MathKernel -noprompt -run "<</home/martins/projects/BatchMultiFit_SF/run_BatchMultiFit_20190110.m" > /home/martins/projects/BatchMultiFit_SF/run_BatchMultiFit_20190110.log
