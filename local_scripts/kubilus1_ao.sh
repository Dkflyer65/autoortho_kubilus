#!/bin/bash

# Activate environment
source ~/venvs/ao_kubilus/bin/activate
cd ~/repos/autoortho_kubilus_org

export AO_CONFIG=~/.autoortho_kubilus
export AO_DATA=~/.autoortho-data_kubilus

# Start Europe FUSE mount in background
sudo -E python autoortho/autoortho_fuse.py \
  "/Volumes/Macintosh HD/Users/Allan/X-Plane 12/Custom Scenery/z_autoortho/scenery/z_ao_eur" \
  "/Volumes/Macintosh HD/Users/Allan/X-Plane 12/Custom Scenery/z_ao_eur" &

# Start North America FUSE mount in background
sudo -E python autoortho/autoortho_fuse.py \
  "/Volumes/Macintosh HD/Users/Allan/X-Plane 12/Custom Scenery/z_autoortho/scenery/z_ao_na" \
  "/Volumes/Macintosh HD/Users/Allan/X-Plane 12/Custom Scenery/z_ao_na" &

# Wait a couple of seconds for mounts to settle
sleep 10

# Start main autoortho
sudo -E python autoortho/

