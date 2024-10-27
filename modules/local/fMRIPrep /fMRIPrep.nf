process runFmriprep {
    input:
    val participantID

    // Script to execute fMRIPrep
    script:
    """
    # Run fMRIPrep using Singularity
    singularity run --cleanenv \\  
      --bind ${params.workdir}:/path/to/work \\  // Bind the work directory to /path/to/work inside the container
      ${params.containerPath_fmriprep} \\  
      ${params.bidsDir} \\  
      ${params.fmriprepOutputDir} \\  
      participant \\  
      --participant-label ${participantID} \\  // Set the participant ID 
      --fs-license-file ${params.FS_LICENSE} \\  
      --skip_bids_validation \\  
      --omp-nthreads 1 \\  // Set OpenMP threads to 1, useful for limiting CPU usage
      --random-seed 13 \\  // Set a fixed random seed for reproducibility
      --skull-strip-fixed-seed  // Enable fixed seed for skull-stripping to have consistent results
    """
}

