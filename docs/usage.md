# imagepreprocessing: Usage

> _Documentation of pipeline parameters is generated automatically from the pipeline schema and can no longer be found in markdown files._
## Option 1: Running the Entire Pipeline Using Nextflow

To run the 4 preprocessing steps (except fMRIPrep) together by executing the nextflow pipeline. This approach automates the execution of the entire pipeline using this command.
```
nextflow run main.nf
```
## Option 2: Running Each Process Separately Using Batch Scripts

If you want to run each process individually, you can use batch scripts using Apptainer or Singularity containers. This approach allows you to manage the execution of each pipeline step (e.g., DCM2BIDS, Pydeface, MRIQC) separately, without the need for Nextflow automation. 

## Introduction
# Preprocessing Pipeline for Neuroimaging Data (BIDSing, BIDS-Validation, Defacing, MRIQC, and fMRIPrep)
**IP18042024/imagepreprocessing** is a bioinformatics pipeline that automates the preprocessing of neuroimaging data, including conversion Dicom data to the BIDS format, validation of the dataset, defacing, MRIQC for quality control, and fMRIPrep for functional MRI preprocessing. It is designed for users working with neuroimaging data who need an efficient and standardized way to manage preprocessing steps before applying further analysis.

This pipeline ingests raw neuroimaging data in DICOM format and processes it through BIDS conversion, validation, and quality control. It outputs preprocessed, ready-to-analyze MRI data for further analysis.

The pipeline consists of five main steps:
- **BIDsing**: Converting raw neuroimaging data (e.g., DICOM) into BIDS format.
- **BIDS Validation**: Validating the converted BIDS dataset to ensure compliance with the BIDS standard.
- **Defacing**: Applying defacing to NIfTI files in the anatomical data by removing facisal features.
- **MRIQC**: Performing quality control checks on the anatomical and functional data.
- **fMRIPrep**: : Preprocessing functional MRI data for subsequent analysis.

## Prerequisites
Before running this pipeline, ensure you have the following installed:
- [Apptainer](https://apptainer.org/) and [Singularity](https://sylabs.io/)
- [bids-validator](https://github.com/bids-standard/bids-validator)
- [dcm2bids](https://github.com/UNFmontreal/Dcm2Bids)
- [FSL](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FSL) (for NIfTI file handling)
- [MRIQC](https://github.com/poldracklab/mriqc) (for quality control of MRI data)
- [fMRIPrep](https://fmriprep.org/en/stable/) (for preprocessing functional MRI data)
**Note**: fMRIPrep requires the FreeSurfer license. You can download the FreeSurfer license [here](https://surfer.nmr.mgh.harvard.edu/registration.html).

Make sure these tools are accessible in your environment, with the paths to the necessary containers (e.g., dcm2bids and pydeface) are correctly set up.

Additionally, ensure the following Singularity .sif container files are correctly installed and accessible in your environment:

    dcm2bids_3.2.0.sif – Required for DICOM to BIDS conversion.
    mriqc-latest.sif – Required for running MRIQC for quality control.
    fmriprep_latest.sif – Required for fMRI preprocessing.
    pydeface_latest.sif – Used for defacing anatomical data.
    bids_validator_latest.sif – Used for validating BIDS datasets.
    
### 1. dcm2bids_3.2.0.sif
- Source Code: Dcm2Bids GitHub Repository[https://github.com/UNFmontreal/Dcm2Bids]
- Version: 3.2.0
- Singularity Recipe:
- Create a Singularity image using the Docker image available on Docker Hub.
- Steps to Build:
    ```
    singularity build dcm2bids_3.2.0.sif docker://cbedetti/dcm2bids:3.2.0
    ```

### 2. bids_validator_latest.sif
- Source Code: BIDS Validator GitHub Repository[https://github.com/bids-standard/bids-validator]
- Version: 1.14.13
- Singularity Recipe:
- The BIDS Validator has an official Docker image.
- Steps to Build:
    ```
    singularity build bids_validator_latest.sif docker://bids/validator:latest
    ```

### 3. mriqc-latest.sif
- Source Code: MRIQC GitHub Repository[https://github.com/nipreps/mriqc]
- Version: v24.1.0.dev0+gd5b13cb5.d20240826
- Latest Version: Check the GitHub releases for the most recent version.
- Singularity Recipe:
- MRIQC provides Docker images that can be converted into Singularity images.
- Steps to Build:
    ```
    singularity build mriqc-latest.sif docker://nipreps/mriqc:latest
    ```
### 4. pydeface_latest.sif
- Source Code: PyDeface GitHub Repository[https://github.com/poldracklab/pydeface]
- Version: 2.0.0
- Singularity Recipe:
- Using a community-maintained image
- Steps to Build (using a community Docker image):
    ```
    singularity build pydeface_latest.sif docker://neuroinformatics/pydeface:latest
    ```

### 5. fmriprep_latest.sif
- Source Code: fMRIPrep GitHub Repository[https://github.com/nipreps/fmriprep]
- Version: v24.0.1
- Latest Version: Refer to the GitHub repository for updates.
- Singularity Recipe:
- fMRIPrep offers Docker images which is suitable for conversion.
- Steps to Build:
    ```
    singularity build fmriprep_latest.sif docker://nipreps/fmriprep:latest
    ```
Make sure these .sif container files are downloaded and placed in an accessible directory. If it is needed, you can create them using the appropriate Singularity or Apptainer commands.

## Pipeline Workflow

### Step 1: BIDSing (Convert DICOM to BIDS)
The first step of the pipeline converts raw neuroimaging data - DICOM files - into the standardized BIDS format using the `dcm2bids` tool. This ensures that the dataset is structured in a way that is widely accepted and compatible with various neuroimaging analysis tools.

**Process**: `ConvertDicomToBIDS`

**Input**:
- DICOM files (e.g.,  01_AAHead_Scout_r1, 05_gre_field_mapping_MIST, etc.) - data from an MRI scan.
- Configuration file (config.json) - used in the dcm2bids process to map DICOM metadata to the BIDS format. You can find the full configuration file [here](https://github.com/mahnaz007/ImagePreprocessing/blob/main/assets/configPHASEDIFF_B0identifier.json).
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
If the same subject has multiple sessions (e.g., different MRI scans at different time points), the input data should reflect this, and the pipeline will automatically manage the sessions. 
**Note**: Files that do not explicitly indicate session information (e.g., IRTG01_001002_b20080101) will be considered as belonging to session 01 (ses-01). 

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
Once the data is converted to BIDS format, the pipeline performs validation using the `bids-validator`tool. This tool checks that the dataset complies with the BIDS standard, ensuring that the format and required metadata are correct.

**Process**: `ValidateBIDS`

**Input**:
- BIDS dataset from the previous step

**Output**:
- Log indicating success or any issues found during validation

### Step 3: Defacing
The third preprocessing step involves defacing the anatomical NIfTI files to remove participants' facial features. This step utilizes Pydeface to process the files stored in the anat folder.

**Process**: `PyDeface`

**Input**:
- NIfTI files (from the `anat` folder)

**Output**:
- Defaced NIfTI files (`defaced_*.nii.gz`)

### Step 4: MRIQC

**Input**:
    BIDS-structured dataset 
    
**Output**:
- HTML reports (mriqc_reports/ directory) containing quality metrics and visualizations for each subject and session.
- SVG figures that generate visualizations such as histograms, noise maps, and segmentation plots in SVG format.

### Step 5: fMRIPrep
Before running fMRIPrep, make sure to update your dataset:
- If any non-4D BOLD images exist, remove them to avoid errors during preprocessing.
- After removing the non-4D BOLD images, you must update the corresponding fmap files. Ensure that the IntendedFor field in the fmap metadata points to the correct BOLD files.
- If, after removing non-4D BOLD files, only one run remains, rename the file to remove the run-01 suffix to ensures the dataset complies with the BIDS standard.

**Input**:
    BIDS-structured dataset 
    
**Output**:
- fMRIPrep outputs (fmriprep_outputs/ directory) containing preprocessed functional and anatomical data.
- HTML reports for quality control metrics.
- SVG figures that display multiple visualizations, including brain masks and quality control.

## Running the pipeline

### General Instructions

### Step 1: Set Up Proxy Identification

Before running Nextflow and executing any process seperately, such as Pydeface, DCM2BIDS, or MRIQC, ensure that you have set the proxy variables that allow Singularity and Git to access the internet through your proxy. Typically, the required commands look like this:

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
The Nextflow pipeline scripts for each process, such as dcm2bids, pydeface, are organized The Nextflow pipeline scripts for each process, such as dcm2bids and pydeface, are organized [here](https://github.com/mahnaz007/ImagePreprocessing/tree/main/modules/local).
 directory. Please refer to these individual scripts if you wish to run or modify specific parts of the pipeline.
The typical command for running the pipeline is:

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
nextflow run main.nf -profile singularity
```
-resume: Continue the pipeline from where it left off using cached results.
```
nextflow run main.nf -profile singularity -resume
```
-c: Specify a custom configuration file for resource allocation or tool-specific options
```
nextflow run main.nf -profile singularity -c /path/to/custom.config
```
## Running the Pipeline Processes without nextflow (using Batch script). 
For each pipeline step, different processes such as DCM2BIDS, Pydeface, and MRIQC need to be executed using specific command-line batch scripts. These commands are intended for users who are containerizing the execution environment with Apptainer or Singularity, ensuring consistent and reproducible results. Each process can be run independently by specifying the appropriate commands for the desired task.

### Running DCM2BIDS 
#### For running 1 participant
```
#!/bin/bash

# Define variables for paths to make the script easier to manage
DICOM_DIR="/home/mzaz021/BIDSProject/sourcecode/IRTG01/IRTG01_001001_S1_b20060101/"
CONFIG_FILE="/home/mzaz021/BIDSProject/code/configPHASEDIFF_B0identifier.json"
OUTPUT_DIR="/home/mzaz021/BIDSProject/dcm2bidsSin"
SIF_FILE="/home/mzaz021/dcm2bids_3.2.0.sif"
PARTICIPANT_LABEL="001001"
SESSION_LABEL="01"

# Apptainer command to run the dcm2bids process
apptainer run -e --containall \
  -B "$DICOM_DIR:/dicoms:ro" \
  -B "$CONFIG_FILE:/config.json:ro" \
  -B "$OUTPUT_DIR:/bids" \
  "$SIF_FILE" \
  -o /bids \
  -d /dicoms \
  -c /config.json \
  -p "$PARTICIPANT_LABEL" \
  -s "$SESSION_LABEL"
```
#### For running the entire project
```
#!/bin/bash
# Define the base directory
bidsdir="/home/mzaz021/BIDSProject"
sourceDir="/home/mzaz021/BIDSProject/sourcecode/IRTG01"

# Loop through all subdirectories in the source directory
for folder in "$sourceDir"/*/; do
	if [ -d "$folder" ]; then
    	# Extract subject and session from the folder name
    	subject=$(basename "$folder" | cut -d '_' -f 2)
    	sesStr=$(basename "$folder" | cut -d '_' -f 3)
    	ses=$(echo "$sesStr" | grep -oP 'S\K\d+')
   	 
    	# Set session to 01 if not specified
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

### Running BIDS Validator 
#### For runnig 1 participant
```
#!/bin/bash

# Define variables for paths to make the script easier to manage
VALIDATOR_SIF="/home/mzaz021/validator_latest.sif"
INPUT_DIR="/home/mzaz021/BIDSProject/preprocessingOutputDir/09B0identifier/sub-009002/"
LOG_DIR="/home/mzaz021/BIDSProject/bidsValidatorLogs"
LOG_FILE="validation_log.txt"

# Make sure the log directory exists
mkdir -p "$LOG_DIR"

# Singularity command to run the BIDS Validator
singularity run --cleanenv \
  "$VALIDATOR_SIF" \
  "$INPUT_DIR" \
  --verbose > "$LOG_DIR/$LOG_FILE" 2>&1
```
#Creates a log in the output directory

#### For runnig the entire project
```
#!/bin/bash
input_dir="/home/mzaz021/BIDSProject/preprocessingOutputDir/09B0identifier"
output_dir="/home/mzaz021/BIDSProject/bidsValidatorLogs"

# Loop through all participant folders (assuming they are named 'sub-XXXXXX')
for participant in "$input_dir"/sub-*; do
    participant_id=$(basename "$participant")
    echo "Running BIDS validation for $participant_id..."

    # Run bids-validator for each participant and save the log in bidsValidatorLogs
    singularity run --cleanenv \
        /home/mzaz021/validator_latest.sif \
        "$participant" \
        --verbose > "$output_dir/${participant_id}_validation_log.txt" 2>&1

    echo "Log saved for $participant_id at $output_dir/${participant_id}_validation_log.txt"
done
```
### Running Pydeface 
#### For runnig 1 participant 
```
#!/bin/bash

# Define variables for paths to make the script easier to manage
INPUT_DIR="/home/mzaz021/BIDSProject/preprocessingOutputDir/09/sub-009002/ses-01/anat"
OUTPUT_DIR="/home/mzaz021/BIDSProject/newPydeface"
SIF_FILE="/home/mzaz021/pydeface_latest.sif"
INPUT_FILE="sub-009002_ses-01_T1w.nii.gz"
OUTPUT_FILE="sub-009002_ses-01_T1w_defaced.nii.gz"

# Singularity command to run Pydeface
singularity run \
  --bind "$INPUT_DIR:/input" \
  --bind "$OUTPUT_DIR:/output" \
  "$SIF_FILE" \
  pydeface /input/"$INPUT_FILE" \
  --outfile /output/"$OUTPUT_FILE"
```

#### For running the entire project
```
#!/bin/bash

INPUT_BASE="/home/mzaz021/BIDSProject/preprocessingOutputDir/09"
OUTPUT_BASE="/home/mzaz021/BIDSProject/newPydeface"
CONTAINER="/home/mzaz021/pydeface_latest.sif"

# Loop through subjects and sessions to run Pydeface
for subject_dir in "$INPUT_BASE"/sub-*/; do
    for session_dir in "$subject_dir"/ses-*/; do
        anat_dir="${session_dir}anat"
        if [[ -d "$anat_dir" ]]; then
            for nifti_file in "$anat_dir"/*.nii.gz; do
                output_dir="${OUTPUT_BASE}/$(basename "$subject_dir")/$(basename "$session_dir")/anat"
                mkdir -p "$output_dir"
                
                # Run pydeface with Singularity
                singularity run \
                    --bind "$session_dir":/input \
                    --bind "$output_dir":/output \
                    "$CONTAINER" \
                    pydeface "/input/anat/$(basename "$nifti_file")" \
                    --outfile "/output/$(basename "$nifti_file" .nii.gz)_defaced.nii.gz"
            done
        fi
    done
done
```
### Running MRIQC 
#### For running 1 participant
```
#!/bin/bash

# Define variables for paths to make the script easier to manage
SIF_FILE="/home/mzaz021/mriqc_24.0.2.sif"
INPUT_DIR="/home/mzaz021/BIDSProject/preprocessingOutputDir/01"
OUTPUT_DIR="/home/mzaz021/BIDSProject/new_mriqcOutput"
PARTICIPANT_LABEL="001004"
NPROCS=4
OMP_THREADS=4
MEM_GB=8

# Singularity command to run MRIQC
singularity run \
  "$SIF_FILE" \
  "$INPUT_DIR" \
  "$OUTPUT_DIR" \
  participant \
  --participant-label "$PARTICIPANT_LABEL" \
  --nprocs "$NPROCS" \
  --omp-nthreads "$OMP_THREADS" \
  --mem_gb "$MEM_GB" \
  --no-sub \
  -vvv \
  --verbose-reports
```
#### For running the entire project
```
#!/bin/bash

input_dir="/home/mzaz021/BIDSProject/preprocessingOutputDir/01"
output_dir="/home/mzaz021/BIDSProject/new_mriqcOutput"
# Path to your MRIQC work directory
work_dir="/home/mzaz021/BIDSProject/work"
singularity_image="/home/mzaz021/mriqc_24.0.2.sif"

# Loop through each participant folder starting with 'sub-'
for participant in $(ls $input_dir | grep 'sub-'); do
	echo "Running MRIQC on $participant"
	singularity run --bind $work_dir:$work_dir $singularity_image \
    	$input_dir $output_dir participant \
    	--participant_label ${participant#sub-} \
    	--nprocs 4 \
    	--omp-nthreads 4 \
    	--mem_gb 8 \
    	--no-sub \
    	-vvv \
    	--verbose-reports \
    	--work-dir $work_dir
	echo "Finished processing $participant"
done
```
### Running fMRIPrep 
#### For running 1 participant
```
#!/bin/bash

# Define variables for paths to make the script easier to manage
SIF_FILE="/home/mzaz021/fmriprep_latest.sif"
INPUT_DIR="/home/mzaz021/BIDSProject/preprocessingOutputDir/09B0identifier"
OUTPUT_DIR="/home/mzaz021/BIDSProject/fmriPreprocessing/09"
PARTICIPANT_LABEL="009004"
FS_LICENSE_FILE="/home/mzaz021/freesurfer/license.txt"
OMP_THREADS=1
RANDOM_SEED=13

# Singularity command to run fMRIPrep
singularity run --cleanenv \
  "$SIF_FILE" \
  "$INPUT_DIR" \
  "$OUTPUT_DIR" \
  participant \
  --participant-label "$PARTICIPANT_LABEL" \
  --fs-license-file "$FS_LICENSE_FILE" \
  --skip_bids_validation \
  --omp-nthreads "$OMP_THREADS" \
  --random-seed "$RANDOM_SEED" \
  --skull-strip-fixed-seed
```


```

