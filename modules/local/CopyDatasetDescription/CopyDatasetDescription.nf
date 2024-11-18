
process CopyDatasetDescription {
    tag 'Copy dataset_description.json'

    input:
    tuple path(bidsDir), path(datasetDescription)

    output:
    path "${bidsDir}/bids_output/dataset_description.json" 
    path "${bidsDir}/dataset_description.json"

    script:
    """
    mkdir -p ${bidsDir}/bids_output
    cp ${datasetDescription} ${bidsDir}/bids_output/dataset_description.json #Copies inside the bids_output subdirectory. (Required for MRIQC process)
    cp ${datasetDescription} ${bidsDir}/dataset_description.json  #Copies to the root of the BIDS directory. (Required for fMRIPrep process)
    """
}
