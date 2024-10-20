process runMRIQC {
    container "${params.containerPath_mriqc}"
    cpus 3
    memory '8 GB'
    errorStrategy 'ignore'  // Continue even if an error occurs
    maxRetries 2

    tag { "Participant: ${participant}" }

    publishDir "${params.mriqcOutputDir}/sub-${participant}", mode: 'copy', overwrite: true

    input:
        val participant

    output:
        path "reports/*.html", emit: 'reports'
        path "metrics/*.json", emit: 'metrics'
        path "figures/*", emit: 'figures'

    script:
    """
    mkdir -p ${params.mriqcOutputDir}/sub-${participant}

    export SINGULARITY_BINDPATH="${params.bidsDir}/bids_output,${params.mriqcOutputDir},${params.workdir}"

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

    if [ \$? -ne 0 ]; then
        echo "MRIQC crashed for participant ${participant}" >> ${params.mriqcOutputDir}/mriqc_crash_log.txt
    fi
    """
}
