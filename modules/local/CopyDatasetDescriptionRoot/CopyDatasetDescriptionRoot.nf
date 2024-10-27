process CopyDatasetDescriptionRoot {
    input:
    tuple path(bidsDir), path(datasetDescription)
   
    output:
    path "${bidsDir}"
   
    script:
    """
    mkdir -p ${bidsDir}
    cp ${datasetDescription} ${bidsDir}/dataset_description.json
    """
}
