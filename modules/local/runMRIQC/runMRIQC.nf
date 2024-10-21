process runMRIQC {
    container "${params.containerPath_mriqc}" 
    cpus 3  // Set the number of CPUs
    memory '8 GB'  // set 8GB of memory
    errorStrategy 'ignore'  // Continue the workflow even if an error happens
    maxRetries 2  // Retry twice in case of failure

    tag { "Participant: ${participant}" }  // Label each task with the participant ID

    // Publish output to a specific directory for the participant
    publishDir "${params.mriqcOutputDir}/sub-${participant}", mode: 'copy', overwrite: true

    input:
        val participant  // Input is the participant ID

    output:
        path "reports/*.html", emit: 'reports'  // Emit reports HTML files
        path "metrics/*.json", emit: 'metrics'  // Emit JSON metrics files
        path "figures/*", emit: 'figures'  // Emit generated figures

    script:
    """
    # Create output directory for the participant
    mkdir -p ${params.mriqcOutputDir}/sub-${participant}

    # Set up binding paths of Singularity
    export SINGULARITY_BINDPATH="${params.bidsDir}/bids_output,${params.mriqcOutputDir},${params.workdir}"

    # Run MRIQC for the participant with Singularity
    singularity exec --bind ${params.bidsDir}/bids_output:/bidsdir \
                     --bind ${params.mriqcOutputDir}:/outdir \
                     --bind ${params.workdir}:/workdir \
                     ${params.containerPath_mriqc} \
                     mriqc /bidsdir /outdir participant \
                     --participant_label ${participant} \
                     --nprocs ${task.cpus} \
                     --omp-nthreads ${task.cpus} \
                     --mem_gb 8 \
                     --no-sub \
                     -vvv \
                     --verbose-reports \
                     --work-dir /workdir > ${params.mriqcOutputDir}/sub-${participant}/mriqc_log_${participant}.txt 2>&1

    # Check if MRIQC failed, and create log with any crashes
    if [ \$? -ne 0 ]; then
        echo "MRIQC crashed for participant ${participant}" >> ${params.mriqcOutputDir}/mriqc_crash_log.txt
    fi
    """
}
