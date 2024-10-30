process ValidateBIDS {
    input:
    val trigger  // Ensure this process runs only after ConvertDicomToBIDS completes

    output:
    path "validation_log.txt", emit: logs

    errorStrategy 'ignore'

    script:
    """
    mkdir -p ${params.bidsValidatorLogs}
    echo "Running BIDS validation..."

    singularity run --cleanenv \
        ${params.singularity_image} \
        ${params.inputDirValidationLog} \
        --verbose 2>&1 | tee ${params.bidsValidatorLogs}/validation_log.txt // Saves the output to the validation log file

    echo "Validation log saved at ${params.bidsValidatorLogs}/validation_log.txt" // Final message after validation completes
    """
}
