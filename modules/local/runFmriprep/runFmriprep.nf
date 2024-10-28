process runFmriprep {
    input:
    val participantID


    script:
    """
    singularity run --cleanenv \
      --bind ${params.workdir}:/home/mzaz021/work \
      ${params.containerPath_fmriprep} \
      ${params.bidsDir} \
      ${params.fmriprepOutputDir} \
      participant \
      --participant-label ${participantID} \
      --fs-license-file ${params.FS_LICENSE} \
      --skip_bids_validation \
      --omp-nthreads 1 \  // For consistent results
      --random-seed 13 \  // For consistent results
      --skull-strip-fixed-seed
    """
}
