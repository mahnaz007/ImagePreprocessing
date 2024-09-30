process PyDeface {
    tag "${niiFile.baseName}"

    publishDir "${params.defacedOutputDir}", mode: 'copy'

    input:
        path niiFile

    output:
        path "defaced_${niiFile.baseName}.nii.gz", emit: defaced_nii

    script:
    """
    echo "Defacing ${niiFile}..."
    pydeface ${niiFile} --outfile defaced_${niiFile.baseName}.nii.gz
    """
}
