#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// Define paths and parameters
params.inputDir = "/path/to/input"  
params.bidsDir = "/path/to/output/bids_output"  
params.outputDir = "/path/to/output"  //  output directory
params.configFile = "/path/to/config.json"  
params.containerPath_dcm2bids = "/path/to/container/dcm2bids_3.2.0.sif"  
params.containerPath_pydeface = "/path/to/container/pydeface_2.0.0.sif"  
params.containerPath_mriqc = "/path/to/container/mriqc_24.0.2.sif"  
params.datasetDescription = "/path/to/dataset_description.json"  
params.defacedOutputDir = "${params.outputDir}/defaced"  // Directory for defaced output
params.mriqcOutputDir = "${params.outputDir}/mriQC"  // MRIQC output directory
params.workdir = '/path/to/work'  //  work directory
params.participantList = ['xxxxxx', 'xxxxxx']  // List of participants without "sub-" (e.g., '001009')

// Using include for external process scripts
include { ConvertDicomToBIDS } from './modules/local/ConvertDicomToBIDS.nf'
include { ValidateBIDS } from './modules/local/ValidateBIDS.nf'
include { PyDeface } from './modules/local/PyDeface.nf'
include { CopyDatasetDescription } from './modules/local/CopyDatasetDescription.nf'
include { runMRIQC } from './modules/local/runMRIQC.nf'

// Workflow
workflow {

    // Create a channel for directories
    dicomDirChannel = Channel
        .fromPath("${params.inputDir}/*", type: 'dir')
        .map { dir ->
            def folderName = dir.name
            def match = (folderName =~ /IRTG\d+_(\d+)(_S\d+)?_b\d+/)

            if (match) {
                def participantID = match[0][1]  // Extract participant ID (e.g., 001009 or 001001)
                def session_id = match[0][2] ? "ses-${match[0][2][-1].padLeft(2, '0')}" : "ses-01"  // Handle session ID if present or default to ses-01
                
                // Filter by participant list
                if (params.participantList.contains(participantID)) {
                    println "Processing participant: $participantID, session: $session_id"
                    return tuple(participantID, session_id, file(dir))
                }
            }
            return null  // Ignore unmatched or filtered directories
        }
        .filter { it != null }  // Remove any null results

    // Step 1: Convert DICOM to BIDS
    bidsFiles = dicomDirChannel | ConvertDicomToBIDS

    // Step 2: Validate BIDS
    validatedBids = bidsFiles | ValidateBIDS

    // Step 3: Process 3D NIfTI files
    niiFiles = bidsFiles.flatMap { it }.filter { it.name.endsWith(".nii.gz") }
    anatFiles = niiFiles.filter { it.toString().contains("/anat/") && "fslval ${it} dim4".execute().text.trim() == "1" }
    defacedFiles = anatFiles | PyDeface

    // Step 4: Ensure dataset_description.json is copied to the BIDS directory root
    bidsDirChannel = validatedBids.map { file(params.bidsDir) }
    descriptionChannel = Channel.of(file(params.datasetDescription))
    bidsDirChannel
        .combine(descriptionChannel)
        | CopyDatasetDescription

    // Step 5: Run MRIQC on validated BIDS files 
    validatedBids
        .map { bidsFile ->
            def participantID = (bidsFile.name =~ /sub-(\d+)/)[0][1]
            return participantID
        }
        .distinct()  // Avoid processing the same participant multiple times
        | runMRIQC
}
