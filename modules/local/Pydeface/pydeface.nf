process PyDeface {
    tag { niiFile.name }
    
    // Publish the defaced output to the specified directory
    publishDir "${params.defacedOutputDir}", mode: 'copy'

    input:
        path niiFile  // Input NIfTI file to be defaced

    output:
        path "defaced_${niiFile.simpleName}.nii.gz", emit: defaced_nii  // Emit the defaced NIfTI file

    shell:
    '''
    input_file="!{niiFile.getName()}"
    output_file="defaced_!{niiFile.simpleName}.nii.gz"
    input_dir="$(dirname '!{niiFile}')"
    singularity_img="!{params.containerPath_pydeface}"

    # Run PyDeface with Apptainer/Singularity
    apptainer run --bind "${input_dir}:/input" \
        "${singularity_img}" \
        pydeface /input/"${input_file}" --outfile "${output_file}"
    '''
}
