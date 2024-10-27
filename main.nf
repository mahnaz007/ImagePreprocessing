#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// Define paths and parameters
params.inputDir = "/path/to/sourcecode"  
params.bidsDir = "/path/to/output/bids_output"  // BIDS output 
params.outputDir = "/path/to/output"  
params.configFile = "/path/to/config.json"  
params.containerPath_dcm2bids = "/path/to/dcm2bids_3.2.0.sif" 
params.singularity_image = "/path/to/1.14.13.sif"  
params.containerPath_pydeface = "/path/to/pydeface_2.0.0.sif"  
params.containerPath_mriqc = "/path/to/mriqc_24.1.0.sif"  
params.containerPath_fmriprep = "/path/to/fmriprep_24.0.1.sif"  
params.FS_LICENSE = "/path/to/freesurfer/license.txt"  
params.datasetDescription = "/path/to/dataset_description.json"  
params.bidsValidatorLogs = "${params.outputDir}/bidsValidatorLogs"  // BIDS validator output Directory
params.defacedOutputDir = "${params.outputDir}/defaced"  // Defaced output directory
params.mriqcOutputDir = "${params.outputDir}/mriQC"  // MRIQC output directory
params.fmriprepOutputDir = "${params.outputDir}/fmriprep"  // fMRIPrep output directory
params.workdir = "/path/to/workdir"  
params.participantList = ['001004', '001008']  // List of participants without "sub-"

// Include external process scripts
include { ConvertDicomToBIDS } from './ConvertDicomToBIDS.nf'
include { ValidateBIDS } from './ValidateBIDS.nf'
include { PyDeface } from './PyDeface.nf'
include { CopyDatasetDescription } from './CopyDatasetDescription.nf'
include { CopyDatasetDescriptionRoot } from './CopyDatasetDescriptionRoot.nf'
include { runMRIQC } from './runMRIQC.nf'
include { runFmriprep } from './runFmriprep.nf'

// Workflow
workflow {

    // Create a channel for participant directories
    dicomDirChannel = Channel
        .fromPath("${params.inputDir}/*", type: 'dir')
        .map { dir ->
            def folderName = dir.name
            def match = (folderName =~ /IRTG\d+_(\d+)(_S\d+)?_b\d+/) // Extract participant and session info

            if (match) {
                def participantID = match[0][1]
                def session_id = match[0][2] ? match[0][2].replace('_S', 'ses-') : "ses-01"

                if (params.participantList.contains(participantID)) {
                    println "Processing participant: $participantID, session: $session_id"
                    return tuple(participantID, session_id, file(dir))
                }
            }
            return null
        }
        .filter { it != null }

    // Step 1: Convert DICOM to BIDS
    bidsFiles = dicomDirChannel | ConvertDicomToBIDS
    completed = bidsFiles.collect()  // Collect output to ensure ConvertDicomToBIDS completes

    // Step 2: Ensure ValidateBIDS completes after ConvertDicomToBIDS 
    completed.map { true } | ValidateBIDS

    // Step 3: Process 3D NIfTI files
    niiFiles = bidsFiles.flatMap { it }.filter { it.name.endsWith(".nii.gz") }
    anatFiles = niiFiles.filter { it.toString().contains("/anat/") && "fslval ${it} dim4".execute().text.trim() == "1" }
    defacedFiles = anatFiles | PyDeface

    // Step 4: Copy dataset_description.json to BIDS root and bids_output subdirectory
    bidsDirChannel = bidsFiles.map { file(params.bidsDir) }
    descriptionChannel = Channel.of(file(params.datasetDescription))

    // Copy to bids_output subdirectory
    bidsDirChannel
        .combine(descriptionChannel)
        | CopyDatasetDescription

    // Copy to BIDS root directory
    bidsDirChannel
        .combine(descriptionChannel)
        | CopyDatasetDescriptionRoot

    // Step 5: Run MRIQC on BIDS files after CopyDatasetDescription
    bidsFiles
        .map { bidsFile ->
            def participantID = (bidsFile.name =~ /sub-(\d+)/)[0][1]
            return participantID
        }
        .distinct()  // Avoid reprocessing the same participant
        | runMRIQC

    // Step 5: Run fMRIPrep on BIDS files after MRIQC and defacing, and CopyDatasetDescriptionRoot
    bidsFiles
        .map { bidsFile ->
            def participantID = (bidsFile.name =~ /sub-(\d+)/)[0][1]
            return participantID
        }
        .distinct()  // Avoid reprocessing the same participant
        | runFmriprep
}
