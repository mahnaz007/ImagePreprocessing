#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// Define parameters
params.inputDir = "/home/mzaz021/BIDSProject/sourcecode/IRTG09"
params.outputDir = "/home/mzaz021/BIDSProject/combinedOutput"
params.configFile = "/home/mzaz021/BIDSProject/code/configPHASEDIFF_B0identifier.json"
params.containerPath_dcm2bids = "/home/mzaz021/dcm2bids_3.2.0.sif" // Path to Apptainer container for dcm2bids
params.containerPath_pydeface = "/home/mzaz021/pydeface_latest.sif" // Path to Apptainer container for pydeface
params.defacedOutputDir = "${params.outputDir}/defaced"

// Ensure subdirectories exist
def subDirs = new File(params.inputDir).listFiles().findAll { it.isDirectory() }

if (subDirs.isEmpty()) {
    error "No subdirectories found in the input directory: ${params.inputDir}"
}

// Define Workflow
workflow {
    // Create a channel from the list of subdirectories and extract participantID and session_id
    subDirChannel = Channel
        .from(subDirs)
        .map { dir ->
            def folderName = dir.name
            // Extract participant ID from the folder name using regex
            def participantIDMatch = folderName =~ /IRTG\d+_(\d+)_?/

            if (!participantIDMatch) {
                // Attempt to extract participant ID without trailing underscore
                participantIDMatch = folderName =~ /IRTG\d+_(\d+)$/
                if (!participantIDMatch) {
                    error "Could not extract participant ID from the folder name: ${folderName}"
                }
            }

            def participantID = participantIDMatch[0][1]

            // Determine session number based on folder name
            def session_id
            switch (folderName) {
                case ~/.*S1.*/:
                    session_id = "ses-01"
                    break
                case ~/.*S2.*/:
                    session_id = "ses-02"
                    break
                default:
                    session_id = "ses-01" // Default session
            }

            // Logging for verification
            println "Processing folder: ${folderName}, Participant ID: ${participantID}, Session ID: ${session_id}"

            return tuple(file(dir), participantID, session_id)  // Include session_id in the tuple
        }

    // Execute ConvertDicomToBIDS process with the channel
    bidsFiles = subDirChannel | ConvertDicomToBIDS

    // BIDS Validation (Optional)
    validatedBids = bidsFiles | ValidateBIDS

    // Filter 3D NIfTI files
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

    // Filter files related to the anat folder
    anatFiles = niiFiles3D.filter { file ->
        file.toString().contains("/anat/")
    }

    // Apply Deface to anat files using PyDeface
    defacedFiles = anatFiles | PyDeface
}

// Define ConvertDicomToBIDS process
process ConvertDicomToBIDS {
    tag { "Participant: ${participantID}, Session: ${session_id}" }

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
        --session ${session_id} \
        -o /bids \
        -d /dicoms \
        -c /config.json \
        -p ${participantID} | tee bids_output/validation_log_${participantID}.txt
    """
}

// Define ValidateBIDS process (Optional)
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
        # Continue pipeline execution even if validation fails
    fi
    """
}

// Define PyDeface process
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
