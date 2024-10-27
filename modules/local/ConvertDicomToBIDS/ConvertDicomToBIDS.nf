process ConvertDicomToBIDS {
    tag { "Participant: ${participantID}, Session: ${session_id}" }
    publishDir "${params.bidsDir}", mode: 'copy'
   
    input:
    tuple val(participantID), val(session_id), path(dicomDir)
   
    output:
    path "bids_output/**", emit: bids_files
   
    script:
    """
    mkdir -p bids_output
    apptainer run -e --containall \\
    -B ${dicomDir}:/dicoms:ro \\
    -B ${params.configFile}:/config.json:ro \\
    -B ./bids_output:/bids \\
    ${params.containerPath_dcm2bids} \\
    --session ${session_id} \\
    -o /bids \\
    -d /dicoms \\
    -c /config.json \\
    -p ${participantID} 
    """
}
