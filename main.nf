#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// Define paths
params.inputDir = "/path/to/input"  // DICOM source for dcm2bids
params.bidsDir = "/path/to/bids/output"  // BIDS dataset output directory for MRIQC
params.outputDir = "/path/to/output/directory"
params.configFile = "/path/to/config/file/config.json"
params.containerPath_dcm2bids = "/path/to/container/dcm2bids_3.2.0.sif"
params.containerPath_pydeface = "/path/to/container/pydeface_2.0.0.sif"
params.containerPath_mriqc = "/path/to/container/mriqc_24.0.1.sif"
params.datasetDescription = "/path/to/dataset_description.json"  // Path to dataset_description.json
params.defacedOutputDir = "${params.outputDir}/defaced"
params.mriqcOutputDir = "${params.outputDir}/mriQC"
params.workdir = "/path/to/work/directory"

// Get all subdirectories
def subDirs = new File(params.inputDir).listFiles().findAll { it.isDirectory() }

process ConvertDicomToBIDS {
    tag { "Participant: ${participantID}, Session: ${session_id}" }
    publishDir "${params.bidsDir}", mode: 'copy'

    input:
        tuple val(participantID), val(session_id), path(dicomDir)

    output:
        path "bids_output/**", emit: bids_files

    script:
    """
    mkdir -p bids_output
    apptainer run -e --containall \
        -B ${dicomDir}:/dicoms:ro \
        -B ${params.configFile}:/config.json:ro \
        -B ./bids_output:/bids \
        ${params.containerPath_dcm2bids} \
        --session ${session_id} \
        -o /bids \
        -d /dicoms \
        -c /config.json \
        -p ${participantID} | tee bids_output/validation_log_${participantID}.txt
    """
}

process ValidateBIDS {
    input:
        path bids_files

    output:
        path bids_files

    script:
    """
    echo "Validating BIDS dataset..."
    bids-validator ${bids_files} --json > validation_report.json || true

    if grep -q '"issues": {}' validation_report.json; then
        echo "BIDS validation successful."
    else
        echo "BIDS validation failed. Check the validation_report.json for details."
        cat validation_report.json
    fi
    """
}

process PyDeface {
    tag { niiFile.name }
    publishDir "${params.defacedOutputDir}", mode: 'copy'

    input:
        path niiFile

    output:
        path "defaced_${niiFile.simpleName}.nii.gz", emit: defaced_nii

    shell:
    '''
    input_file="!{niiFile.getName()}"
    output_file="defaced_!{niiFile.simpleName}.nii.gz"
    input_dir="$(dirname '!{niiFile}')"
    singularity_img="!{params.containerPath_pydeface}"

    apptainer run --bind "${input_dir}:/input" \
        "${singularity_img}" \
        pydeface /input/"${input_file}" --outfile "${output_file}"
    '''
}

// Process to copy dataset_description.json into the root of BIDS directory
process CopyDatasetDescription {
    input:
        tuple path(bidsDir), path(datasetDescription)

    output:
        path "${bidsDir}/bids_output"

    script:
    """
    # Ensure the second bids_output directory exists and copy the file there
    mkdir -p ${bidsDir}/bids_output
    cp ${datasetDescription} ${bidsDir}/bids_output/dataset_description.json
    """
}

process runMRIQC {
    container "${params.containerPath_mriqc}"

    cpus 4
    memory '8 GB'
    errorStrategy 'ignore'  // Continue even if MRIQC fails
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

    apptainer exec --bind ${params.bidsDir}/bids_output:/bidsdir \
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

// Workflow
workflow {
    subDirChannel = Channel
        .from(subDirs)
        .map { dir ->
            def folderName = dir.name
            def participantID = (folderName =~ /IRTG\d+_(\d+)/)[0][1]
            def session_id = folderName.contains("S2") ? "ses-02" : "ses-01"
            return tuple(participantID, session_id, file(dir))
        }

    // Run processes
    bidsFiles = subDirChannel | ConvertDicomToBIDS
    validatedBids = bidsFiles | ValidateBIDS

    // Process 3D NIfTI files
    niiFiles = bidsFiles.flatMap { it }.filter { it.name.endsWith(".nii.gz") }
    anatFiles = niiFiles.filter { it.toString().contains("/anat/") && "fslval ${it} dim4".execute().text.trim() == "1" }
    defacedFiles = anatFiles | PyDeface

    // Ensure dataset_description.json is copied to the BIDS directory root
    bidsDirChannel = validatedBids.map { file(params.bidsDir) }
    descriptionChannel = Channel.of(file(params.datasetDescription))

    bidsDirChannel
        .combine(descriptionChannel)
        | CopyDatasetDescription

    // Run MRIQC on the defaced NIfTI files
    participantIDs = defacedFiles.map { defacedFile -> 
        def participantID = (defacedFile.getName() =~ /sub-(\d+)/)[0][1]
        return participantID
    }
    participantIDs | runMRIQC
}
