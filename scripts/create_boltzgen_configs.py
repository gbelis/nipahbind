import mdtraj as md
import os
import sys

# --- Configuration ---
TRAJECTORY_FILE = 'targets/samples.pdb'
FRAMES_DIR = 'targets'
CONFIGS_DIR = 'configs'
# ---

# Create output directories if they don't exist
os.makedirs(FRAMES_DIR, exist_ok=True)
os.makedirs(CONFIGS_DIR, exist_ok=True)


xtc_file = '/home/belissen/nipah_binder/bioemu_frames/samples_md_equil.xtc'
topology_file = '/home/belissen/nipah_binder/bioemu_frames/samples_md_equil.pdb'
t = md.load(xtc_file, top=topology_file)
print(f"Successfully loaded {t.n_frames} frames.")

for i, structure in enumerate(t):
    frame_filepath = os.path.join(FRAMES_DIR, f'frame_{i}.pdb')
    structure.save(frame_filepath)
    relative_frame_path = f'../{frame_filepath}'

    config_content = f"""
entities:

  # 1. The Target: Nipah G Protein (Frame {i})
  - file:
      id: nipah_g
      path: '{relative_frame_path}'

      include:
        - chain:
            id: A

      binding_types:
        - chain:
            id: A
            binding: 51, 52, 53, 54, 55, 118, 201, 202, 214, 215, 217, 271, 301, 302, 303, 304, 305, 314, 317, 318, 319, 320, 341, 343, 344, 345, 346, 368, 370, 371, 372, 392, 393, 394, 396, 401

  # 2. The Binder: To be designed
  - protein:
      id: binder
      sequence: 40..70
"""

    # 4. Write the config file
    config_filepath = os.path.join(CONFIGS_DIR, f'frame_{i}_config.yaml')
    with open(config_filepath, 'w') as f:
        f.write(config_content)
