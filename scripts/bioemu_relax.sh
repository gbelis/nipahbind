#!/bin/bash

# --- Slurm Directives (Adjust these for your cluster) ---
#SBATCH --job-name=$5
#SBATCH --qos=normal
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=1-00:00:00
#SBATCH --partition=gpu
#SBATCH --gres=gpu:2
#SBATCH --cpus-per-task=1
#SBATCH --mem=50G
#SBATCH --output=./logs/slurm-bioemu-relax-%x_%j.out # Standard output log file
#SBATCH --account=bio-468

conda activate bioemu
python -m bioemu.sidechain_relax --pdb-path /home/belissen/nipah_binder/bioemu_frames/topology.pdb --xtc-path /home/belissen/nipah_binder/bioemu_frames/samples.xtc