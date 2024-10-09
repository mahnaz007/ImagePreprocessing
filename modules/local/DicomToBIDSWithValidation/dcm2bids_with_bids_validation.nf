#!/usr/bin/env nextflow
nextflow.enable.dsl=2
// Parameters for input and output directories
params.inputDir = "/home/mzaz021/BIDSProject/sourcecode/IRTG02"
params.outputDir = "/home/mzaz021/BIDSProject/dcm2bidsNF"
params.configFile = "/home/mzaz021/BIDSProject/code/configPHASEDIFF_B0identifier.json"
params.containerPath = "/home/mzaz021/dcm2bids_3.2.0.sif"
// Get subdirectories from the input directory
def subDirs = new File(params.inputDir).listFiles().findAll { it.isDirectory() }
process ConvertDicomToBIDS {
tag { "Participant: ${participantID}, Session: ${session_id}" }
publishDir "${params.outputDir}/bids_output", mode: 'copy'
input:
tuple path(dicomDir), val(participantID), val(session_id)
output:
path "bids_output/**", emit: bids_files
script:
"""
mkdir -p bids_output
apptainer run --containall \
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
// Convert each subdirectory into required parameters
workflow {
Channel
.from(subDirs)
.map { dir ->
def participantID = dir.name.replaceAll(/IRTG\d+_(\d+).*/, '$1')
def session_id = dir.name.contains('S1') ? "ses-01" : "ses-02"
tuple(file(dir), participantID, session_id)
}
.set { subDirChannel }
// Call the main process
subDirChannel | ConvertDicomToBIDS
}
