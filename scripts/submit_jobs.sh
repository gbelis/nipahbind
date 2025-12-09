#!/bin/bash

# --- Configuration for Job Submission ---
OUTPUT_BASE_DIR="./workbench" 
NUM_DESIGNS=1000                     
BUDGET=20                
JOB_SCRIPT="./scripts/run_boltzgen.sh"  
    

mkdir -p "$OUTPUT_BASE_DIR"

echo "Starting job submissions for Izar..."

# --- Loop through config files and submit jobs ---
for CONFIG_FILE in ./configs/frame_*_config.yaml; do
    if [ -f "$CONFIG_FILE" ]; then
        
        # 1. Extract the base name for the job and output directory (e.g., 'frame_123')
        CONFIG_BASENAME=$(basename "$CONFIG_FILE" | sed 's/_config\.yaml//')
        
        # 2. Define a unique output directory for this run
        OUTPUT_DIR="${OUTPUT_BASE_DIR}/${CONFIG_BASENAME}_run"
        mkdir -p "$OUTPUT_DIR"
        
        # 3. Define a dynamic job name for easy queue monitoring
        DYNAMIC_JOB_NAME="BG-${CONFIG_BASENAME}"
        
        # 4. Submit the Slurm job
        # Arguments: $1 (CONFIG_FILE), $2 (OUTPUT_DIR), $3 (NUM_DESIGNS), $4 (BUDGET), $5 (DYNAMIC_JOB_NAME)
        sbatch "$JOB_SCRIPT" "$CONFIG_FILE" "$OUTPUT_DIR" "$NUM_DESIGNS" "$BUDGET" "$DYNAMIC_JOB_NAME"
        
        echo "Submitted job: ${DYNAMIC_JOB_NAME}. Output to: $OUTPUT_DIR"
    else
        echo "Error: No config files found matching ./configs/frame_*_config.yaml"
        exit 1
    fi
done

echo "All jobs submitted. Use 'squeue -u \$USER' to monitor them."