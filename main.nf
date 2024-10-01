#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// Define parameters for input directory, output directory, config file, and container paths
params.inputDir = params.inputDir ?: 'path/to/input'
params.outputDir = params.outputDir ?: 'path/to/output'
params.configFile = params.configFile ?: 'path/to/config/configPHASEDIFF_B0identifier.json'
params.containerPath_dcm2bids = params.containerPath_dcm2bids ?: 'path/to/container/dcm2bids_3.2.0.sif' // Apptainer image for dcm2bids
params.containerPath_pydeface = params.containerPath_pydeface ?: 'path/to/container/pydeface_latest.sif' // Container image for pydeface
params.defacedOutputDir = "${params.outputDir}/defaced"

// Ensure subdirectories exist
def subDirs = new File(params.inputDir).listFiles().findAll { it.isDirectory() }

if (subDirs.isEmpty()) {
    error "No subdirectories found in the input directory: ${params.inputDir}"
}

// Define the workflow
workflow {
    // Create a channel from the list of subdirectories and extract participant ID and session_id
    subDirChannel = Channel
        .from(subDirs)
        .map { dir ->
            def folderName = dir.name
            // Extract participant ID from the folder name
            def participantIDMatch = folderName =~ /IRTG\d+_(\d+)_/
    
            if (!participantIDMatch) {
                error "Could not extract participant ID from the folder name: ${folderName}"
            }
    
            def participantID = participantIDMatch[0][1]
            // Determine the session number
            def session_id = folderName.contains("S1") ? "ses-01" :
                            folderName.contains("S2") ? "ses-02" : "ses-01"
            return tuple(file(dir), participantID, session_id)
        }

    // Execute the ConvertDicomToBIDS process with the channel
    bidsFiles = subDirChannel | ConvertDicomToBIDS

    // (Optional) Validate BIDS
    validatedBids = bidsFiles | ValidateBIDS

    // Filter NIfTI 3D files
    niiFiles = bidsFiles
        .flatMap { it }
        .filter { it.name.endsWith(".nii.gz") }

    niiFiles3D = niiFiles.filter { file ->
        def is_3d = false
        try {
            def cmd = "fslval ${file} dim4".execute().text.trim()
            is_3d = cmd.toInteger() == 1
        } catch (Exception e) {
            is_3d = false
        }
        return is_3d
    }

    // Filter files from the anat folder
    anatFiles = niiFiles3D.filter { file ->
        file.toString().contains("/anat/")
    }

    // Apply defacing to the anat files using PyDeface
    defacedFiles = anatFiles | PyDeface
}

// Process for ConvertDicomToBIDS
process ConvertDicomToBIDS {
    tag { participantID }

    publishDir "${params.outputDir}/bids_output", mode: 'copy', saveAs: { filename -> "${filename}" }

    input:
        tuple path(dicomDir), val(participantID), val(session_id)

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
        --auto_extract_entities \
        --bids_validate \
        -o /bids \
        -d /dicoms \
        -c /config.json \
        -p ${participantID}
    """
}

// (Optional) Process for ValidateBIDS
process ValidateBIDS {
    tag "BIDS Validation"

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
        # Continue pipeline even if validation fails
    fi
    """
}

// Process for PyDeface
process PyDeface {
    tag { niiFile.name }

    publishDir "${params.defacedOutputDir}", mode: 'copy'

    input:
        file niiFile

    output:
        path "defaced_${niiFile.simpleName}.nii.gz", emit: defaced_nii

    shell:
    '''
    #!/usr/bin/env bash

    # Define variables for input and output
    input_file="!{niiFile.getName()}"
    output_file="defaced_!{niiFile.simpleName}.nii.gz"
    input_dir="$(dirname '!{niiFile}')"
    singularity_img="!{params.containerPath_pydeface}"

    # Run pydeface using Apptainer
    apptainer run \
        --bind "${input_dir}:/input" \
        "${singularity_img}" \
        pydeface /input/"${input_file}" \
        --outfile "${output_file}"
    '''
}
