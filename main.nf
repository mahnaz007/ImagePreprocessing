#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// Define paths and parameters
params.inputDir = "/path/to/input"  
params.bidsDir = "path/to/output/bids_output"  //  output path for BIDS
params.outputDir = "path/to/output"  // Generalized output path
params.configFile = "path/to/config/config.json" 
params.containerPath_dcm2bids = "/path/to/container/dcm2bids_3.2.0.sif"  
params.containerPath_pydeface = "/path/to/container/pydeface_2.0.0.sif"  
params.containerPath_mriqc = "/path/to/container/mriqc_24.0.2.sif"  
params.datasetDescription = "/path/to/dataset_description.json"  
params.defacedOutputDir = "${params.outputDir}/defaced"
params.mriqcOutputDir = "${params.outputDir}/mriQC"
params.workdir = "${baseDir}/path/to/workdir"  
params.participantList = ['xxxxxx', 'xxxxxx']  // List of participants without "sub-"  (e.g., 001009 or 001010)

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
                def participantID = match[0][1]  // Extract participant ID (e.g., 001009 or 001010)
                def session_id = match[0][2] ? "ses-${match[0][2][-1].padLeft(2, '0')}" : "ses-01"  //  Session ID if present or default it to ses-01 or ses-02
                
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

    // Step 4: Run MRIQC on the validated BIDS files 
    validatedBids
        .map { bidsFile ->
            def participantID = (bidsFile.name =~ /sub-(\d+)/)[0][1]
            return participantID
        }
        .distinct()  // Avoid processng same participant multiple times
        | runMRIQC
}
