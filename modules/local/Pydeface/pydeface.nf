process PyDeface {
    tag { niiFile.name }
    
    // publishDir for defaced output
    publishDir "${params.defacedOutputDir}", mode: 'copy'

    input:
        path niiFile  // Input defaced NIfTI file 

    output:
        path "defaced_${niiFile.simpleName}.nii.gz", emit: defaced_nii  
    shell:
    '''
    # Define the input and output file names
    input_file="!{niiFile.getName()}"
    output_file="defaced_!{niiFile.simpleName}.nii.gz"
    input_dir="$(dirname '!{niiFile}')"
    singularity_img="!{params.containerPath_pydeface}"

    # Run PyDeface within Apptainer/Singularity
    apptainer run --bind "${input_dir}:/input" \
        "${singularity_img}" \
        pydeface /input/"${input_file}" --outfile "${output_file}"
    '''
}
