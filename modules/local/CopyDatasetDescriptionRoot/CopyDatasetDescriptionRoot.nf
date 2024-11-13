process CopyDatasetDescription {
    publishDir "${params.bidsDir}", mode: 'copy'

    input:
    tuple path(bidsDir), path(datasetDescription)

    output:
    path "${bidsDir}/dataset_description.json"

    // Copies the dataset_description.json file to the root of the BIDS directory. (Required for fMRIPrep)
    script:
    """
    mkdir -p ${bidsDir}
    cp ${datasetDescription} ${bidsDir}/dataset_description.json
    """
}
