nextflow.enable.dsl = 2

process pydeface {

	input:
	val input_file
	val output_file
	val singularity_img
	path input_dir
	path output_dir

	script:
	"""
	singularity run \
  	--bind ${input_dir}:/input \
  	--bind ${output_dir}:/output \
  	${singularity_img} \
  	pydeface /input/${input_file} \
  	--outfile /output/${output_file}
	"""
}

workflow {

	params.input_file = "sub-009002_ses-01_T1w.nii.gz"
	params.output_file = "sub-009002_ses-01_T1w_defaced.nii.gz"
	params.input_dir = "/home/mzaz021/BIDSProject/preprocessingOutputDir/09/sub-009002/ses-01/anat"
	params.output_dir = "/home/mzaz021/BIDSProject/newPydeface"
	params.singularity_img = "/home/mzaz021/pydeface_latest.sif"

	pydeface(
    	params.input_file,
    	params.output_file,
    	params.singularity_img,
    	file(params.input_dir),
    	file(params.output_dir)
	)
}
