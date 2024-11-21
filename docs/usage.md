# Usage

> This section describes the usage of the preprocessing tools.


### Set Up Proxy Identification

>❗**Everytime** before running Nextflow, cloning a GitHub repository, or executing any processes such as Pydeface, DCM2BIDS, or MRIQC, ensure that you have set the proxy variables that allow Singularity and Git to access the internet through your proxy. 

In your terminal, the required bash commands look like this:

```bash
nic
proxy
echo $https_proxy
```

## Data preprocessing 

> To perform preprocessing of your data with the five tools you can choos between two options on how to do it. The choice depends on your personal needs and preferences on how you want to perform the preprocessing.

**Option 1: Bash scripts** \
[Running the individual processing steps](#running/the/individual/processing/steps)

You can run each of the five processes (BIDSing, BIDS-Validation, Defacing, MRIQC, and fMRIPrep) separatly, by using the provided Singularity or Apptainer containers and execute them with the provided bash scripts 



**Option 2: Nextflow pipeline** \


By running the nextflow pipeline you can perfomre the first four preprocessing steps (BIDSing, BIDS-Validation, Defacing, MRIQC) automatically on your dataset. Since fMRIPrep is currently not included into the pipeline you would need to use the provided bash script to run it manually on your data.


## Running the individual processing steps via Bash scripts
> 💡This section describes how to run every processing step indicidually by executing the provided bash scripts. The recommended order for the preprocessing is the following:
1. BIDSing (Convert DICOM to BIDS)
2. BIDS Validation
3. Defacing
4. MRIQC
5. fMRIPrep

### 1. BIDSing (Convert DICOM to BIDS)

This tool converts raw neuroimaging data - DICOM files - into the standardized BIDS format using the `dcm2bids` tool.
This ensures that the dataset is structured in a way that is widely accepted and compatible with various neuroimaging analysis tools.

**Process**: `DCM2BIDS`

**Input**:
- DICOM files (e.g.,  01_AAHead_Scout_r1, 05_gre_field_mapping_MIST, etc.) - data from an MRI scan.
- Configuration file (config.json) - used in the dcm2bids process to map DICOM metadata to the BIDS format. You can find the full configuration file [here](https://github.com/mahnaz007/ImagePreprocessing/blob/main/assets/configPHASEDIFF_B0identifier.json).

Example of DICOM input structure:
```
input/
IRTG01/
├── 01_AAHead_Scout_r1/
├── 02_AAHead_Scout_r1_MPR_sag/
├── 03_AAHead_Scout_r1_MPR_cor/
├── 05_gre_field_mapping_MIST/
└── ... (other DICOM folders)
```

> 💡Multiple Session  
If the same subject has multiple sessions (e.g., different MRI scans at different time points), the input data should reflect this, and the tool will automatically manage the sessions. 
**Note**: Files that do not explicitly indicate session information (e.g., IRTG01_001002_b20080101) will be considered as belonging to session 01 (ses-01). 

<br/><br/>
**Output**:
- NIfTI files (.nii.gz): The actual neuroimaging data converted from DICOM.
- JSON metadata files (.json): Associated metadata for each NIfTI file, providing information about the scan and its parameters.
- Sidecar files: Such as .bvec and .bval files for diffusion-weighted imaging (DWI), if applicable.  

Example of BIDS-compliant output structure:
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
<br/><br/>
**Execution**

You can run the tool for one participant or an entiere project.
To run it for one participant you will run the container from the terminal with the following bash script:

`TODO: review`
```
appteiner run \
    -e --containall \
    -B <path/to/dicom/files> \
    -B <path/to/confi.json> \
    -B <path/to/BIDSProject> \
    <path/to/container/file> \
    --auto_extract_entities \
    -o <output/path> \
    -d <dicoms/path> \
    -c <confi.json> \
    -p <?> \
    -s <session_number>
```

Example command:
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
To run an entire project you need to use the following bash script. You need to adjust the `bidsdir` and `sourceDir` as well as the parameters in the `apptainer run`command.

`TODO: explain to store it in a .sh file and provide the command to execute the file in the terminal ! -> one general explanation maybe?`
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


### 2. BIDS Validation
This tool checks that the dataset complies with the BIDS standard, ensuring that the format and required metadata are correct.

> ❗Before running BIDS validation, the tmp_dcm2bids directory should be either ignored by adding it to a .bidsignore file or removed manually to prevent any errors. The tmp_dcm2bids folder is created during the BIDSing process and not further needed.

**Process**: `ValidateBIDS`

**Input**:
- BIDS dataset from BIDSing

**Output**:
- Log indicating success or any issues found during validation
<br/><br/>

**Execution**
You can run the tool for one participant or an entiere project.
Before the BIDS validation can be run, the tmp_dcm2bids directory should be removed to prevent any errors. The tmp_dcm2bids folder is created during the BIDSing process and not further needed.


To run it for one participant you will run the container from the terminal with the following bash script:
 
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


To run an entire project you need to use the following bash script. You need to adjust the `input_dir` and `output_dir` as well as the parameters in the `singularity run`command.

`TODO: explain to store it in a .sh file and proved the command to execute the file in the terminal ?`
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


**Common Errors and Warnings**
> 💡 In general all errors need to be resolved, while warnings do not, though they should be considered.

Common Errors:
- code: 54 - BOLD_NOT_4D
- code: 75 - NIFTI_PIXDIM4
-> This can happen due to incomplete sequences. This necessitates a check whether there were any sessions that were started, but not completed. The DICOM files within the sequence folder should be fewer than the comparable sequences. Incomplete DICOM sequences need to be removed before running the pipeline.

Common Warnings:
- code: 38 - INCONSISTENT_SUBJECTS
- code: 39 - INCONSISTENT_PARAMETERS
- code: 97 - MISSING_SESSION
-> Necessitates a check whether these warnings are congruent with the acquired data or if the subjects/sessions did not get converted correctly.

Moreover, a .bidsignore file has been created to prevent certain files from being flagged during the BIDS validation process. This file allows you to tell the BIDS validator to ignore specific files or patterns that don't adhere to BIDS standards but are still essential for your project.

**Temporary Folder and Log Files**

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


### 3. Defacing
This tool performs defacing on the anatomical NIfTI files to remove participants' facial features. This step utilizes Pydeface to process the files stored in the anat folder.

**Process**: `PyDeface`

**Input**:
- NIfTI files (from the `anat` folder)

**Output**:
- Defaced NIfTI files (`defaced_*.nii.gz`)

**Execution**

You can run the tool for one participant or an entiere project.

To run it for one participant use the following bash script:

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

To run an entire project you need to use the following bash script. You need to adjust the `INPUT_BASE`, `OUTPUT_BASE`, and `CONTAINER`.

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

### 4. MRIQC

**Input**:
    BIDS-structured dataset 
    
**Output**:
- HTML reports (mriqc_reports/ directory) containing quality metrics and visualizations for each subject and session.
- SVG figures that generate visualizations such as histograms, noise maps, and segmentation plots in SVG format.

**Execution**
You can run the tool for one participant or an entiere project.

To run it for one participant use the following bash script:

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
To run an entire project you need to use the following bash script. You need to adjust the `input_dir`, `output_dir`, `work_dir`, and `singularity_image`.


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

### 5. fMRIPrep
> 💡Before running fMRIPrep, make sure to update your dataset:
> - If any non-4D BOLD images exist, remove them to avoid errors during preprocessing.
> - After removing the non-4D BOLD images, you must update the corresponding fmap files. Ensure that the IntendedFor field in the fmap metadata points to the correct BOLD files.
> - If, after removing non-4D BOLD files, only one run remains, rename the file to remove the run-01 suffix to ensures the dataset complies with the BIDS standard.

**Input**:
    BIDS-structured dataset 
    
**Output**:
- fMRIPrep outputs (fmriprep_outputs/ directory) containing preprocessed functional and anatomical data.
- HTML reports for quality control metrics.
- SVG figures that display multiple visualizations, including brain masks and quality control.

**Execution**
You can run the tool for one participant or an entiere project.

To run it for one participant use the following bash script:

```
#!/bin/bash

# Define variables for paths to make the script easier to manage
SIF_FILE="$IRTG/sif/fmriprep_24.0.1.sif"  
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
To run an entire project, use the following bash script:
```
#!/bin/bash

# Define paths
INPUT_DIR="/path/to/BIDS/input_dir"  # BIDS dataset
OUTPUT_DIR="/path/to/output_dir" 
WORK_DIR="/path/to/host_workdir"  # Host work directory 
SINGULARITY_IMG="/path/to/fmriprep_24.0.1.sif"  
FS_LICENSE="/path/to/freesurfer/license.txt" 

# Get the list of subjects 
subjects=$(ls ${INPUT_DIR} | grep '^sub-')

# Run fmriprep in parallel for each subject
echo ${subjects} | tr ' ' '\n' | parallel -j 2 \ # Run with a maximum of 2 parallel for each subject  
  singularity run --cleanenv \
  --bind ${WORK_DIR}:/work \
  ${SINGULARITY_IMG} \
  ${INPUT_DIR} \
  ${OUTPUT_DIR} \
  participant \
  --participant-label {=s/^sub-//=} \
  --fs-license-file ${FS_LICENSE} \
  --skip_bids_validation \
  --omp-nthreads 1 \
  --random-seed 13 \
  --skull-strip-fixed-seed
```
<br/><br/>
<br/><br/>


## Nextflow pipeline

The Nextflow pipeline automates the preprocessing of neuroimaging data, streamlining the execution of multiple steps in a single workflow. This pipeline includes five specific processes: BIDSing, BIDS Validation, Defacing, MRIQC, and fMRIPrep. Each process is modularized under the modules/local directory, allowing for flexible and efficient data processing. By running the Nextflow pipeline, you can perform the first four preprocessing steps automatically on your dataset, ensuring consistency and reproducibility in your data analysis workflow. The full main.nf script and individual process scripts can be viewed in the repository.

### Pipeline execution

To run the nextflow pipeline, you need to clone this repository via the terminal:

```
git clone https://github.com/mahnaz007/ImagePreprocessing.git
```
Now change your current directory to the repositories directory via terminal: 

```
cd ImagePreprocessing
```
execute the nextflow pipeline with the following command from the terminal: 

```
nextflow run main.nf
```
