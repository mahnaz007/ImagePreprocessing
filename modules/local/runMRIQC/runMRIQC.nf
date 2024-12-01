process runMRIQC {
    container "${params.containerPath_mriqc}" 
    cpus 4 // Allocates 4 CPUs for MRIQC processing
    memory '8 GB' // Sets 8 GB of memory 
    errorStrategy 'ignore' // Ensures pipeline continues even if MRIQC fails for a participant
    maxRetries 2 // Allows MRIQC to retry twice if it fails
    tag { "Participant: ${participant}" } // Tags logs and outputs with participant info
    publishDir "${params.mriqcOutputDir}/sub-${participant}", mode: 'copy', overwrite: true // Saves MRIQC outputs for each participant

    input:
    val participant // Input participant ID

    // Runs MRIQC on the BIDS dataset for the specified participant
    script:
    """
    mkdir -p ${params.mriqcOutputDir}/sub-${participant} // Ensure output directory exists

    export SINGULARITY_BINDPATH="${params.bidsDir}/bids_output,${params.mriqcOutputDir},${params.workdir}" // Bind paths for singularity

    singularity exec --bind ${params.bidsDir}/bids_output:/bidsdir \\
    --bind ${params.mriqcOutputDir}:/outdir \\
    --bind ${params.workdir}:/workdir \\
    ${params.containerPath_mriqc} \\
    mriqc /bidsdir /outdir participant \\
    --participant_label ${participant} \\
    --nprocs ${task.cpus} \\
    --omp-nthreads ${task.cpus} \\
    --mem_gb 8 \\
    --no-sub \\
    -vvv \\
    --verbose-reports \\
    --work-dir /workdir > ${params.mriqcOutputDir}/sub-${participant}/mriqc_log_${participant}.txt 2>&1 // Logs MRIQC outputs

    if [ \$? -ne 0 ]; then
        echo "MRIQC crashed for participant ${participant}" >> ${params.mriqcOutputDir}/mriqc_crash_log.txt // Log crash information
    fi
    """
}
