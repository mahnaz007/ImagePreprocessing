process ConvertDicomToBIDS {
    tag "${params.participant}"

    publishDir "${params.outputDir}", mode: 'copy', saveAs: { filename -> "bids_output/${filename}" }

    output:
        path "bids_output/*", emit: bids

    script:
    """
    mkdir -p bids_output
    dcm2bids -d ${params.inputDir} -p ${params.participant} -c ${params.configFile} -o bids_output
    """
}
