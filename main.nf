#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// Define input and output parameters
params.input_file = "/home/mzaz021/BIDSProject/preprocessingOutputDir/09B0identifier/sub-009002/ses-01/anat/sub-009002_ses-01_T1w.nii.gz"
params.output_dir = "/home/mzaz021/BIDSProject/pydeface009002Git/"

// Define the workflow
workflow {
    // Create a channel with the input file
    input_file = Channel.value(params.input_file)

    // Execute the pydeface process
    defaced_file = pydeface_process(input_file)

    // Optionally, display the path of the defaced file
    defaced_file.view()
}

// Define the pydeface_process
process pydeface_process {
    // Assign a tag for easier identification in logs
    tag "Pydeface"

    // Publish the output to the specified output directory
    publishDir params.output_dir, mode: 'copy', pattern: '*.nii.gz'

    // Define the input for the process
    input:
    path in_file

    // Define the output for the process
    output:
    path "${in_file.getBaseName()}_defaced.nii.gz"

    // Define the script to execute
    script:
    """
    # Run pydeface on the input file and specify the output filename
    pydeface "$in_file" --out "${in_file.getBaseName()}_defaced.nii.gz"
    """
}
