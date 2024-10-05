#!/usr/bin/env nextflow

nextflow.enable.dsl=2

// Set input directory and output directory
params.inputDir = "/home/mzaz021/BIDSProject/sourcecode/IRTG09"
params.outputDir = "/home/mzaz021/BIDSProject/dcm2bidsNF"
params.configFile = "/home/mzaz021/BIDSProject/code/configPHASEDIFF_B0identifier.json"
params.containerPath = "/home/mzaz021/dcm2bids_3.2.0.sif" // Path to your Apptainer image

// Validate that the input directory exists
if (!new File(params.inputDir).exists()) {
    error "Input directory does not exist: ${params.inputDir}"
}

// Find all subdirectories inside the input directory
def subDirs = new File(params.inputDir).listFiles().findAll { it.isDirectory() }

if (subDirs.isEmpty()) {
    error "No subdirectories found in the input directory: ${params.inputDir}"
}

workflow {
    // Create a channel from the list of subdirectories and extract participant IDs and session_id
    subDirChannel = Channel
        .from(subDirs)
        .map { dir ->
            def folderName = dir.name
            // Extract participant ID from the folder name using regex
            // Adjust the regex based on your actual folder naming convention
            def participantIDMatch = folderName =~ /IRTG\d+_(\d+)_?/

            if (!participantIDMatch) {
                // Handle cases where the folder name does not match expected pattern
                // Attempt to extract participant ID without trailing underscore
                participantIDMatch = folderName =~ /IRTG\d+_(\d+)$/
                if (!participantIDMatch) {
                    error "Could not extract participant ID from the folder name: ${folderName}"
                }
            }

            def participantID = participantIDMatch[0][1]

            // Determine the session number based on the subfolder's name
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

            return tuple(file(dir), participantID, session_id)  // Include session_id in the tuple
        }

    // Execute the ConvertDicomToBIDS process with the channel
    bidsFiles = subDirChannel | ConvertDicomToBIDS
}

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
        ${params.containerPath} \
        --auto_extract_entities \
        --bids_validate \
        -o /bids \
        -d /dicoms \
        -c /config.json \
        -p ${participantID} \
        --session ${session_id} | tee bids_output/validation_log_${participantID}.txt
    """
}
