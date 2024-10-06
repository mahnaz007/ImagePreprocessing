#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// Set default parameters
params.inputdir = '/home/mzaz021/BIDSProject/preprocessingOutputDir/01'
params.outdir = '/home/mzaz021/BIDSProject/mriqcOutputNF'
params.workdir = '/home/mzaz021/BIDSProject/work'
params.singularityImage = '/home/mzaz021/mriqc_24.0.2.sif'

// Define the MRIQC process
process runMRIQC {
    container "${params.singularityImage}"

    // Set resources
    cpus 4
    memory '8 GB'
    errorStrategy 'retry'
    maxRetries 2

    // Tag each participant for tracking
    tag { "Participant: ${participant}" }

    // Output directory for each participant
    publishDir "${params.outdir}/sub-${participant}", mode: 'copy', overwrite: true

    input:
    val participant

    output:
    path "reports/*.html", emit: 'reports'
    path "metrics/*.json", emit: 'metrics'
    path "figures/*", emit: 'figures'

    script:
    """
    export SINGULARITY_BINDPATH="${params.inputdir},${params.outdir},${params.workdir}"
    
    mriqc ${params.inputdir} ${params.outdir} participant \
    --participant_label ${participant} \
    --nprocs ${task.cpus} \
    --omp-nthreads ${task.cpus} \
    --mem_gb 8 \
    --no-sub \
    -vvv \
    --verbose-reports \
    --work-dir ${params.workdir}
    """
}

// Workflow
workflow {
    // Get participant IDs
    participantChannel = Channel
        .fromPath("${params.inputdir}/sub-*", type: 'dir')
        .ifEmpty { error "No participant directories found in ${params.inputdir}" }
        .map { dir -> dir.name.replace('sub-', '') }

    // Run MRIQC for each participant
    runMRIQC(participantChannel)
}

