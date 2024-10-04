# imagepreprocessing: Usage

> _Documentation of pipeline parameters is generated automatically from the pipeline schema and can no longer be found in markdown files._

## Introduction
# Preprocessing Pipeline for Neuroimaging Data (BIDSing, BIDS-Validation, and Defacing)
This pipeline automates the preprocessing of neuroimaging data, including conversion Dicom data to the BIDS format, validation of the dataset, and defacing. It is designed for users working with neuroimaging data who need an efficient and standardized way to manage preprocessing steps before applying further analysis.

The pipeline consists of three main steps:
- **BIDsing**: Converting raw neuroimaging data (e.g., DICOM) into BIDS format.
- **BIDS Validation**: Validating the converted BIDS dataset to ensure compliance with the BIDS standard.
- **Defacing**: Applying defacing to NIfTI files in the anatomical data to anonymize participants.

This guide will walk you through the setup, usage, and execution of the preprocessing pipeline.

## Prerequisites
Before running this pipeline, ensure you have the following installed:

- [Nextflow](https://www.nextflow.io/)
- [Apptainer/Singularity](https://apptainer.org/) or [Singularity](https://sylabs.io/)
- [bids-validator](https://github.com/bids-standard/bids-validator)
- [FSL](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FSL) (for NIfTI file handling)

Make sure these tools are accessible in your environment, and that the paths to necessary containers (e.g., dcm2bids and pydeface) are correctly set up.

## Pipeline Workflow

### Step 1: BIDSing (Convert DICOM to BIDS)
The first step of the pipeline is converting raw neuroimaging data, such as DICOM files, into the standardized BIDS format using the `dcm2bids` tool. This ensures that the dataset is structured in a way that is widely accepted and compatible with various neuroimaging analysis tools.

**Process**: `ConvertDicomToBIDS`

**Input**:
- DICOM files (e.g.,  01_AAHead_Scout_r1, 05_gre_field_mapping_MIST, etc.) appears to be organized DICOM data from an MRI scan.
- Configuration file (config.json) is used in the dcm2bids process to map DICOM metadata to the BIDS format.
 ##Example of DIcom input structure:

```
input/
IRTG01/
├── 01_AAHead_Scout_r1/
├── 02_AAHead_Scout_r1_MPR_sag/
├── 03_AAHead_Scout_r1_MPR_cor/
├── 05_gre_field_mapping_MIST/
└── ... (other DICOM folders)
```

**Output**:
- NIfTI files (.nii.gz): The actual neuroimaging data converted from DICOM.
- JSON metadata files (.json): Associated metadata for each NIfTI file, providing information about the scan and its parameters.
- Sidecar files: Such as .bvec and .bval files for diffusion-weighted imaging (DWI), if applicable.

##Multiple Session
If the same subject has two sessions (e.g., different MRI scans at different time points), the input data should reflect this, and the pipeline will automatically manage the sessions. Below is an example structure:

##Example of BIDS-compliant output structure:

```
output/
├── sub-001001
│   ├── ses-01
│   │   ├── anat
│   │   │   ├── sub-001001_ses-01_T1w.nii.gz              # NIfTI file (T1-weighted image)
│   │   │   ├── sub-001001_ses-01_T1w.json                # Metadata for T1w image
│   │   │   ├── sub-001001_ses-01_T2w.nii.gz              # NIfTI file (T2-weighted image)
│   │   │   ├── sub-001001_ses-01_T2w.json                # Metadata for T2w image
│   │   ├── func
│   │   │   ├── sub-001001_ses-01_task-rest_dir-AP_bold.nii.gz   # NIfTI file for BOLD fMRI
│   │   │   ├── sub-001001_ses-01_task-rest_dir-AP_bold.json     # Metadata for BOLD fMRI
│   │   ├── fmap
│   │   │   ├── sub-001001_ses-01_run-01_magnitude1.nii.gz       # NIfTI file for magnitude fieldmap
│   │   │   ├── sub-001001_ses-01_run-01_magnitude1.json         # Metadata for magnitude1
│   │   │   ├── sub-001001_ses-01_run-01_phasediff.nii.gz        # NIfTI file for phase difference map
│   │   │   ├── sub-001001_ses-01_run-01_phasediff.json          # Metadata for phase difference map
│   │   ├── dwi
│   │   │   ├── sub-001001_ses-01_acq-DGD006_dir-PA_dwi.nii.gz   # NIfTI file for diffusion-weighted imaging
│   │   │   ├── sub-001001_ses-01_acq-DGD006_dir-PA_dwi.bvec     # Diffusion gradient directions
│   │   │   ├── sub-001001_ses-01_acq-DGD006_dir-PA_dwi.bval     # Diffusion weighting factors
│   │   │   ├── sub-001001_ses-01_acq-DGD006_dir-PA_dwi.json     # Metadata for DWI
│   ├── ses-02
│   │   ├── anat
│   │   │   ├── sub-001001_ses-02_T1w.nii.gz              # NIfTI file for session 2
│   │   │   └── sub-001001_ses-02_T1w.json                # Metadata for session 2
├── dataset_description.json  # Metadata file describing the dataset
├── participants.tsv          # Participant-level metadata
└── README                    # Optional readme file describing the dataset
```



### Step 2: BIDS Validation
Once the data is converted to BIDS format, the pipeline performs validation using the `bids-validator`. This step checks that the dataset complies with the BIDS standard, ensuring that the format and required metadata are correct.

**Process**: `ValidateBIDS`

**Input**:
- BIDS dataset from the previous step

**Output**:
- Log indicating success or any issues found during validation

### Step 3: Defacing
The final preprocessing step is defacing the anatomical NIfTI files to anonymize participants by removing facial features. This step uses `pydeface` to process files located in the `anat` folder.

**Process**: `PyDeface`

**Input**:
- NIfTI files (from the `anat` folder)

**Output**:
- Defaced NIfTI files (`defaced_*.nii.gz`)


## Samplesheet input

You will need to create a samplesheet with information about the samples you would like to analyse before running the pipeline. Use this parameter to specify its location. It has to be a comma-separated file with 3 columns, and a header row as shown in the examples below.

```bash
--input '[path to samplesheet file]'
```

### Multiple runs of the same sample

The `sample` identifiers have to be the same when you have re-sequenced the same sample more than once e.g. to increase sequencing depth. The pipeline will concatenate the raw reads before performing any downstream analysis. Below is an example for the same sample sequenced across 3 lanes:

```csv title="samplesheet.csv"
sample,fastq_1,fastq_2
CONTROL_REP1,AEG588A1_S1_L002_R1_001.fastq.gz,AEG588A1_S1_L002_R2_001.fastq.gz
CONTROL_REP1,AEG588A1_S1_L003_R1_001.fastq.gz,AEG588A1_S1_L003_R2_001.fastq.gz
CONTROL_REP1,AEG588A1_S1_L004_R1_001.fastq.gz,AEG588A1_S1_L004_R2_001.fastq.gz
```

### Full samplesheet

The pipeline will auto-detect whether a sample is single- or paired-end using the information provided in the samplesheet. The samplesheet can have as many columns as you desire, however, there is a strict requirement for the first 3 columns to match those defined in the table below.

A final samplesheet file consisting of both single- and paired-end data may look something like the one below. This is for 6 samples, where `TREATMENT_REP3` has been sequenced twice.

```csv title="samplesheet.csv"
sample,fastq_1,fastq_2
CONTROL_REP1,AEG588A1_S1_L002_R1_001.fastq.gz,AEG588A1_S1_L002_R2_001.fastq.gz
CONTROL_REP2,AEG588A2_S2_L002_R1_001.fastq.gz,AEG588A2_S2_L002_R2_001.fastq.gz
CONTROL_REP3,AEG588A3_S3_L002_R1_001.fastq.gz,AEG588A3_S3_L002_R2_001.fastq.gz
TREATMENT_REP1,AEG588A4_S4_L003_R1_001.fastq.gz,
TREATMENT_REP2,AEG588A5_S5_L003_R1_001.fastq.gz,
TREATMENT_REP3,AEG588A6_S6_L003_R1_001.fastq.gz,
TREATMENT_REP3,AEG588A6_S6_L004_R1_001.fastq.gz,
```

| Column    | Description                                                                                                                                                                            |
| --------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `sample`  | Custom sample name. This entry will be identical for multiple sequencing libraries/runs from the same sample. Spaces in sample names are automatically converted to underscores (`_`). |
| `fastq_1` | Full path to FastQ file for Illumina short reads 1. File has to be gzipped and have the extension ".fastq.gz" or ".fq.gz".                                                             |
| `fastq_2` | Full path to FastQ file for Illumina short reads 2. File has to be gzipped and have the extension ".fastq.gz" or ".fq.gz".                                                             |

An [example samplesheet](../assets/samplesheet.csv) has been provided with the pipeline.

## Running the pipeline

### Step 1: Set Up Proxy Identification
Before running Nextflow, ensure that you have set the proxy variables that allow Singularity to access the internet through your proxy. Typically, the required commands would look like this:
```bash
nic
proxy
echo $https_proxy
```
### Step 2: Run the Nextflow Pipeline:
After setting up the proxy, you can run your Nextflow pipeline with the default or customized paths.The typical command for running the pipeline is as follows:

```bash
nextflow run main.nf
```

If you want the flexibility to override these default values, you can still pass them as command-line parameters, which will take precedence over the default values in the script. For example:

```bash
nextflow run main.nf --inputDir /path/to/your/data --outputDir /path/to/output --configFile /path/to/config.json --containerPath_dcm2bids /path/to/dcm2bids.sif --containerPath_pydeface /path/to/pydeface.sif
```

This will launch the pipeline with the `singularity` and 'apptainer' configuration profile. See below for more information about profiles.

Note that the pipeline will create the following files in your working directory:

```bash
work                # Directory containing the nextflow working files
<OUTDIR>            # Finished results in specified location (defined with --outdir)
.nextflow_log       # Log file from Nextflow
# Other nextflow hidden files, eg. history of pipeline runs and old logs.
```
### DCM2BIDS and BIDS-Validator batch script
#### For running 1 participant
```
apptainer run -e --containall \
-B /path/to/source/directory:/dicoms:ro \
-B /path/to/config.json:/config.json:ro \
-B /path/to/output/directory:/bids \
/path/to/dcm2bids_3.2.0.sif \
--auto_extract_entities \
--bids_validate \
-o /bids \
-d /dicoms \
-c /config.json \
-p <participant_id> \
-s <session_id>
```
#### For running the entire project

```
#!/bin/bash
# Define the base directory
bidsdir="/path/to/output"
sourceDir="/path/to/sourcedata"

# Loop over all subdirectories in the source directory
for folder in "$sourceDir"/*/; do
	if [ -d "$folder" ]; then
    	# Extract subject and session from the folder name
    	subject=$(basename "$folder" | cut -d '_' -f 2)
    	sesStr=$(basename "$folder" | cut -d '_' -f 3)
    	ses=$(echo "$sesStr" | grep -oP 'S\K\d+')
   	 
    	# Default session to 01 if empty
    	[ -z "$ses" ] && ses="01"
    	session_label="ses-$(printf '%02d' "$ses")"
    	echo "Processing participant: sub-${subject}, session: $session_label"

    	# Call dcm2bids using Apptainer, without BIDS validation
    	apptainer run \
        	-e --containall \
        	-B "$folder:/dicoms:ro" \
        	-B /path/to/config.json:/config.json:ro \
        	-B "$bidsdir":/bids \
        	/path/to/dcm2bids_3.2.0.sif --auto_extract_entities \
        	-d /dicoms -p "sub-${subject}" -s "$session_label" -c /config.json -o /bids
	else
    	echo "$folder not found."
	fi
done

```
#### Running by nextflow 
```
#!/usr/bin/env nextflow

nextflow.enable.dsl=2

// Set input directory, output directory, config file, and container path (Generalized)
params.inputDir = "input/directory"
params.outputDir = "output/directory"
params.configFile = "input/directory/config.json"
params.containerPath = "input/directory/dcm2bids_3.2.0.sif"  // Path to dcm2bids Apptainer image (version 3.2.0)

// Find all subdirectories inside the input directory
def subDirs = new File(params.inputDir).listFiles().findAll { it.isDirectory() }

if (subDirs.isEmpty()) {
	error "No subdirectories found in the input directory: ${params.inputDir}"
}

workflow {
	// Create a channel from the list of subdirectories and extract participant IDs and session_id
	subDirChannel = Channel
    	.from(subDirs)
    	.map { dir ->
        	def folderName = dir.name
        	// Extract participant ID from the folder name (Generalized Pattern)
        	def participantIDMatch = folderName =~ /PROJECT\d+_(\d+)_/

        	if (!participantIDMatch) {
            	error "Could not extract participant ID from the folder name: ${folderName}"
        	}
       	 
        	def participantID = participantIDMatch[0][1]

        	// Determine the session number (Generalized for S1 and S2)
        	def session_id = folderName.contains("S1") ? "ses-01" :
                        	folderName.contains("S2") ? "ses-02" : "ses-01"

        	return tuple(file(dir), participantID, session_id)  // Include session_id in the tuple
    	}

	// Execute the ConvertDicomToBIDS process with the channel
	bidsFiles = subDirChannel | ConvertDicomToBIDS
}

process ConvertDicomToBIDS {
	tag { participantID }

	publishDir "${params.outputDir}/bids_output", mode: 'copy', saveAs: { filename -> "${filename}" }

	input:
    	tuple path(dicomDir), val(participantID), val(session_id)

	output:
    	path "bids_output/**", emit: bids_files

	script:
	"""
	mkdir -p bids_output
	apptainer run -e --containall -B ${dicomDir}:/dicoms:ro -B ${params.configFile}:/config.json:ro -B ./bids_output:/bids ${params.containerPath} --auto_extract_entities --bids_validate -o /bids -d /dicoms -c /config.json -p ${participantID} | tee bids_output/validation_log_${participantID}.txt
	"""
}

```

### Pydeface batch script

#### For runnig 1 participant 
```
singularity run \
   --bind /path/to/input/directory:/input \ (should follow the BIDS structure)
   --bind /path/to/output/directory:/output \
   /path/to/pydeface_0.3.0.sif \
   pydeface /input/sub-<subject>_ses-<session>_T1w.nii.gz \
   --outfile /output/sub-<subject>_ses-<session>_T1w_defaced.nii.gz
```

#### For running the entire project
```
#!/bin/bash

# Path to the Singularity container
CONTAINER="/path/to/pydeface_0.3.0.sif"

# Base input and output directories
INPUT_BASE="/path/to/input/directory" (should follow the BIDS structure)
OUTPUT_BASE="/path/to/output/directory"

# Loop through each subject directory in the base input directory
for subject_dir in $INPUT_BASE/sub-*/; do
	# Loop through each session directory within the current subject directory
	for session_dir in $subject_dir/ses-*/; do
    	# Check if the anatomical directory exists
    	anat_dir="${session_dir}anat"
    	if [[ -d "$anat_dir" ]]; then
        	# Loop through each NIfTI file within the anatomical directory
        	for nifti_file in $anat_dir/*.nii.gz; do
            	# Define output directory and ensure it exists
            	output_dir="${OUTPUT_BASE}/$(basename ${subject_dir})/$(basename ${session_dir})/anat"
            	mkdir -p "$output_dir"
           	 
            	# Define output file path
            	output_file="${output_dir}/$(basename "${nifti_file}" .nii.gz)_defaced.nii.gz"
           	 
            	# Run pydeface
            	singularity run \
                	--bind $session_dir:/input \
                	--bind $output_dir:/output \
                	--bind /path/to/home:/home \
                	$CONTAINER \
                	pydeface "/input/anat/$(basename "$nifti_file")" \
                	--outfile "/output/$(basename "$output_file")"
        	done
    	fi
	done
done

```
#### Running by nextflow 
```
#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// Set generalized input directory and output directory
params.inputDir = "input/directory"
params.defacedOutputDir = "output/directory"
params.singularityImg = "path/to/pydeface_0.3.0.sif"  // Specify the version of the Singularity image (0.3.0 in this case)

workflow {
	// Option 1: Use toAbsolutePath() to get absolute paths of NIfTI files
	niiFiles = Channel.fromPath("${params.inputDir}/sub-*/ses-*/anat/*.nii.gz")
                  	.map { file -> file.toAbsolutePath() }

	// Option 2: Remove the map operation (if absolute paths are not needed)
	// niiFiles = Channel.fromPath("${params.inputDir}/sub-*/ses-*/anat/*.nii.gz")

	// Apply defacing to the NIfTI files using Singularity
	niiFiles | PyDeface
}

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

```

### Updating the pipeline

When you run the above command, Nextflow automatically pulls the pipeline code from GitHub and stores it as a cached version. When running the pipeline after this, it will always use the cached version if available - even if the pipeline has been updated since. To make sure that you're running the latest version of the pipeline, make sure that you regularly update the cached version of the pipeline:

nextflow pull nf-core/imagepreprocessing

### Reproducibility

It is a good idea to specify a pipeline version when running the pipeline on your data. This ensures that a specific version of the pipeline code and software are used when you run your pipeline. If you keep using the same tag, you'll be running the same version of the pipeline, even if there have been changes to the code since.

First, go to the [IP18042024/imagepreprocessing releases page](https://github.com/IP18042024/imagepreprocessing/releases) and find the latest pipeline version - numeric only (eg. `1.3.1`). Then specify this when running the pipeline with `-r` (one hyphen) - eg. `-r 1.3.1`. Of course, you can switch to another version by changing the number after the `-r` flag.

This version number will be logged in reports when you run the pipeline, so that you'll know what you used when you look back in the future. 

## Core Nextflow arguments

The pipeline supports standard Nextflow arguments. Here are some key options:

    -profile: Choose a configuration profile such as apptainer and singularity.
    -resume: Continue the pipeline from where it left off using cached results.
    -c: Specify a custom configuration file for resource allocation or tool-specific options
    
nextflow run nf-core/imagepreprocessing --input /data/dicom --output /data/bids_output -profile singularity



### Custom Customization
##Resouce Request

Whilst the default requirements set within the pipeline will hopefully work for most people and with most input data, you may find that you want to customise the compute resources that the pipeline requests. Each step in the pipeline has a default set of requirements for number of CPUs, memory and time. For most of the steps in the pipeline, if the job exits with any of the error codes specified [here](https://github.com/nf-core/rnaseq/blob/4c27ef5610c87db00c3c5a3eed10b1d161abf575/conf/base.config#L18) it will automatically be resubmitted with higher requests (2 x original, then 3 x original). If it still fails after the third attempt then the pipeline execution is stopped.

To change the resource requests, please see the [max resources](https://nf-co.re/docs/usage/configuration#max-resources) and [tuning workflow resources](https://nf-co.re/docs/usage/configuration#tuning-workflow-resources) section of the nf-core website.

### Custom Containers

In some cases you may wish to change which container or conda environment a step of the pipeline uses for a particular tool. By default nf-core pipelines use containers and software from the [biocontainers](https://biocontainers.pro/) or [bioconda](https://bioconda.github.io/) projects. However in some cases the pipeline specified version maybe out of date.

To use a different container from the default container or conda environment specified in a pipeline, please see the [updating tool versions](https://nf-co.re/docs/usage/configuration#updating-tool-versions) section of the nf-core website.

### Custom Tool Arguments

A pipeline might not always support every possible argument or option of a particular tool used in pipeline. Fortunately, nf-core pipelines provide some freedom to users to insert additional parameters that the pipeline does not include by default.

## Running in the background

Nextflow handles job submissions and supervises the running jobs. The Nextflow process must run until the pipeline is finished.

The Nextflow `-bg` flag launches Nextflow in the background, detached from your terminal so that the workflow does not stop if you log out of your session. The logs are saved to a file.

Alternatively, you can use `screen` / `tmux` or similar tool to create a detached session which you can log back into at a later time.
Some HPC setups also allow you to run nextflow within a cluster job submitted your job scheduler (from where it submits more jobs).

## Nextflow memory requirements

In some cases, the Nextflow Java virtual machines can start to request a large amount of memory.
We recommend adding the following line to your environment to limit this (typically in `~/.bashrc` or `~./bash_profile`):

```bash
NXF_OPTS='-Xms1g -Xmx4g'
```
