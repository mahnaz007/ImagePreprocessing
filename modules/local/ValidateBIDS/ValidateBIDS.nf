process ValidateBIDS {
    publishDir "${params.bidsValidatorLogs}", mode: 'copy' // Saves logs for debugging and documentation.

    input:
    val trigger // Ensures this process runs after `ConvertDicomToBIDS`.

    output:
    path "validation_log.txt", emit: logs

    // Validates the BIDS directory 
    // Any issues in the BIDS structure will be logged in validation_log.txt.
    script:
    """
    mkdir -p ${params.bidsValidatorLogs}
    singularity run --cleanenv \
        ${params.singularity_image} \
        ${params.bidsDir} \
        --verbose > ${params.bidsValidatorLogs}/validation_log.txt 2>&1
    """
}
