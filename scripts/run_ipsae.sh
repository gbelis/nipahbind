

source .venv/bin/activate

# boltz/predictions/boltz_results_frame_*_config_*/predictions/frame_*_config_*/frame_*_config_*_model_0.cif

cif_pattern=boltz/latent_labs_predictions/*/predictions/*/*_model_0.cif
for cif_file in $cif_pattern; do
    echo $cif_file
    # 1. Get the directory and the base filename of the structure
    dir_name=$(dirname "$cif_file")
    base_name=$(basename "$cif_file")

    # 2. Construct the expected PAE filename
    # logic: take "frame_X.cif", remove ".cif", add "pae_" prefix and ".npz" suffix
    pae_name="pae_${base_name%.cif}.npz"
    pae_file="$dir_name/$pae_name"

    # 3. Run the command if the pair exists
    if [ -f "$pae_file" ]; then
        echo "Running ipsae on: $base_name"
        ipsae "$pae_file" "$cif_file"
    else
        echo "Skipping $base_name: Corresponding PAE file not found."
    fi
done