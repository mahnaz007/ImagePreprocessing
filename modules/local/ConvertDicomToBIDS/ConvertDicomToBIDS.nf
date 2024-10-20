process ConvertDicomToBIDS {
    tag { "Participant: ${participantID}, Session: ${session_id}" }

    // Generalized publishDir to use the output path defined in params
    publishDir "${params.bidsDir}", mode: 'copy'

    input:
        tuple val(participantID), val(session_id), path(dicomDir)

    output:
        path "bids_output/**", emit: bids_files

    script:
    """
    # Create output directory for BIDS files
    mkdir -p bids_output
    
    # Run the DICOM to BIDS conversion using Apptainer/Singularity
    apptainer run -e --containall \
        -B ${dicomDir}:/dicoms:ro \               # Bind DICOM directory
        -B ${params.configFile}:/config.json:ro \  # Bind config file
        -B ./bids_output:/bids \                   # Bind output directory for BIDS
        ${params.containerPath_dcm2bids} \         # Use the specified container for DICOM to BIDS conversion
        --session ${session_id} \                  # Session identifier
        -o /bids \                                 # Output BIDS directory
        -d /dicoms \                               # Input DICOM directory
        -c /config.json \                          # Configuration file
        -p ${participantID} | tee bids_output/validation_log_${participantID}.txt  # Log output
    """
}
