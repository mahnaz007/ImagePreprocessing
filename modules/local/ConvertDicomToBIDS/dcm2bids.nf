#!/usr/bin/env nextflow

nextflow.enable.dsl=2

// Set input directory and output directory
params.inputDir = "/path/to/sourcecode/yourProject"
params.outputDir = "/path/to/dcm2bidsOutput"
params.configFile = "/path/to/code/config.json"
params.containerPath = "/path/to/dcm2bids.sif" // Path to the Apptainer image

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
            // Extract participant ID from the folder name
            def participantIDMatch = folderName =~ /yourProject\d+_(\d+)_/

            if (!participantIDMatch) {
                error "Could not extract participant ID from the folder name: ${folderName}"
            }
            
            def participantID = participantIDMatch[0][1]

            // Determine the session number
            def session_id = folderName.contains("S1") ? "ses-01" :
                            folderName.contains("S2") ? "ses-02" : "ses-01"

            return tuple(file(dir), participantID, session_id)  // Include session_id in the tuple
        }

    // Execute the ConvertDicomToBIDS process with the channel
    bidsFiles = subDirChannel | ConvertDicomToBIDS
}

process ConvertDicomToBIDS {
    tag { participantID }

    publishDir "${params.outputDir}/bids_output", mode: '
