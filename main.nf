#!/usr/bin/env nextflow

nextflow.enable.dsl=2

params.inputDir = '/Users/mahi021/Psychatry-department-data/Rawdata_MRscanner/10/ccplac/Anatomie_raw'
params.outputDir = '/Users/mahi021/Psychatry-department-data/Rawdata_MRscanner/10/ccplac/Output'

process CONVERTDICOMTONIFTITHIRDSECOUND {
    input:
        path dicomFiles

    output:
        path "*.nii", emit: nii

    script:
        """
        dcm2niix -o . -f '%p_%s' ${dicomFiles}
        """
}

process PyDeface {
    tag "${niftiFiles.baseName}"

    input:
        path niftiFiles

    output:
        path "defaced_*.nii", emit: nii

    script:
        """
        pydeface ${niftiFiles} --outfile defaced_${niftiFiles.baseName}.nii
        """
}

include {PyDeface} from './modules/PyDeface/main.nf'
include {CONVERTDICOMTONIFTITHIRDSECOUND} from './modules/CONVERTDICOMTONIFTITHIRDSECOUND/main.nf'

workflow {
    // Adjust the pattern to match all files if they don't have a specific extension
    dicomChannel = Channel.fromPath("${params.inputDir}/*", checkIfExists: true)

    // Convert DICOM to NIFTI
    niftiChannel = CONVERTDICOMTONIFTITHIRDSECOUND(dicomChannel)

    // Deface NIFTI files
    defacedChannel = PyDeface(niftiChannel)
}

