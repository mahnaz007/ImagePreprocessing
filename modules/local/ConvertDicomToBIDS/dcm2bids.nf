#!/usr/bin/env nextflow

nextflow.enable.dsl=2

// Set input directory, output directory, config file, and container path as parameters
params.inputDir = params.inputDir ?: 'path/to/input'
params.outputDir = params.outputDir ?: 'path/to/output'
params.configFile = params.configFile ?: 'path/to/config/configPHASEDIFF_B0identifier.json'
params.containerPath = params.containerPath ?: 'path/to/container/dcm2bids_3.2.0.sif' // Path to Apptainer image

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
        	def participantIDMatch = folderName =~ /IRTG\d+_(\d+)_/

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

	// Use a generic output path
	publishDir "${params.outputDir}/bids_output", mode: 'copy', saveAs: { filename -> "${filename}" }

	input:
    	tuple path(dicomDir), val(participantID), val(session_id)

	output:
    	path "bids_output/**", emit: bids_files

	script:
	"""
	mkdir -p bids_output
	apptainer run -e --containall -B ${dicomDir}:/dicoms:ro -B ${params.configFile}:/config.json:ro -B ./bids_output:/bids ${params.containerPath} --auto_extract_entities --bids_validate -o /bids -d /dicoms -c /config.json -p ${participantID} | tee bids_output/validation_log_${participantID}.txt
	"""
}
