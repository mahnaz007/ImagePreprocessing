process PyDeface {
    tag "${niftiFiles.baseName}"

    input:
        path niftiFiles

    output:
        path "defaced_*.nii", emit: true

    script:
        """
        pydeface ${niftiFiles} --outfile defaced_${niftiFiles.baseName}.nii
        """
}

