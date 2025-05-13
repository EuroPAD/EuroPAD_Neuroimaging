#!/bin/bash

# for each json, if that field is not an array, make it an array, else do nothing (.); then save the modified json in tmp.json, then move tmp.json to original .json
for json in data_ses-01/sub-EPAD*/ses-0?/func/sub*.json; do 
    jq 'if (.SliceTiming | type != "array") then .SliceTiming = [.SliceTiming] else . end' "$json" > tmp.json && mv tmp.json "$json"; 
done