#!/bin/bash -euo pipefail
mkdir -p bids_output
dcm2bids -d 01_localizer_20_Kanal -p 01 -c /Users/mahi021/Psychatry-department-data/Rawdata_MRscanner/aOC01/T0/dcm2bids_config.json -o bids_output
