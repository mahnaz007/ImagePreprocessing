# imagepreprocessing: Usage  

> _Documentation of pipeline parameters is generated automatically from the pipeline schema and can no longer be found in markdown files._


# Preprocessing Pipeline for Neuroimaging Data (BIDSing, BIDS-Validation, MRIQC, fMRIPrep, and Defacing)

## Introduction
**IP18042024/imagepreprocessing** is a bioinformatics pipeline that automates the preprocessing of neuroimaging data, including conversion of DICOM data to the BIDS format, validation of the dataset, MRIQC for quality control, defacing, and fMRIPrep for functional MRI preprocessing. It is designed for users working with neuroimaging data who need an efficient and standardized way to manage preprocessing steps before applying further analysis.

This pipeline converts raw DICOM neuroimaging data into the BIDS format, performs validation, applies quality control and defacing, and preprocesses functional MRI data. The output is fully preprocessed, anonymized MRI data ready for analysis.
The pipeline consists of five main steps:
- **BIDsing**: Converting raw neuroimaging data (e.g., DICOM) into BIDS format.
- **BIDS Validation**: Validating the converted BIDS dataset to ensure compliance with the BIDS standard.
- **MRIQC**: Performing quality control checks on the anatomical and functional data.
- **fMRIPrep**: Preprocessing functional MRI data for subsequent analysis.
- **Defacing**: Applying defacing to NIfTI files in the anatomical data by removing facial features.




This file covers the sections: 
- **Prerequisites** needed to run the pipeline 
- **Pipeline Workflow** describing the single steps of the pipeline, as well as its input and output structure
- **Running the Pipeline** detailing concrete instructions and example code to run the pipeline and its single modules

### Usage Option 1: Running the Entire Pipeline Using Nextflow
Execute the nextflow pipeline to run the five processes together. This approach automates the execution of the entire pipeline for selected participant. For more details, please refer to the [Running the Pipeline Option 1](https://github.com/mahnaz007/ImagePreprocessing/blob/main/docs/usage.md#option-1-running-full-pipeline-with-nextflow)  section.

### Usage Option 2: Running Each Process Separately Using Bash Scripts
If you want to run each process individually, you can use bash scripts with Apptainer or Singularity containers. This approach allows you to manage the execution of each pipeline step (e.g., dcm2Bids, Pydeface, MRIQC) separately, without the need for Nextflow automation. For more details, please refer to the [Running the Pipeline Option 2](https://github.com/mahnaz007/ImagePreprocessing/blob/main/docs/usage.md#option-2-running-individual-pipeline-processes-with-bash-scripts) section.

**Note**: For a visual understanding of how the processes in this pipeline are connected, you can refer to the [IRTG MRI Preprocessing](https://github.com/mahnaz007/ImagePreprocessing/blob/main/docs/IRTG%20MRI%20Preprocessing.jpg) on GitHub. This image provides a general overview of the entire workflow, helping to clarify how the different steps interact with each other.

## Prerequisites
Before running this pipeline, ensure you have the following installed:
- [Apptainer](https://apptainer.org/) and [Singularity](https://sylabs.io/)
- [BIDS-validator](https://github.com/bids-standard/bids-validator) (for validating BIDS datasets)
- [dcm2bids](https://github.com/UNFmontreal/Dcm2Bids) (for converting DICOM files to BIDS format)
- [MRIQC](https://github.com/poldracklab/mriqc) (for quality control of MRI data)
- [fMRIPrep](https://fmriprep.org/en/stable/) (for preprocessing functional MRI data)
- [FSL](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FSL) (for NIfTI file handling)

**Note**: fMRIPrep requires the FreeSurfer license. You can download the FreeSurfer license [here](https://surfer.nmr.mgh.harvard.edu/registration.html).

Make sure these tools are accessible in your environment, with the paths to the necessary containers (e.g., dcm2Bids and pydeface) are correctly set up.

Additionally, ensure the following Singularity .sif container files are correctly installed and accessible in your environment:

    dcm2bids 3.2.0 – Required for DICOM to BIDS conversion.
    MRIQC 24.0.2 – Required for running MRIQC for quality control.
    fMRIPrep 24.0.1 – Required for fMRI preprocessing.
    pydeface 2.0.0 – Used for defacing anatomical data.
    bids-validator 1.14.13 – Used for validating BIDS datasets.
    
**Note**: In this project, all Singularity Image Format (SIF) files, required for running different processes are stored in a specific directory. This ensures everyone can easily access the necessary files.
Location of these files is in the following path:
  ```
/nic/sw/IRTG
  ```
However, if you need to build any of these container images (e.g., if there is an update), you can follow these steps to build them using Singularity or Apptainer.

### Building Container Images for Neuroimaging Tools 
#### 1. dcm2bids_3.2.0.sif
- Source Code: Dcm2Bids GitHub Repository[https://github.com/UNFmontreal/Dcm2Bids]
- Docker Hub: [https://hub.docker.com/r/unfmontreal/dcm2bids]
- Version: 3.2.0
- Singularity Recipe:
- Create a Singularity image using the Docker image available on Docker Hub.
- Steps to Build:
    ```
    export VERSION=3.2.0
    apptainer pull dcm2bids.sif docker://unfmontreal/dcm2bids:${VERSION}
    ```
#### 2. validator_1.14.13.sif
- Source Code: BIDS Validator GitHub Repository[https://github.com/bids-standard/bids-validator]
- Docker Hub: [https://hub.docker.com/r/bids/validator]
- Version: 1.14.13
- Singularity Recipe:
- The BIDS Validator has an official Docker image.
- Steps to Build:
    ```
    singularity build validator_1.14.13.sif docker://bids/validator:1.14.13
    ```
    
#### 3. mriqc_24.0.2.sif
- Source Code: MRIQC GitHub Repository [https://github.com/nipreps/mriqc]
- Docker Hub: [https://hub.docker.com/r/nipreps/mriqc]
- Version: 24.0.2
- Latest Version: Check the GitHub releases for the most recent version.
- Singularity Recipe:
- MRIQC provides Docker images that can be converted into Singularity images.
- Steps to Build:
    ```
    singularity build mriqc_24.0.2.sif docker://nipreps/mriqc:24.0.2
    ```
    
#### 4. fmriprep_24.0.1.sif
- Source Code: fMRIPrep GitHub Repository [https://github.com/nipreps/fmriprep]
- Docker Hub: [https://hub.docker.com/r/nipreps/fmriprep]
- Version: 24.0.1
- Latest Version: Refer to the GitHub repository for updates.
- Singularity Recipe:
- fMRIPrep offers Docker images which is suitable for conversion.
- Steps to Build:
    ```
    singularity build fmriprep_24.0.1.sif docker://nipreps/fmriprep:24.0.1
    ```
    
#### 5. pydeface_2.0.0.sif
- Source Code: PyDeface GitHub Repository [https://github.com/poldracklab/pydeface]
- Docker Hub: [https://hub.docker.com/r/poldracklab/pydeface]
- Version: 2.0.0 
- Singularity Recipe:
- Using a community-maintained image
- Steps to Build (using a community Docker image):
    ```
    singularity build pydeface_2.0.0.sif docker://poldracklab/pydeface:2.0.0 
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
This pipeline creates a BIDS-compliant output, organized by four main imaging modalities: anatomical, functional, field maps, and diffusion.
- anat (T1w, T2w): Anatomical modality provides High-resolution anatomical images. T1w captures gray/white matter boundaries, T2w captures cerebrospinal fluid and lesions.

- func: Functional MRI shows brain activity by detecting changes in blood oxygen levels, which is useful for mapping brain function during specific tasks and resting states

- fmap: Field maps correct distortions in fMRI and diffusion data due to magnetic field variations.

- dwi: Diffusion-weighted imaging shows water diffusion in tissues, highlighting white matter pathways.
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
Errors need to be addressed, while warnings should be noted; typical errors include BOLD_NOT_4D and NIFTI pixel dimension issues, and common warnings relate to inconsistent subjects, parameters, and missing sessions, with a .bidsignore file created to ignore certain files from BIDS validation.

**Process**: `ValidateBIDS`

**Input**:
- BIDS dataset from the previous step

**Output**:
- Log indicating success or any issues found during validation
  
**Note**:
If you prefer a quick, web-based approach, you can also use the online BIDS validator available at [https://bids-standard.github.io/bids-validator]. This tool provides a convenient way to check your dataset without setting up the containerized version locally.
### Step 3: MRIQC
MRIQC (Magnetic Resonance Imaging Quality Control) is a tool that evaluates the quality of MRI data by calculating standardized quality metrics for structural and functional MRI scans. It helps identify data issues like artifacts or noise, enabling researchers to assess and filter out low-quality scans before analysis, thereby improving the reliability of MRI studies.

**Process**: `runMRIQC`

**Input**:
    BIDS-structured dataset 
    
**Output**:
- HTML reports (mriqc_reports/ directory) containing quality metrics and visualizations for each subject and session.
- SVG figures that generate visualizations such as histograms, noise maps, and segmentation plots in SVG format.

### Step 4: fMRIPrep
fMRIPrep is a robust, automated preprocessing tool for functional magnetic resonance imaging (fMRI) data that corrects for head motion, aligns functional images to anatomical scans, and normalizes data to standard spaces, ensuring compatibility and reproducibility across studies.

> 💡Before running fMRIPrep, make sure to update your dataset:
> - If any non-4D BOLD images exist, remove them to avoid errors during preprocessing.
> - After removing the non-4D BOLD images, you must update the corresponding fmap files. Ensure that the IntendedFor field in the fmap metadata points to the correct BOLD files.
> - If, after removing non-4D BOLD files, only one run remains, rename the file to remove the run-01 suffix to ensures the dataset complies with the BIDS standard.

**Process**: `runFmriprep`

**Input**:
    BIDS-structured dataset 
    
**Output**:
- fMRIPrep outputs (fmriprep_outputs/ directory) containing preprocessed functional and anatomical data.
- HTML reports for quality control metrics.
- SVG figures that display multiple visualizations, including brain masks and quality control.

### Step 5: Defacing
The five preprocessing step involves defacing the anatomical NIfTI files to remove participants' facial features. This step utilizes Pydeface to process the files stored in the anat folder.

**Process**: `PyDeface`

**Input**:
- NIfTI files (from the `anat` folder)

**Output**:
- Defaced NIfTI files (`defaced_*.nii.gz`)

## Running the Pipeline

### General Instructions
This pipeline includes five specific processes. You can view the full main.nf script [here in the repository](https://github.com/mahnaz007/ImagePreprocessing/blob/main/main.nf).
The individual processes for each step in the pipeline are modularized under the [modules/local](https://github.com/mahnaz007/ImagePreprocessing/tree/main/modules/local) directory.

#### First-time usage
These steps need to be completed before the pipeline or its modules are used for the first time.

##### Step 1: Set Up Proxy Identification
Before running Nextflow and executing Pydeface and MRIQC processes separately, ensure that you have set the proxy variables that allow Singularity and Git to access the internet through your proxy. Typically, the required commands look like this:

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

#### Every usage
This step needs to be completed every time a new session or terminal is started before the pipeline or its processes are used.

##### Step 1: Set Up Proxy Identification
Before running Nextflow and executing Pydeface and MRIQC processes separately, ensure that you have set the proxy variables that allow Singularity and Git to access the internet through your proxy. Typically, the required commands look like this:

```bash
nic
proxy
echo $https_proxy
```

### Option 1: Running Full Pipeline With Nextflow
To preprocess the fifth processes at once as discussed in the [Usage](https://github.com/mahnaz007/ImagePreprocessing/blob/main/docs/usage.md#option-1-running-the-entire-pipeline-using-nextflow) section, the typical command for running the pipeline is, if you are on the main branch:
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
### Option 2: Running Individual Pipeline Processes with Bash Scripts 
For each pipeline step, different processes such as dcm2Bids, Pydeface, and MRIQC need to be executed using specific command-line bash scripts. These commands are intended for users who are containerizing the execution environment with Apptainer or Singularity, ensuring consistent and reproducible results. Each process can be run independently by specifying the appropriate commands for the desired task. The example codes are bash commands and can be used directly in a terminal or used, saved and accessed as bash scripts. Make sure to adapt all paths before running the commands.

### Running Dcm2Bids 
#### For Running 1 Participant
```
#!/bin/bash
# Define the base directory, IRTG number, and specific participant
irtg="IRTGxx"  # set the IRTG project (e.g., IRTG02)
participant="xxxxxx"  # set the participant number you want to run (e.g., 002002)
sourceDir="/home/to/input/${irtg}"
outputDir= "/home/to/output" 

# Loop over all subdirectories in the source directory
for folder in "$sourceDir"/*; do
    if [ -d "$folder" ]; then
        # Extract subject and session from the folder name
        subject=$(basename "$folder" | cut -d '_' -f 2)
        
        # Check if the folder is for the specified participant
        if [ "$subject" == "$participant" ]; then
            sesStr=$(basename "$folder" | cut -d '_' -f 3)
            ses=$(echo "$sesStr" | grep -oP 'S\K\d+')

            # Default session to 01 if empty
            [ -z "$ses" ] && ses="01"
            session_label="ses-$(printf '%02d' "$ses")"

            echo "Processing participant: sub-${subject}, session: $session_label"

            # Call dcm2bids using Apptainer, without BIDS validation
            # The --force_dcm2bids option overwrites existing  temporary files 
            apptainer run \
                -e --containall \
                -B "$folder:/dicoms:ro" \
                -B /home/to/config.json:/config.json:ro \
                -B "$outputDir:/bids" \
                /home/to/dcm2bids_3.2.0.sif \
                -d /dicoms -p "sub-${subject}" -s "$session_label" -c /config.json -o /bids --force_dcm2bids
        else
            echo "Skipping participant: sub-${subject}"
        fi
    else
        echo "$folder not found."
    fi
done
```
#### For Running the Entire Project
```
#!/bin/bash
# Define the base directory

sourceDir="/home/to/input"
configFile="/home/to/config.json"
outputDir="/home/to/output"
container="/home/to/dcm2bids_3.2.0.sif"

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
            -B "$configFile:/config.json:ro" \
            -B "$outputDir:/bids" \
            "$container" \
            -d /dicoms -p "sub-${subject}" -s "$session_label" -c /config.json -o /bids
    else
        echo "$folder not found."
    fi
done
```

### Running BIDS Validator
**Note**: Before running BIDS validation, the tmp_dcm2bids directory should be either ignored by adding it to a .bidsignore file or removed manually to prevent any errors. The tmp_dcm2bids folder is created during the BIDSing process and not further needed.
#### For Running 1 Participant
```
#!/bin/bash

# Define variables for paths to make the script easier to manage
VALIDATOR_SIF="$IRTG/sif/validator_1.14.13.sif"  
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
        "$IRTG/sif/validator_1.14.13.sif" \
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

##### Temporary Folder and Log Files

The tmp_dcm2bids logs are one of the files that should be removed or ignored using the .bidsignore file to avoid validation errors related to non-compliant files. These logs are crucial for debugging but aren't part of the final BIDS dataset.

Below are common errors related to the tmp log files:

- code: 1 - NOT_INCLUDED: 
```
./tmp_dcm2bids/log/sub-009002_ses-01_20241016-104413.log
```
- code: 64 - SUBJECT_LABEL_IN_FILENAME_DOESNOT_MATCH_DIRECTORY
- code: 65 - SESSION_LABEL_IN_FILENAME_DOESNOT_MATCH_DIRECTORY
- code: 67 - NO_VALID_DATA_FOUND_FOR_SUBJECT

The contents of the .bidsignore File are as follows: 
```
*_sbref.bval
*_sbref.bvec
*_ADC*
# Ignore all log files under the tmp_dcm2bids/log/ directory
tmp_dcm2bids/log/*
# Ignore all files and subdirectories under the tmp_dcm2bids/ directory
tmp_dcm2bids/**
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
### Running fMRIPrep 
Before running fMRIPrep, make sure to update your dataset:
- If any non-4D BOLD images exist, remove them to avoid errors during preprocessing.
- After removing the non-4D BOLD images, you must update the corresponding fmap files. Ensure that the IntendedFor field in the fmap metadata points to the correct BOLD files.
- If, after removing non-4D BOLD files, only one run remains, rename the file to remove the run-01 suffix to ensure the dataset complies with the BIDS standard.
#### For Running 1 Participant
fMRIPrep is designed to process one session at a time. When you have multiple sessions for the same participant, fMRIPrep may encounter issues all at once. By creating a temporary folder for each session, we isolate that session's data in a clean, single-session dataset.
```
#!/bin/bash

# Define participant and file path variables
PARTICIPANT_LABEL="xxxxxx"                       
INPUT_DIR="/path/to/input"                       
OUTPUT_DIR="/path/to/output"                      
WORK_DIR="/path/to/work"                         
FS_LICENSE_FILE="/path/to/license.txt"            
SIF_FILE="/path/to/fmriprep_24.0.1.sif"            


# Define a writable directory for TemplateFlow cache.
TEMPLATEFLOW_DIR="/path/to/input/templateflow"
mkdir -p "$TEMPLATEFLOW_DIR"                      # Create the TemplateFlow directory if it doesn't exist

# List sessions to process
SESSIONS=("ses-01" "ses-02")                      # Array of session labels

# Loop over each session to process them individually
for SESSION in "${SESSIONS[@]}"; do
    echo "Processing session: $SESSION"         

    # Create a temporary directory to the current session. This ensures that fMRIPrep sees only one session.
    TEMP_BIDS_DIR=$(mktemp -d -t bids_tmp_${PARTICIPANT_LABEL}_${SESSION}_XXXXXX)
    echo "Temporary BIDS directory created: $TEMP_BIDS_DIR"

    # Copy the dataset description file to the root of the temporary BIDS folder.
    cp -v "$INPUT_DIR/dataset_description.json" "$TEMP_BIDS_DIR/"

    # Verify if the dataset_description.json file was successfully copied.
    if [ ! -f "$TEMP_BIDS_DIR/dataset_description.json" ]; then
        echo "Error: dataset_description.json not found in the temporary folder."
        exit 1
    fi

    # Create a subdirectory for the participant in the temporary BIDS folder.
    mkdir -p "$TEMP_BIDS_DIR/sub-${PARTICIPANT_LABEL}"

    # Copy the session-specific data from the input directory to the temporary folder.
    cp -av "$INPUT_DIR/sub-${PARTICIPANT_LABEL}/$SESSION" "$TEMP_BIDS_DIR/sub-${PARTICIPANT_LABEL}/"

    # If anatomical data exists for the participant, copy it as well.
    if [ -d "$INPUT_DIR/sub-${PARTICIPANT_LABEL}/anat" ]; then
        cp -av "$INPUT_DIR/sub-${PARTICIPANT_LABEL}/anat" "$TEMP_BIDS_DIR/sub-${PARTICIPANT_LABEL}/"
    fi

    # If functional data exists as a separate folder, copy it too.
    if [ -d "$INPUT_DIR/sub-${PARTICIPANT_LABEL}/func" ]; then
        cp -av "$INPUT_DIR/sub-${PARTICIPANT_LABEL}/func" "$TEMP_BIDS_DIR/sub-${PARTICIPANT_LABEL}/"
    fi

    # Check if the session folder was correctly copied into the temporary directory.
    if [ ! -d "$TEMP_BIDS_DIR/sub-${PARTICIPANT_LABEL}/$SESSION" ]; then
        echo "Error: session folder $SESSION not found in the temporary directory."
        exit 1
    fi

    # Verify if the functional directory exists within the session folder.
    if [ ! -d "$TEMP_BIDS_DIR/sub-${PARTICIPANT_LABEL}/$SESSION/func" ]; then
        echo "Error: func directory not found for $SESSION in the temporary directory."
        exit 1
    fi

    # List the contents of the temporary BIDS folder for debugging purposes.
    echo "Contents of the temporary BIDS directory:"
    ls -lR "$TEMP_BIDS_DIR"

    # Run fMRIPrep using Singularity with environment variables set to bypass SSL certificate issues.
    SINGULARITYENV_CURL_CA_BUNDLE=/dev/null \
    SINGULARITYENV_SSL_CERT_FILE=/dev/null \
    singularity run --cleanenv \
      --bind "$WORK_DIR":/work \
      --bind "$TEMPLATEFLOW_DIR":/templateflow \
      --env APPTAINERENV_TEMPLATEFLOW_HOME=/templateflow \
      --env APPTAINERENV_http_proxy="$http_proxy" \
      --env APPTAINERENV_https_proxy="$https_proxy" \
      "$SIF_FILE" \
      "$TEMP_BIDS_DIR" \                      # The temporary BIDS input folder
      "$OUTPUT_DIR" \                         # Output directory for fMRIPrep results
      participant \                           # Indicates participant-level processing
      --participant-label "$PARTICIPANT_LABEL" \
      --fs-license-file "$FS_LICENSE_FILE" \
      --skip_bids_validation \                # Skip BIDS validation if already confirmed valid
      --omp-nthreads "$OMP_THREADS" \
      --random-seed "$RANDOM_SEED" \
      --skull-strip-fixed-seed

    # After processing, delete the temporary BIDS directory to free up space.
    echo "Deleting temporary directory: $TEMP_BIDS_DIR"
    rm -rf "$TEMP_BIDS_DIR"
done
```
#### For Running the entire project
```
#!/bin/bash

# Set directories and files
INPUT_DIR="/path/to/input" 
OUTPUT_DIR="/path/to/output"
WORK_DIR="/path/to/work"
FS_LICENSE_FILE="/path/to/license.txt"
SIF_FILE="/path/to/fmriprep_24.0.1.sif"

# Use a writable directory for the TemplateFlow cache
TEMPLATEFLOW_DIR="/path/to/input/templateflow"
mkdir -p "$TEMPLATEFLOW_DIR"

# List sessions to process
SESSIONS=("ses-01" "ses-02")

# Loop over each subject directory found in the BIDS root
for subject_dir in "$BIDS_ROOT"/sub-*; do
  # Check if it is a directory
  if [ -d "$subject_dir" ]; then
    # Extract the subject ID (removing the "sub-" prefix)
    SUBJECT_ID=$(basename "$subject_dir" | sed 's/sub-//')
    echo "Processing subject: $SUBJECT_ID"

    # Loop over sessions for the current subject
    for SESSION in "${SESSIONS[@]}"; do
      echo "Processing session: $SESSION"

      # Create a temporary BIDS directory for the session
      TEMP_BIDS_DIR=$(mktemp -d -t bids_tmp_${SUBJECT_ID}_${SESSION}_XXXXXX)
      echo "Temporary BIDS directory created: $TEMP_BIDS_DIR"

      # Copy dataset_description.json to the temporary BIDS directory
      cp -v "$BIDS_ROOT/dataset_description.json" "$TEMP_BIDS_DIR/"

      if [ ! -f "$TEMP_BIDS_DIR/dataset_description.json" ]; then
          echo "Error: dataset_description.json not found in the temporary folder."
          exit 1
      fi

      # Create subject directory in the temporary folder
      mkdir -p "$TEMP_BIDS_DIR/sub-${SUBJECT_ID}"

      # Copy session data 
      cp -av "$BIDS_ROOT/sub-${SUBJECT_ID}/$SESSION" "$TEMP_BIDS_DIR/sub-${SUBJECT_ID}/"

      # Copy anat data 
      if [ -d "$BIDS_ROOT/sub-${SUBJECT_ID}/anat" ]; then
          cp -av "$BIDS_ROOT/sub-${SUBJECT_ID}/anat" "$TEMP_BIDS_DIR/sub-${SUBJECT_ID}/"
      fi

      #Copy func data
      if [ -d "$BIDS_ROOT/sub-${SUBJECT_ID}/func" ]; then
        cp -av "$BIDS_ROOT/sub-${SUBJECT_ID}/func" "$TEMP_BIDS_DIR/sub-${SUBJECT_ID}/"
      fi
      if [ ! -d "$TEMP_BIDS_DIR/sub-${SUBJECT_ID}/$SESSION" ]; then
          echo "Error: session folder $SESSION not found in the temporary directory."
          exit 1
      fi
      # Copy functional data if available
      if [ ! -d "$TEMP_BIDS_DIR/sub-${SUBJECT_ID}/$SESSION/func" ]; then
          echo "Error: func directory not found for $SESSION in the temporary directory."
          exit 1
      fi

      echo "Contents of the temporary BIDS directory:"
      ls -lR "$TEMP_BIDS_DIR"

      # Run fMRIPrep using Singularity with environment variables to bypass SSL issues
      SINGULARITYENV_CURL_CA_BUNDLE=/dev/null \
      SINGULARITYENV_SSL_CERT_FILE=/dev/null \
      singularity run --cleanenv \
        --bind "$WORK_DIR":/work \
        --bind "$TEMPLATEFLOW_DIR":/templateflow \
        --env APPTAINERENV_TEMPLATEFLOW_HOME=/templateflow \
        --env APPTAINERENV_http_proxy="$http_proxy" \
        --env APPTAINERENV_https_proxy="$https_proxy" \
        "$FMRIPREP_IMAGE" \
        "$TEMP_BIDS_DIR" \
        "$OUTPUT_DIR" \
        participant \
        --participant-label "$SUBJECT_ID" \
        --fs-license-file "$FS_LICENSE" \
        --skip_bids_validation \
        --omp-nthreads 1 \
        --random-seed 13 \
        --skull-strip-fixed-seed

      echo "Deleting temporary directory: $TEMP_BIDS_DIR"
      rm -rf "$TEMP_BIDS_DIR"
    done
  fi
done
```

### Running Pydeface 
#### For Running 1 Participant 
```
#!/bin/bash

# Define variables for paths to make the script easier to manage
INPUT_DIR="/path/to/input/anat" # BIDS dataset
OUTPUT_DIR="/path/to/output"
SIF_FILE="$IRTG/sif/pydeface_2.0.0.sif"  
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
CONTAINER="$IRTG/sif/pydeface_2.0.0.sif"  

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
