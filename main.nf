#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// Define input and output parameters
params.input = "/Users/mahi021/pydeface009002Input/sub-009002_ses-01_T1w.nii.gz"
params.output_dir = "/Users/mahi021/pydeface009002Output"

// Define the workflow
workflow {
    // Create a channel with the input file
    input_file = Channel.value(params.input)

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
