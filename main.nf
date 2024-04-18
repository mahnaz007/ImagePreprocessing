#!/usr/bin/env nextflow

nextflow.enable.dsl=2

params.inputDir = "/Users/mahi021/Psychatry-department-data/Rawdata_MRscanner/aOC01/T0/01_localizer_20_Kanal"
params.outputDir = "/Users/mahi021/Psychatry-department-data/Rawdata_MRscanner/aOC01/T0/Output"
params.configFile = "/Users/mahi021/Psychatry-department-data/Rawdata_MRscanner/aOC01/T0/dcm2bids_config.json"
params.participant = "01"
params.defacedOutputDir = "/Users/mahi021/Psychatry-department-data/Rawdata_MRscanner/aOC01/T0/defaced"

process ConvertDicomToBIDS {
    tag "${params.participant}"

    publishDir "${params.outputDir}/bids_output", mode: 'copy', saveAs: { filename -> "${filename}" }

    input:
        path dicomDir

    output:
        path "bids_output/**", emit: bids_files

    script:
    """
    mkdir -p bids_output
    dcm2bids -d ${dicomDir} -p ${params.participant} -c ${params.configFile} -o bids_output
    """
}

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


workflow {
    dicomChannel = Channel.fromPath("${params.inputDir}", type: 'dir').ifEmpty { error "No DICOM directory found!" }
    bidsFiles = ConvertDicomToBIDS(dicomChannel)

    bidsFiles
        .flatMap { it }
        .filter { it.name.endsWith(".nii.gz") }
        .set { niiFiles }

    PyDeface(niiFiles)
}
