import os
import glob
import pandas as pd


BOLTZ_OUT_DIR = "boltz/"  # root folder containing design_* folders
OUTPUT_CSV = "boltz/ipsae_ranked.csv"  # output CSV





import yaml
from typing import Optional, Dict, Any, List

def get_sequence(file_path: str) -> Optional[str]:
    """
    Parses a YAML string, searches the 'sequences' list for the protein
    with 'id: B', and extracts its 'sequence' value.

    Args:
        yaml_content: A string containing the YAML data.

    Returns:
        The sequence string for protein 'B', or None if not found.
    """
    with open(file_path, 'r') as file:
            yaml_content = file.read()
    data = yaml.safe_load(yaml_content)

    # Check if the top-level 'sequences' key exists and is a list
    sequences = data.get('sequences', [])
    if not isinstance(sequences, list):
        print("Error: 'sequences' field is not a list.")
        return None

    # Iterate through the list of sequences (proteins)
    for item in sequences:
        protein_data: Optional[Dict[str, str]] = item.get('protein')

        # Check if this item is the target protein 'B'
        if (protein_data and
                protein_data.get('id') == 'B' and
                'sequence' in protein_data):
            
            # Return the sequence if all conditions are met
            return protein_data['sequence']

    # If the loop finishes without finding the protein
    print("Protein with ID 'B' not found in the YAML content.")
    return None


# paths = glob.glob('boltz/predictions/boltz_results_frame_*_config_*/predictions/frame_*_config_*/frame_*_config_*_model_0_10_10.txt')
paths = glob.glob('boltz/latent_labs_predictions/*/predictions/*/*_model_0_10_10.txt')
dfs = []
seqs = []


for ipsae_path in paths:
    ipsae_df = pd.read_csv(ipsae_path, delim_whitespace=True)#,sep='\s+')


    yaml_path = '/'.join(ipsae_path.split('/')[:3]).replace('predictions/boltz_results_', 'configs/') + '.yaml'
    sequence = get_sequence(yaml_path)

    ipsae_df['Sequence'] = sequence
    dfs.append(ipsae_df)




df = pd.concat(dfs, ignore_index=True)
df = df.groupby('Model', as_index=False)[['ipSAE', 'Sequence']].aggregate({'ipSAE':'max', 'Sequence':'first'})
df = df.sort_values(by='ipSAE', ascending=False)
df = df.rename(columns={'Model': 'Name'})
df['Name'] = df['Name'].str.replace('_model_0', '')


df.to_csv(OUTPUT_CSV, index=False)
df[:10].to_csv(OUTPUT_CSV.replace('.csv','_top10.csv'), index=False)
df[10:20].to_csv(OUTPUT_CSV.replace('.csv','_next10.csv'), index=False)
print(f"Ranked designs saved to {OUTPUT_CSV}")
print(df.head(10))