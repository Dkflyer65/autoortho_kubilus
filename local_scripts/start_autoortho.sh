#!/bin/bash

# Activate environment
cd ~/Documents/home
source autoortho-tk-env/bin/activate
cd autoortho

# Start Europe FUSE mount in background
sudo python autoortho/autoortho_fuse.py \
  "/Volumes/Macintosh HD/Users/Allan/X-Plane 12/Custom Scenery/z_autoortho/scenery/z_ao_eur" \
  "/Volumes/Macintosh HD/Users/Allan/X-Plane 12/Custom Scenery/z_ao_eur" &

# Start North America FUSE mount in background
sudo python autoortho/autoortho_fuse.py \
  "/Volumes/Macintosh HD/Users/Allan/X-Plane 12/Custom Scenery/z_autoortho/scenery/z_ao_na" \
  "/Volumes/Macintosh HD/Users/Allan/X-Plane 12/Custom Scenery/z_ao_na" &

# Wait a couple of seconds for mounts to settle
sleep 10

# Start main autoortho
sudo python autoortho/

