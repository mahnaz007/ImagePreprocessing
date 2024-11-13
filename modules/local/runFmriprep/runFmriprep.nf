process runFmriprep {
    container "${params.containerPath_fmriprep}" 
    tag { "Participant: ${participantID}" } // Tags logs and outputs with participant 
    time '48h' // Sets a 48-hour time limit for the process

    input:
    val participantID // Input participant ID

    output:
    path "${params.fmriprepOutputDir}/**", mode: 'copy', emit: 'outputs' // Collects all fMRIPrep outputs

    // Runs fMRIPrep to preprocess MRI data for the specified participant
    script:
    """
    # Create the output directory if it doesn't exist
    mkdir -p ${params.fmriprepOutputDir}

    singularity run --cleanenv \\
      --bind ${params.workdir}:/workdir \\
      --bind ${params.bidsDir}:/data:ro \\
      --bind ${params.fmriprepOutputDir}:/out \\
      ${params.containerPath_fmriprep} \\
      /data \\
      /out \\
      participant \\
      --participant-label ${participantID} \\
      --fs-license-file ${params.FS_LICENSE} \\ // Specifies the FreeSurfer license
      --skip_bids_validation \\ // Skips validation as it's already done
      --omp-nthreads 4 \\ // Allocates 4 threads for OpenMP
      --random-seed 13 \\ // Ensures reproducibility with a fixed random seed
      --skull-strip-fixed-seed \\ // Uses a fixed seed for skull stripping
      --output-spaces MNI152NLin2009cAsym:res-2 T1w fsnative fsaverage5 // Specifies output spaces

    echo "fMRIPrep completed for Participant: ${participantID}" // Logs completion message
    ls -R ${params.fmriprepOutputDir} // Lists all output files
    """
}
