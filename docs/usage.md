# imagepreprocessing: Usage

> _Documentation of pipeline parameters is generated automatically from the pipeline schema and can no longer be found in markdown files._

## Option 1: Running the Entire Pipeline Using Nextflow
To run the four preprocessing steps (except fMRIPrep) together by executing the nextflow pipeline. This approach automates the execution of the entire pipeline. For more details, please refer to the **Running the Pipeline** section.

## Option 2: Running Each Process Separately Using Batch Scripts
If you want to run each process individually, you can use batch scripts with Apptainer or Singularity containers. This approach allows you to manage the execution of each pipeline step (e.g., dcm2Bids, Pydeface, MRIQC) separately, without the need for Nextflow automation. For more details, please refer to the **Running the Pipeline** section.

**Note**: For a visual understanding of how the processes in this pipeline are connected, you can refer to the [IRTG Psychiatry MRI data processing](https://github.com/mahnaz007/ImagePreprocessing/blob/main/docs/IRTG%20Psychiatry%20MRI%20data%20processing.jpg) on GitHub. This image provides a general overview of the entire workflow, helping to clarify how the different steps interact with each other.

## Introduction
# Preprocessing Pipeline for Neuroimaging Data (BIDSing, BIDS-Validation, Defacing, MRIQC, and fMRIPrep)
**IP18042024/imagepreprocessing** is a bioinformatics pipeline that automates the preprocessing of neuroimaging data, including conversion of DICOM data to the BIDS format, validation of the dataset, MRIQC for quality control, defacing, and fMRIPrep for functional MRI preprocessing. It is designed for users working with neuroimaging data who need an efficient and standardized way to manage preprocessing steps before applying further analysis.

This pipeline ingests raw DICOM neuroimaging data into the BIDS format, performs validation, applies quality control and defacing, and preprocesses functional MRI data. The output is fully preprocessed, anonymized MRI data ready for analysis.
The pipeline consists of five main steps:
- **BIDsing**: Converting raw neuroimaging data (e.g., DICOM) into BIDS format.
- **BIDS Validation**: Validating the converted BIDS dataset to ensure compliance with the BIDS standard.
- **MRIQC**: Performing quality control checks on the anatomical and functional data.
- **Defacing**: Applying defacing to NIfTI files in the anatomical data by removing facial features.
- **fMRIPrep**: Preprocessing functional MRI data for subsequent analysis.

## Prerequisites
Before running this pipeline, ensure you have the following installed:
- [Apptainer](https://apptainer.org/) and [Singularity](https://sylabs.io/)
- [BIDS-validator](https://github.com/bids-standard/bids-validator) (for validating BIDS datasets)
- [dcm2bids](https://github.com/UNFmontreal/Dcm2Bids) (for converting DICOM files to BIDS format)
- [FSL](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FSL) (for NIfTI file handling)
- [MRIQC](https://github.com/poldracklab/mriqc) (for quality control of MRI data)
- [fMRIPrep](https://fmriprep.org/en/stable/) (for preprocessing functional MRI data)

**Note**: fMRIPrep requires the FreeSurfer license. You can download the FreeSurfer license [here](https://surfer.nmr.mgh.harvard.edu/registration.html).

Make sure these tools are accessible in your environment, with the paths to the necessary containers (e.g., dcm2Bids and pydeface) are correctly set up.

Additionally, ensure the following Singularity .sif container files are correctly installed and accessible in your environment:

    dcm2bids 3.2.0 – Required for DICOM to BIDS conversion.
    MRIQC v24.1.0.dev0+gd5b13cb5.d20240826 – Required for running MRIQC for quality control.
    fMRIPrep v24.0.1 – Required for fMRI preprocessing.
    pydeface 2.0.0 – Used for defacing anatomical data.
    bids-validator 1.14.13 – Used for validating BIDS datasets.
    
**Note**: In this project, all Singularity Image Format (SIF) files, required for running different processes are stored in a specific directory. This ensures everyone can easily access the necessary files.
Location of these files is in the following path:
  ```
/nic/sw/IRTG
  ```
However, if you need to build any of these images (e.g., if there is an update), you can follow these steps to build them using Singularity or Apptainer.

### Building Singularity Images for Neuroimaging Tools 
#### 1. dcm2bids_3.2.0.sif
- Source Code: Dcm2Bids GitHub Repository[https://github.com/UNFmontreal/Dcm2Bids]
- Docker Hub: [https://hub.docker.com/r/unfmontreal/dcm2bids]
- Version: 3.2.0
- Singularity Recipe:
- Create a Singularity image using the Docker image available on Docker Hub.
- Steps to Build:
    ```
    singularity build dcm2bids_3.2.0.sif docker://cbedetti/dcm2bids:3.2.0
    ```
### 2. bids_validator_latest.sif
- Source Code: BIDS Validator GitHub Repository[https://github.com/bids-standard/bids-validator]
- Docker Hub: [https://hub.docker.com/r/bids/validator]
- Version: 1.14.13
- Singularity Recipe:
- The BIDS Validator has an official Docker image.
- Steps to Build:
    ```
    singularity build bids_validator_latest.sif docker://bids/validator:latest
    ```
### 3. mriqc-latest.sif
- Source Code: MRIQC GitHub Repository [https://github.com/nipreps/mriqc]
- Docker Hub: [https://hub.docker.com/r/nipreps/mriqc]
- Version: v24.1.0.dev0+gd5b13cb5.d20240826
- Latest Version: Check the GitHub releases for the most recent version.
- Singularity Recipe:
- MRIQC provides Docker images that can be converted into Singularity images.
- Steps to Build:
    ```
    singularity build mriqc-latest.sif docker://nipreps/mriqc:latest
    ```
### 4. pydeface_latest.sif
- Source Code: PyDeface GitHub Repository [https://github.com/poldracklab/pydeface]
- Docker Hub: [https://hub.docker.com/r/poldracklab/pydeface]
- Version: 2.0.0 
- Singularity Recipe:
- Using a community-maintained image
- Steps to Build (using a community Docker image):
    ```
    singularity build pydeface_latest.sif docker://neuroinformatics/pydeface:latest
    ```
### 5. fmriprep_latest.sif
- Source Code: fMRIPrep GitHub Repository [https://github.com/nipreps/fmriprep]
- Docker Hub: [https://hub.docker.com/r/nipreps/fmriprep]
- Version: v24.0.1
- Latest Version: Refer to the GitHub repository for updates.
- Singularity Recipe:
- fMRIPrep offers Docker images which is suitable for conversion.
- Steps to Build:
    ```
    singularity build fmriprep_latest.sif docker://nipreps/fmriprep:latest
    ```

## Pipeline Workflow

### Step 1: BIDSing (Convert DICOM to BIDS)
The first step of the pipeline converts raw neuroimaging data - DICOM files - into the standardized BIDS format using the `dcm2bids` tool. This ensures that the dataset is structured in a way that is widely accepted and compatible with various neuroimaging analysis tools.

**Process**: `ConvertDicomToBIDS`

**Input**:
- DICOM files (e.g.,  01_AAHead_Scout_r1, 05_gre_field_mapping_MIST, etc.) - data from an MRI scan.
- Configuration file (config.json) - used in the dcm2bids process to map DICOM metadata to the BIDS format. You can find the full configuration file [here](https://github.com/mahnaz007/ImagePreprocessing/blob/main/assets/configPHASEDIFF_B0identifier.json).
 ### Example of DICOM input structure:
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

### Multiple Session
If the same subject has multiple sessions (e.g., different MRI scans at different time points), the input data should reflect this, and the pipeline will automatically manage the sessions. 
**Note**: Files that do not explicitly indicate session information (e.g., IRTG01_001002_b20080101) will be considered as belonging to session 01 (ses-01). 

### Example of BIDS-compliant Output Structure:
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
Once the data is converted to BIDS format, the pipeline performs validation using the `bids-validator` tool. This tool checks that the dataset complies with the BIDS standard, ensuring that the format and required metadata are correct.

**Process**: `ValidateBIDS`

**Input**:
- BIDS dataset from the previous step

**Output**:
- Log indicating success or any issues found during validation

### Step 3: MRIQC

**Input**:
    BIDS-structured dataset 
    
**Output**:
- HTML reports (mriqc_reports/ directory) containing quality metrics and visualizations for each subject and session.
- SVG figures that generate visualizations such as histograms, noise maps, and segmentation plots in SVG format.

### Step 4: Defacing
The third preprocessing step involves defacing the anatomical NIfTI files to remove participants' facial features. This step utilizes Pydeface to process the files stored in the anat folder.

**Process**: `PyDeface`

**Input**:
- NIfTI files (from the `anat` folder)

**Output**:
- Defaced NIfTI files (`defaced_*.nii.gz`)

### Step 5: fMRIPrep

**Input**:
    BIDS-structured dataset 
    
**Output**:
- fMRIPrep outputs (fmriprep_outputs/ directory) containing preprocessed functional and anatomical data.
- HTML reports for quality control metrics.
- SVG figures that display multiple visualizations, including brain masks and quality control.

## Running the Pipeline

#### General Instructions

##### Step 1: Set Up Proxy Identification

Before running Nextflow and executing any process separately, such as Pydeface, dcm2bids, or MRIQC, ensure that you have set the proxy variables that allow Singularity and Git to access the internet through your proxy. Typically, the required commands look like this:

```bash
nic
proxy
echo $https_proxy
```
##### Step 2: Install the Nextflow
Install [Nextflow](https://www.nextflow.io/docs/stable/install.html)
##### Step 3: Clone the Repository
```
git clone https://github.com/repo-name.git
cd repo-name
```

### Option 1: Running Full Pipeline With Nextflow
 
To preprocess the four processes at once (as discussed in the Usage section), the typical command for running the pipeline is, if you are on the main branch:
```bash
nextflow run main.nf
```
#### Core Nextflow Arguments
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
### Option 2: Running Individual Pipeline Processes with Batch Scripts 
For each pipeline step, different processes such as dcm2Bids, Pydeface, and MRIQC need to be executed using specific command-line batch scripts. These commands are intended for users who are containerizing the execution environment with Apptainer or Singularity, ensuring consistent and reproducible results. Each process can be run independently by specifying the appropriate commands for the desired task.

### Running Dcm2Bids 
#### For Running 1 Participant
```
#!/bin/bash

# Define variables for paths to make the script easier to manage
DICOM_DIR="/path/to/input/dicom/directory/IRTGxx"
CONFIG_FILE="/path/to/config/file/config.json"
OUTPUT_DIR="/path/to/output/directory"
SIF_FILE="$IRTG/sif/dcm2bids_3.2.0.sif"  
PARTICIPANT_LABEL="xxxxxx"  # Update as needed 
SESSION_LABEL="xx"  # Update as needed 

# Apptainer (or Singularity) command to run the dcm2bids process
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
#### For Running the Entire Project
```
#!/bin/bash
# Define the base directory
bidsdir="/path/to/output"
sourceDir="/path/to/input/IRTG01"

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
            -B /path/to/input/config.json:/config.json:ro \
            -B /path/to/output/dcm2bids:/bids \
            "$IRTG/sif/dcm2bids_3.2.0.sif" --auto_extract_entities \
            -d /dicoms -p "sub-${subject}" -s "$session_label" -c /config.json -o /bids
    else
        echo "$folder not found."
    fi
done
```

### Running BIDS Validator
**Note**: Before running BIDS validation, the tmp_dcm2bids directory should be removed to prevent any errors. The tmp_dcm2bids folder is created during the BIDSing process and not further needed.
#### For Running 1 Participant
```
#!/bin/bash

# Define variables for paths to make the script easier to manage
VALIDATOR_SIF="$IRTG/sif/validator_latest.sif"  
INPUT_DIR="/path/to/input/sub-xxxxxx/"
LOG_DIR="/path/to/output"
LOG_FILE="validation_log.txt"

# Make sure the log directory exists
mkdir -p "$LOG_DIR"

# Singularity (or Apptainer) command to run the BIDS Validator
apptainer run --cleanenv \
  "$VALIDATOR_SIF" \
  "$INPUT_DIR" \
  --verbose > "$LOG_DIR/$LOG_FILE" 2>&1
```
#### For Running the Entire Project
```
#!/bin/bash
input_dir="/path/to/input"
output_dir="/path/to/output"

# Loop through all participant folders ('sub-XXXXXX')
for participant in "$input_dir"/sub-*; do
    participant_id=$(basename "$participant")
    echo "Running BIDS validation for $participant_id..."

    # Run bids-validator for each participant and save the log in bidsValidatorLogs
    singularity run --cleanenv \
        "$IRTG/sif/validator_latest.sif" \
        "$participant" \
        --verbose > "$output_dir/${participant_id}_validation_log.txt" 2>&1

    echo "Log saved for $participant_id at $output_dir/${participant_id}_validation_log.txt"
done
```
**Note**: All errors need to be resolved, while warnings do not, though they should be considered.

**Common Errors**:
- code: 54 - BOLD_NOT_4D
- code: 75 - NIFTI_PIXDIM4
-> This can happen due to incomplete sequences. This necessitates a check whether there were any sessions that were started, but not completed. The DICOM files within the sequence folder should be fewer than comparable sequences.

**Common Warnings**:
- code: 38 - INCONSISTENT_SUBJECTS
- code: 39 - INCONSISTENT_PARAMETERS
- code: 97 - MISSING_SESSION
-> Necessitates a check whether these are congruent with the acquired data or if the subjects/sessions did not get converted correctly.

Moreover, a .bidsignore file has been created to prevent certain files from being flagged during the BIDS validation process. This file allows you to tell the BIDS validator to ignore specific files or patterns that don't adhere to BIDS standards but are still essential for your project.
The contents of the .bidsignore File are as follows: 
```
*_sbref.bval
*_sbref.bvec
*_ADC*
```

### Running MRIQC 
#### For Running 1 Participant
```
#!/bin/bash

# Define variables for paths to make the script easier to manage
SIF_FILE="$IRTG/sif/mriqc_24.0.2.sif"  
INPUT_DIR="/path/to/input" #BIDS dataset 
OUTPUT_DIR="/path/to/output"
PARTICIPANT_LABEL="xxxxxx"  # Update as needed 
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
#### For Running the Entire Project
```
#!/bin/bash

input_dir="/path/to/input" #BIDS dataset
output_dir="/path/to/output"
# Path to your MRIQC work directory
work_dir="/path/to/work/directory"
singularity_image="$IRTG/sif/mriqc_24.0.2.sif"  

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

### Running Pydeface 
#### For Running 1 Participant 
```
#!/bin/bash

# Define variables for paths to make the script easier to manage
INPUT_DIR="/path/to/input/anat" # BIDS dataset
OUTPUT_DIR="/path/to/output"
SIF_FILE="$IRTG/sif/pydeface_latest.sif"  
INPUT_FILE="sub-xxxxxx_ses-xx_T1w.nii.gz"
OUTPUT_FILE="sub-xxxxxx_ses-xx_T1w_defaced.nii.gz"

# Singularity command to run Pydeface
singularity run \
  --bind "$INPUT_DIR:/input" \
  --bind "$OUTPUT_DIR:/output" \
  "$SIF_FILE" \
  pydeface /input/"$INPUT_FILE" \
  --outfile /output/"$OUTPUT_FILE"
```

#### For Running The Entire Project
```
#!/bin/bash

INPUT_BASE="/path/to/input/anat" # BIDS dataset
OUTPUT_BASE="/path/to/output"
CONTAINER="$IRTG/sif/pydeface_latest.sif"  

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

### Running fMRIPrep 
Before running fMRIPrep, make sure to update your dataset:
- If any non-4D BOLD images exist, remove them to avoid errors during preprocessing.
- After removing the non-4D BOLD images, you must update the corresponding fmap files. Ensure that the IntendedFor field in the fmap metadata points to the correct BOLD files.
- If, after removing non-4D BOLD files, only one run remains, rename the file to remove the run-01 suffix to ensure the dataset complies with the BIDS standard.
#### For Running 1 Participant
```
#!/bin/bash

# Define variables for paths to make the script easier to manage
SIF_FILE="$IRTG/sif/fmriprep_latest.sif"  
INPUT_DIR="/path/to/input" #BIDS dataset
OUTPUT_DIR="/path/to/output"
PARTICIPANT_LABEL="xxxxxx"  # Update participant label 
FS_LICENSE_FILE="/path/to/freesurfer/license.txt"
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
