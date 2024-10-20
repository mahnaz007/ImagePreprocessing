process CopyDatasetDescription {
    input:
        tuple path(bidsDir), path(datasetDescription)

    output:
        path "${bidsDir}/bids_output"

    script:
    """
    # Create bids_output directory if it doesn't exist
    if [ ! -d "${bidsDir}/bids_output" ]; then
        mkdir -p ${bidsDir}/bids_output
    fi

    # Copy the dataset_description.json into the bids_output directory
    cp ${datasetDescription} ${bidsDir}/bids_output/dataset_description.json
    """
}
