#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// Define paths and parameters
params.inputDir = "/path/to/inputDir"                             // Path to DICOM files
params.bidsDir = "/path/to/bidsDir"                               // Path to BIDS directory
params.outputDir = "/path/to/outputDir"                           // Path to output directory
params.configFile = "/path/to/config.json"                        // Path to dcm2bids config file
params.containerPath_dcm2bids = "/path/to/dcm2bids_3.2.0.sif"     // Path to dcm2bids container
params.singularity_image = "/path/to/validator_1.14.13.sif"       // Path to BIDS validator container
params.containerPath_pydeface = "/path/to/pydeface_2.0.0.sif"     // Path to pydeface container
params.containerPath_mriqc = "/path/to/mriqc_24.0.2.sif"          // Path to MRIQC container
params.containerPath_fmriprep = "/path/to/fmriprep_24.0.1.sif"    // Path to fMRIPrep container
params.FS_LICENSE = '/path/to/freesurfer/license.txt'             // FreeSurfer license file
params.datasetDescription = "/path/to/dataset_description.json"   // Path to dataset description
params.bidsValidatorLogs = "${params.outputDir}/bidsValidatorLogs" // BIDS validator logs output directory
params.defacedOutputDir = "${params.outputDir}/defaced"           // Defaced output directory
params.mriqcOutputDir = "${params.outputDir}/mriQC"               // MRIQC output directory
params.fmriprepOutputDir = "${params.outputDir}/fmriprep"         // fMRIPrep output directory
params.workdir = '/path/to/workdir'                               // Work directory
params.participantList = ['xxxxxx']                               // List of participants without "sub-" (e.g., 001004)


// Include external process scripts
include { ConvertDicomToBIDS } from './modules/local/ConvertDicomToBIDS.nf'
include { ValidateBIDS } from './modules/local/ValidateBIDS.nf'
include { PyDeface } from './modules/local/PyDeface.nf'
include { CopyDatasetDescription } from './modules/local/CopyDatasetDescription.nf'
include { runMRIQC } from './modules/local/runMRIQC.nf'
include { runFmriprep } from './modules/local/runFmriprep.nf'

// Workflow
workflow {
    // Step 1: Create a channel for directories
    dicomDirChannel = Channel
        .fromPath("${params.inputDir}/*", type: 'dir') // Read all directories in the input folder
        .map { dir ->
            def folderName = dir.name
            def match = (folderName =~ /IRTG\d+_(\d+)(_S\d+)?_b\d+/) // Regex to extract participant and session details

            if (match) {
                def participantID = match[0][1] // Extract participant ID
                def session_id = match[0][2] ? "ses-" + match[0][2].replace('_S', '').padLeft(2, '0') : "ses-01" // Extract session ID

                // Process only if participantID is in the provided list
                if (params.participantList.isEmpty() || params.participantList.contains(participantID)) {
                    println "Processing participant: $participantID, session: $session_id"
                    return tuple(participantID, session_id, file(dir)) // Return participant/session tuple
                }
            }
            return null
        }
        .filter { it != null } // Exclude null values for unmatched directories

    // Step 2: Convert DICOM to BIDS
    bidsFiles = dicomDirChannel | ConvertDicomToBIDS

    // Ensure all ConvertDicomToBIDS outputs are collected before moving to the next step
    completed = bidsFiles.collect()

    // Step 3: Validate BIDS data
    completed.map { true } | ValidateBIDS // Trigger BIDS validation after DICOM conversion is complete

    // Step 4: Process 3D NIfTI files for defacing
    niiFiles = bidsFiles.flatMap { it }.filter { it.name.endsWith(".nii.gz") } // Collect NIfTI files
    anatFiles = niiFiles.filter { it.toString().contains("/anat/") && "fslval ${it} dim4".execute().text.trim() == "1" } // Filter anatomical files
    defacedFiles = anatFiles | PyDeface // Run PyDeface on anatomical files

    // Step 5: Copy dataset_description.json to both BIDS root and bids_output subdirectory
    bidsDirChannel = bidsFiles.map { file(params.bidsDir) }
    descriptionChannel = Channel.of(file(params.datasetDescription))

    // Combine channels and copy dataset_description.json
    bidsDirChannel
        .combine(descriptionChannel)
        | CopyDatasetDescription

    // Step 6: Run MRIQC
    // Extract participant IDs and ensure MRIQC runs only once per participant
    bidsFiles
        .map { bidsFile ->
            def participantID = (bidsFile.name =~ /sub-(\d+)/)[0][1] // Extract participant ID
            return participantID
        }
        .distinct() // Avoid duplicates
        | runMRIQC

    // Step 7: Run fMRIPrep
    // Extract participant IDs and ensure fMRIPrep runs only once per participant
    bidsFiles
        .map { bidsFile ->
            def participantID = (bidsFile.name =~ /sub-(\d+)/)[0][1] // Extract participant ID
            return participantID
        }
        .distinct() // Avoid duplicates
        | runFmriprep
}
