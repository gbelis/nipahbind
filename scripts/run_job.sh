#!/bin/bash

# --- 1. Check for Correct Arguments ---
if [ "$#" -ne 4 ]; then
    echo "Error: Incorrect number of arguments."
    echo "Usage: ./run_job.sh [CONFIG_PATH] [OUTPUT_DIR] [NUM_DESIGNS] [BUDGET]"
    echo "Example: ./run_job.sh configs/config.yaml workbench/test_run 10 2"
    exit 1
fi

# --- 2. Assign Variables from Arguments ---
CONFIG_FILE="$1"
OUTPUT_DIR="$2"
NUM_DESIGNS="$3"
BUDGET="$4"

echo "--- Starting Job ---"
echo "  Config: $CONFIG_FILE"
echo "  Output: $OUTPUT_DIR"
echo "  Num Designs: $NUM_DESIGNS"
echo "  Budget: $BUDGET"
echo "----------------------"

# --- 3. Activate Virtual Environment ---
# NOTE: Using the standard bash-compatible 'activate' script,
# not the .fish version, as this is a bash script.
echo "Activating virtual environment..."
source .venv/bin/activate

if [ $? -ne 0 ]; then
    echo "Error: Could not activate virtual environment at .venv/bin/activate"
    exit 1
fi

# --- 4. Run BoltzGen ---
echo "Starting BoltzGen run..."
boltzgen run "$CONFIG_FILE" \
  --output "$OUTPUT_DIR" \
  --protocol protein-anything \
  --num_designs "$NUM_DESIGNS" \
  --budget "$BUDGET"

echo "BoltzGen run complete. Starting validation..."

# --- 5. Define Dynamic File Paths ---
FINAL_DIR="${OUTPUT_DIR}/final_ranked_designs/final_${BUDGET}_designs"
NPZ_DIR="${OUTPUT_DIR}/intermediate_designs_inverse_folded/refold_cif"

# --- 6. Loop and Validate Final Designs ---
echo "Validating final $BUDGET designs..."
for cif_file in ${FINAL_DIR}/*.cif; do
  
  # Handle cases where no files are found
  if [ ! -f "$cif_file" ]; then
    echo "No .cif files found in $FINAL_DIR. Exiting validation."
    break
  fi
  
  base_name=$(basename "$cif_file" .cif)
  npz_file="${NPZ_DIR}/${base_name}_pae.npz"

  echo "--- Validating: ${base_name} ---"

  if [[ -f "$cif_file" && -f "$npz_file" ]]; then
    # Assumes ipsae.py is in your current directory
    python ipsae.py "$npz_file" "$cif_file" 10 10
  else
    echo "Error: Could not find matching files for ${base_name}"
    echo "  CIF: $cif_file"
    echo "  NPZ: $npz_file"
  fi
done

echo "--- Job Complete ---"