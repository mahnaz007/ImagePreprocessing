# imagepreprocessing: Usage

> _Documentation of pipeline parameters is generated automatically from the pipeline schema and can no longer be found in markdown files._

## Introduction
# Preprocessing Pipeline for Neuroimaging Data (BIDSing, BIDS-Validation, and Defacing)
This pipeline automates the preprocessing of neuroimaging data, including conversion Dicom data to the BIDS format, validation of the dataset, and defacing. It is designed for users working with neuroimaging data who need an efficient and standardized way to manage preprocessing steps before applying further analysis.

The pipeline consists of three main steps:
- **BIDsing**: Converting raw neuroimaging data (e.g., DICOM) into BIDS format.
- **BIDS Validation**: Validating the converted BIDS dataset to ensure compliance with the BIDS standard.
- **Defacing**: Applying defacing to NIfTI files in the anatomical data by removing facisal features.

## Prerequisites
Before running this pipeline, ensure you have the following installed:

- [Nextflow](https://www.nextflow.io/)
- [Apptainer/Singularity](https://apptainer.org/) or [Singularity](https://sylabs.io/)
- [bids-validator](https://github.com/bids-standard/bids-validator)
- [FSL](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FSL) (for NIfTI file handling)

Make sure these tools are accessible in your environment, with the paths to the necessary containers (e.g., dcm2bids and pydeface) are correctly set up.

## Pipeline Workflow

### Step 1: BIDSing (Convert DICOM to BIDS)
The first step of the pipeline is converting raw neuroimaging data, such as DICOM files, into the standardized BIDS format using the `dcm2bids` tool. This ensures that the dataset is structured in a way that is widely accepted and compatible with various neuroimaging analysis tools.

**Process**: `ConvertDicomToBIDS`

**Input**:
- DICOM files (e.g.,  01_AAHead_Scout_r1, 05_gre_field_mapping_MIST, etc.) appears to be DICOM data from an MRI scan.
- Configuration file (config.json) is used in the dcm2bids process to map DICOM metadata to the BIDS format.
 ##Example of DICOM input structure:

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
If the same subject has multiple sessions (e.g., different MRI scans at different time points), the input data should reflect this, and the pipeline will automatically manage the sessions. Files that do not explicitly indicate session information (e.g., IRTG01_001002_b20080101) will be considered as belonging to session 01 (ses-01). Below is an example structure:

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
The third preprocessing step involves defacing the anatomical NIfTI files to remove participants' facial features. This step utilizes pydeface to process the files stored in the anat folder.

**Process**: `PyDeface`

**Input**:
- NIfTI files (from the `anat` folder)

**Output**:
- Defaced NIfTI files (`defaced_*.nii.gz`)

## Running the pipeline

### Step 1: Set Up Proxy Identification

Before running Nextflow, ensure that you have set the proxy variables that allow Singularity to access the internet through your proxy. Typically, the required commands  looks like this:

```bash
nic
proxy
echo $https_proxy
```
### Step 2: Install the Nextflow:
Install [Nextflow](https://www.nextflow.io/docs/stable/install.html)
### Step 3: Clone the Repository
```
git clone https://github.com/repo-name.git
cd repo-name
```

### Step 3: Run the Nextflow Pipeline:
You can run your Nextflow pipeline with the default or customized paths.The typical command for running the pipeline is as follows:

```bash
nextflow run main.nf
```
If you need to specify parameters such as input data or output paths, you can pass them in the command:
```
nextflow run main.nf --input /path/to/input --output /path/to/output
```

## Core Nextflow arguments

The pipeline supports standard Nextflow arguments. Here are some key options:

-profile: Choose a configuration profile such as apptainer and singularity.
```
nextflow run main.nf -profile local
```
-resume: Continue the pipeline from where it left off using cached results.
```
nextflow run main.nf -resume
```
-c: Specify a custom configuration file for resource allocation or tool-specific options

### DCM2BIDS batch script
#### For running 1 participant
```
apptainer run -e --containall \
  -B /home/mzaz021/BIDSProject/sourcecode/IRTG09/IRTG09_009002_S1_b20090101:/dicoms:ro \
  -B /home/mzaz021/BIDSProject/code/configPHASEDIFF_B0identifier.json:/config.json:ro \
  -B /home/mzaz021/BIDSProject/dcm2bidsSin:/bids \
  /home/mzaz021/dcm2bids_3.2.0.sif \
  --auto_extract_entities \
  -o /bids -d /dicoms -c /config.json \
  -p 009002 -s 01
```
#### For running the entire project

```
#!/bin/bash
# Define the base directory
bidsdir="/home/mzaz021/BIDSProject"
sourceDir="/home/mzaz021/BIDSProject/sourcecode/IRTG09"

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
        	-B /home/mzaz021/BIDSProject/code/configPHASEDIFF_B0identifier.json:/config.json:ro \
        	-B /home/mzaz021/BIDSProject/dcm2bidsSin:/bids \
        	/home/mzaz021/dcm2bids_3.2.0.sif --auto_extract_entities \
        	-d /dicoms -p "sub-${subject}" -s "$session_label" -c /config.json -o /bids
	else
    	echo "$folder not found."
	fi
done
```
#### Running using nextflow (this NF script is compined with bids-validator) 
```
#!/usr/bin/env nextflow

nextflow.enable.dsl=2

// Set input directory and output directory
params.inputDir = "/home/mzaz021/BIDSProject/sourcecode/IRTG09"
params.outputDir = "/home/mzaz021/BIDSProject/dcm2bidsNF"
params.configFile = "/home/mzaz021/BIDSProject/code/configPHASEDIFF_B0identifier.json"
params.containerPath = "/home/mzaz021/dcm2bids_3.2.0.sif" // Path to your Apptainer image

// Validate that the input directory exists
if (!new File(params.inputDir).exists()) {
    error "Input directory does not exist: ${params.inputDir}"
}

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
            // Extract participant ID from the folder name using regex
            // Adjust the regex based on your actual folder naming convention
            def participantIDMatch = folderName =~ /IRTG\d+_(\d+)_?/

            if (!participantIDMatch) {
                // Handle cases where the folder name does not match expected pattern
                // Attempt to extract participant ID without trailing underscore
                participantIDMatch = folderName =~ /IRTG\d+_(\d+)$/
                if (!participantIDMatch) {
                    error "Could not extract participant ID from the folder name: ${folderName}"
                }
            }

            def participantID = participantIDMatch[0][1]

            // Determine the session number based on the subfolder's name
            def session_id
            switch (folderName) {
                case ~/.*S1.*/:
                    session_id = "ses-01"
                    break
                case ~/.*S2.*/:
                    session_id = "ses-02"
                    break
                default:
                    session_id = "ses-01" // Default session
            }

            return tuple(file(dir), participantID, session_id)  // Include session_id in the tuple
        }

    // Execute the ConvertDicomToBIDS process with the channel
    bidsFiles = subDirChannel | ConvertDicomToBIDS
}

process ConvertDicomToBIDS {
    tag { "Participant: ${participantID}, Session: ${session_id}" }

    publishDir "${params.outputDir}/bids_output", mode: 'copy', saveAs: { filename -> "${filename}" }

    input:
        tuple path(dicomDir), val(participantID), val(session_id)

    output:
        path "bids_output/**", emit: bids_files

    script:
    """
    mkdir -p bids_output
    apptainer run -e --containall \
        -B ${dicomDir}:/dicoms:ro \
        -B ${params.configFile}:/config.json:ro \
        -B ./bids_output:/bids \
        ${params.containerPath} \
        --auto_extract_entities \
        --bids_validate \
        -o /bids \
        -d /dicoms \
        -c /config.json \
        -p ${participantID} \
        --session ${session_id} | tee bids_output/validation_log_${participantID}.txt
    """
}
```
### BIDS Validator batch script

#### For runnig 1 participant
```
singularity run --cleanenv \
  /home/mzaz021/validator_latest.sif \
  /home/mzaz021/BIDSProject/preprocessingOutputDir/09B0identifier/sub-009002/ \
  --verbose > /home/mzaz021/BIDSProject/bidsValidatorLogs/validation_log.txt 2>&1
#it creates a log in the output directory
```

#### For runnig the entire project
```
#!/bin/bash
input_dir="/home/mzaz021/BIDSProject/preprocessingOutputDir/09B0identifier"
output_dir="/home/mzaz021/BIDSProject/bidsValidatorLogs"
# Create the output directory if it doesn't exist
mkdir -p $output_dir
# Loop through all participant folders (assuming they are named 'sub-XXXXXX')
for participant in $input_dir/sub-*; do
participant_id=$(basename $participant)
echo "Running BIDS validation for $participant_id..."
# Run bids-validator for each participant and save the log in bidsValidatorLogs
singularity run --cleanenv \
/home/mzaz021/validator_latest.sif \
$participant \
--verbose > $output_dir/${participant_id}_validation_log.txt 2>&1
echo "Log saved for $participant_id at $output_dir/${participant_id}_validation_log.txt"
done
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



