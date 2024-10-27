process CopyDatasetDescription {
    input:
    tuple path(bidsDir), path(datasetDescription)
   
    output:
    path "${bidsDir}/bids_output"
   
    script:
    """
    mkdir -p ${bidsDir}/bids_output
    cp ${datasetDescription} ${bidsDir}/bids_output/dataset_description.json
    """
}
