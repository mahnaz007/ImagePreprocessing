#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// Set input directory, output directory, and Singularity image path as parameters
params.inputDir = params.inputDir ?: 'path/to/input'
params.defacedOutputDir = params.defacedOutputDir ?: 'path/to/output/defaced'
params.singularityImg = params.singularityImg ?: 'path/to/singularity/pydeface_latest.sif'

workflow {
	// Use Channel.fromPath to find NIfTI files in a generic directory structure
	niiFiles = Channel.fromPath("${params.inputDir}/sub-*/ses-*/anat/*.nii.gz")
                      .map { file -> file.toAbsolutePath() }

	// Apply defacing to the NIfTI files using Singularity
	niiFiles | PyDeface
}

process PyDeface {
	tag { niiFile.name }

	// Generic output directory
	publishDir "${params.defacedOutputDir}", mode: 'copy'

	input:
    	file niiFile

	output:
    	path "defaced_${niiFile.simpleName}.nii.gz", emit: defaced_nii

	shell:
	'''
	#!/usr/bin/env bash

	# Define variables for input and output
	input_file="!{niiFile.getName()}"
	output_file="defaced_!{niiFile.simpleName}.nii.gz"
	input_dir="$(dirname '!{niiFile}')"
	singularity_img="!{params.singularityImg}"

	# Run pydeface using Singularity
	singularity run \
    	--bind "${input_dir}:/input" \
    	"${singularity_img}" \
    	pydeface /input/"${input_file}" \
    	--outfile "${output_file}"
	'''
}
