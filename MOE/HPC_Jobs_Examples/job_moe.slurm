#!/bin/bash
#SBATCH --job-name=MOE_Test
#SBATCH --partition=64c512g
#SBATCH -N 1 
#SBATCH --ntasks-per-node=4
#SBATCH --output=%j.out
#SBATCH --error=%j.err

module load moe/2024

moebatch -exec "script 'capped.svl'"

