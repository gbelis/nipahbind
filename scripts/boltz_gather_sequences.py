import pandas as pd
import glob
import os
import yaml



pattern = '/home/belissen/nipah_binder/workbench/frame_*_run/final_ranked_designs/final_designs_metrics_20.csv'

OUT_DIR = '/home/belissen/nipah_binder/boltz/configs'
os.makedirs(OUT_DIR, exist_ok=True)

INVARIANT_CHAIN_A = (
    "ICLQKTSNQILKPKLISYTLPVVGQSGTCITDPLLAMDEGYFAYSHLERIGSCSRGVSKQRIIGVGEVLDRGDEVPSLFMTNVWTPPNPNTVYHCSAVYNNEFYYVLCAVSTVGDPILNSTYWSGSLMMTRLAVKPKSNGGGYNQHQLALRSIEKGRYDKVMPYGPSGIKQGDTLYFPAVGFLVRTEFKYNDSNCPITKCQYSKPENCRLSMGIRPNSHYILRSGLLKYNLSDGENPKVVFIEISDQRLSIGSPSKIYDSLGQPVFYQASFSWDTMIKFGDVLTVNPLVVNWRNNTVISRPGQSQCPRFNTCPEICWEGVYNDAFLIDRINWISAGVFLDSNQTAENPVFTVFKDNEILYRAQLASEDTNAQKTITNCFLLKNKIWCISLVEIYDTGDNVIRPKLFAVKIPEQCTH"
)

def make_yaml(seq, out_path):
    data = {
        "version": 1,
        "sequences": [
            {"protein": {"id": "A", "sequence": INVARIANT_CHAIN_A}},
            {"protein": {"id": "B", "sequence": seq, "msa": "empty"}}
        ],
    }
    with open(out_path, "w") as f:
        yaml.dump(data, f, sort_keys=False)


seq_files = glob.glob(pattern)

if not seq_files:
    print(f"No files found matching pattern: {pattern}")
else:
    print(f"Found {len(seq_files)} files. Processing...")

    # List to store individual dataframes
    dfs = []
    for filename in seq_files:
        try:
            df_temp = pd.read_csv(filename, usecols=['id', 'designed_sequence'])
            dfs.append(df_temp)
        except ValueError as e:
            print(f"Skipping {filename}: Columns not found - {e}")
        except Exception as e:
            print(f"Error reading {filename}: {e}")

    if dfs:
        final_df = pd.concat(dfs, ignore_index=True)
        print(f"Successfully concatenated {len(dfs)} files.")
        print(f"Total rows: {len(final_df)}")
        print("\nFirst 5 rows:")
        print(final_df.head())
    else:
        print("No valid dataframes created.")

for row in final_df.itertuples(index=False):
            # Construct safe filename (assuming 'id' is clean, otherwise consider sanitizing)
            file_name = f"{row.id}.yaml"
            file_path = os.path.join(OUT_DIR, file_name)
            make_yaml(row.designed_sequence, file_path)