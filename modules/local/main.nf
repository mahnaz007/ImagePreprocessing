process PyDeface {
    tag "${niiFile.baseName}"

    publishDir params.outputDir, mode: 'copy' // or 'move', depending on your preference

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
