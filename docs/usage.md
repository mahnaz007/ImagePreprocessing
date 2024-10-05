# imagepreprocessing: Usage

> _Documentation of pipeline parameters is generated automatically from the pipeline schema and can no longer be found in markdown files._

## Introduction
# Preprocessing Pipeline for Neuroimaging Data (BIDSing, BIDS-Validation, and Defacing)
This pipeline automates the preprocessing of neuroimaging data, including conversion Dicom data to the BIDS format, validation of the dataset, and defacing. It is designed for users working with neuroimaging data who need an efficient and standardized way to manage preprocessing steps before applying further analysis.

The pipeline consists of five main steps:
- **BIDsing**: Converting raw neuroimaging data (e.g., DICOM) into BIDS format.
- **BIDS Validation**: Validating the converted BIDS dataset to ensure compliance with the BIDS standard.
- **Defacing**: Applying defacing to NIfTI files in the anatomical data by removing facisal features.
- **MRIQC**: Performing quality control checks on the anatomical and functional data.
- - **fMRIPrep**: : Preprocessing functional MRI data for subsequent analysis.

## Prerequisites
Before running this pipeline, ensure you have the following installed:

- [Nextflow](https://www.nextflow.io/)
- [Apptainer/Singularity](https://apptainer.org/) or [Singularity](https://sylabs.io/)
- [bids-validator](https://github.com/bids-standard/bids-validator)
- [FSL](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FSL) (for NIfTI file handling)
- [MRIQC](https://github.com/poldracklab/mriqc) (for quality control of MRI data)
- [fMRIPrep](https://fmriprep.org/en/stable/) (for preprocessing functional MRI data)


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

### Step 4: MRIQC

**Input**:
    BIDS-structured dataset from the Defacing step
    
**Output**:
MRIQC reports (mriqc_reports/ directory) containing quality metrics and visualizations for each subject and session.

### Step 5: fMRIPrep
**Input**:
    BIDS-structured dataset from the Defacing step
    
**Output**:
fMRIPrep outputs (fmriprep_outputs/ directory) containing preprocessed functional and anatomical data.

## Running the pipeline

### General Instructions

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

### Step 4: Run the Nextflow Pipeline:
The Nextflow pipeline scripts for each process, such as dcm2bids, pydeface,etc are organized in the modules/local/ directory. Please should refer to these individual scripts if you wish to run or modify specific parts of the pipeline.
You can run your Nextflow pipeline with the default or customized paths.
The typical command for running the pipeline is as follows:

```bash
nextflow run modules/local/module_name.nf
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

### Running DCM2BIDS batch script
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

### Running BIDS Validator batch script

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
### Running Pydeface batch script

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
