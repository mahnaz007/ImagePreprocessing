process CONVERTDICOMTONIFTITHIRDSECOUND {
    input:
        path dicomFiles

    output:
        path "*.nii", emit: true

    script:
        """
        dcm2niix -o . -f '%p_%s' ${dicomFiles}
        """
}



