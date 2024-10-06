#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// Set input directory and output directory
params.inputDir = "/home/mzaz021/BIDSProject/preprocessingOutputDir/09B0identifier"
params.defacedOutputDir = "/home/mzaz021/BIDSProject/defaced/defacedIRTG09"
params.singularityImg = "/home/mzaz021/pydeface_latest.sif"

process PyDeface {
	tag { niiFile.name }

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

workflow {
	// Option 1: Use toAbsolutePath()
	niiFiles = Channel.fromPath("${params.inputDir}/sub-*/ses-*/anat/*.nii.gz")

	// Apply defacing to the NIfTI files using Singularity
	niiFiles | PyDeface
}
