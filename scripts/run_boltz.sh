#!/bin/bash

# --- Configuration ---
CONFIG_DIR="/home/belissen/nipah_binder/boltz/latent_labs_configs"
PREDICTIONS_DIR="/home/belissen/nipah_binder/boltz/latent_labs_predictions"
LOG_DIR="/home/belissen/nipah_binder/boltz/latent_labs_logs"

# Create output directories if they don't exist
mkdir -p "$PREDICTIONS_DIR"
mkdir -p "$LOG_DIR"

# --- Loop and Submit ---
# Loop through every .yaml file in the config directory
for config_file in "${CONFIG_DIR}"/*.yaml; do
    
    # Check if file exists to avoid errors if directory is empty
    [ -e "$config_file" ] || continue

    # Extract the ID (filename without path and extension)
    filename=$(basename -- "$config_file")
    job_id="${filename%.*}"
    
    echo "Submitting Boltz job for: $job_id"

    # Pass the job script to sbatch via stdin (Heredoc)
    sbatch <<EOT
#!/bin/bash
#SBATCH --job-name=boltz_${job_id}
#SBATCH --output=${LOG_DIR}/${job_id}.out
#SBATCH --error=${LOG_DIR}/${job_id}.err
#SBATCH --partition=gpu          # <--- CHECK: Adjust to your cluster's partition name
#SBATCH --gres=gpu:2             # Request 1 GPU
#SBATCH --time=01:00:00          # Adjust time limit as needed
#SBATCH --qos=normal
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=50G
#SBATCH --account=bio-468


# --- Environment Setup ---
source .venv/bin/activate

# --- Run Boltz ---
# Assuming 'boltz' is in your path. 
# If using a specific checkpoint, add --cache <path>
boltz predict "${config_file}" \
    --out_dir "${PREDICTIONS_DIR}" \
    --use_msa_server \
    --write_full_pae 

EOT

done

echo "All jobs submitted."
