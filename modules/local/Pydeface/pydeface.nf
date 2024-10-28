process PyDeface {
    // Tag to identify process by the input file name
    tag { niiFile.name }
    
    // Copy results to the defaced output directory
    publishDir "${params.defacedOutputDir}", mode: 'copy'

    input:
    path niiFile

    output:
    path "defaced_${niiFile.simpleName}.nii.gz", emit: defaced_nii

    shell:
    '''
    # Set input and output filenames
    input_file="!{niiFile.getName()}"   // Original file name
    output_file="defaced_!{niiFile.simpleName}.nii.gz"  
    input_dir="$(dirname '!{niiFile}')"  // Directory of the input file
    singularity_img="!{params.containerPath_pydeface}"  

    # Run PyDeface within the Singularity container
    apptainer run --bind "${input_dir}:/input" \\  
    "${singularity_img}" \\  // Specify the container image to use
    pydeface /input/"${input_file}" --outfile "${output_file}"  # Run PyDeface on input file and save to output file
    '''
}
