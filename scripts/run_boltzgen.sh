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
#SBATCH --output=./logs/slurm-%x_%j.out # Standard output log file
#SBATCH --account=bio-468


# --- Receive Arguments from Submission Script ---
CONFIG_FILE=$1    # e.g., ./configs/frame_1_config.yaml
OUTPUT_DIR=$2     # e.g., ./boltzgen_outputs/frame_1_run
NUM_DESIGNS=$3    # e.g., 100
BUDGET=$4         # e.g., 10000

# --- Setup Environment ---
source .venv/bin/activate

echo "Starting BoltzGen run"
echo "Config File: $CONFIG_FILE"
echo "Output Directory: $OUTPUT_DIR"

# --- The actual command ---
boltzgen run "$CONFIG_FILE" \
  --output "$OUTPUT_DIR" \
  --protocol protein-anything \
  --num_designs "$NUM_DESIGNS" \
  --budget "$BUDGET"\
  --reuse

# Check the exit status of the boltzgen command
if [ $? -eq 0 ]; then
  echo "BoltzGen run completed successfully!"
else
  echo "BoltzGen run failed with an error."
fi