process PyDeface {
    tag { niiFile.name } // Tags for easy identification of input/output files.
    publishDir "${params.defacedOutputDir}", mode: 'copy' // Saves defaced files to a directory.

    input:
    path niiFile

    output:
    path "defaced_${niiFile.simpleName}.nii.gz", emit: defaced_nii

    // Uses the pydeface container to remove facial features from anatomical images.
    script:
    """
    singularity run --bind ${niiFile.parent}:/input \
        ${params.containerPath_pydeface} \
        pydeface /input/${niiFile.name} --outfile /input/defaced_${niiFile.simpleName}.nii.gz
    """
}
