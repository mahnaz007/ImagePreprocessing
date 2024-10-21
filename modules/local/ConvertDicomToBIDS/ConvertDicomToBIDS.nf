process ConvertDicomToBIDS {
    tag { "Participant: ${participantID}, Session: ${session_id}" }

    // publishDir used the output path defined in params
    publishDir "${params.bidsDir}", mode: 'copy'

    input:
        tuple val(participantID), val(session_id), path(dicomDir)

    output:
        path "bids_output/**", emit: bids_files  // output pattern

    script:
    """
    # Create the output directory for BIDS files
    mkdir -p bids_output
    
    # Run the DICOM to BIDS conversion using Apptainer/Singularity
    apptainer run -e --containall \
        -B ${dicomDir}:/dicoms:ro \               # Bind DICOM directory as read-only
        -B ${params.configFile}:/config.json:ro \  # Bind config file as read-only
        -B ./bids_output:/bids \                   # Bind output directory for BIDS
        ${params.containerPath_dcm2bids} \         # Use the container for DICOM to BIDS conversion
        --session ${session_id} \                  
        -o /bids \                                 # Specify output directory 
        -d /dicoms \                               # Specify DICOM input directory 
        -c /config.json \                          # Specify config file 
        -p ${participantID} | tee bids_output/validation_log_${participantID}.txt  # Log the validation output
    """
}
