process CopyDatasetDescription {
    input:
        tuple path(bidsDir), path(datasetDescription)

    output:
        path "${bidsDir}/dataset_description.json"  

    script:
    """
    # Ensure the bids_output directory exists if it doesn't already exist
    if [ ! -d "${bidsDir}" ]; then
        mkdir -p ${bidsDir}
    fi
    
    # Copy the dataset_description.json file into the BIDS output folder
    cp ${datasetDescription} ${bidsDir}/dataset_description.json
    """
}
