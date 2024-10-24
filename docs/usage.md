# Usage
> This section describes the usage of the preprocessing tools.

### Description 
To perform preprocessing of your data with the five tools you can choos between two options on how to do it. The choice depends on your personal needs and preferences on how you want to perform the preprocess.

**Option 1:** \
[Running the individual processing steps](#running/the/individual/processing/steps)

    You can run each of the five processes (BIDSing, BIDS-Validation, Defacing, MRIQC, and fMRIPrep) separatly, by using the provided Singularity or Apptainer containers and execute them with the provided bash scripts 
    


**Option 2:** \
[]()

    By running the nextflow pipeline you can perfomre the first four preprocessing steps (BIDSing, BIDS-Validation, Defacing, MRIQC) automatically on your dataset. Since fMRIPrep is currently not included into the pipeline you would need to use the provided bash script to run it manually on your data.

### Set Up Proxy Identification

>❗**Everytime** before running Nextflow, cloning a GitHub repository, or executing any processes such as Pydeface, DCM2BIDS, or MRIQC, ensure that you have set the proxy variables that allow Singularity and Git to access the internet through your proxy. 

In your terminal, the required bash commands look like this:

```bash
nic
proxy
echo $https_proxy
```


## 1. Running the individual processing steps
> 💡This section describes how to run every processing step indicidually by executing the provided bash scripts. The recommended order for the preprocessing is the following:
1. BIDSing (Convert DICOM to BIDS)
2. BIDS Validation
3. Defacing
4. MRIQC
5. fMRIPrep


### 1. BIDSing (Convert DICOM to BIDS)

This tool converts raw neuroimaging data - DICOM files - into the standardized BIDS format using the `dcm2bids` tool.
This ensures that the dataset is structured in a way that is widely accepted and compatible with various neuroimaging analysis tools.

**Process**: DCM2BIDS

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

To run it for one participant you will run the container from the terminal with the following command:

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
apptainer run \
-e --containall \
-B /home/mzaz021/BIDSProject/sourcecode/IRTG01/IRTG01_001001_S1_b20060101/:/dicoms:ro \
-B /home/mzaz021/BIDSProject/code/configPHASEDIFF_B0identifier.json:/config.json:ro \
-B /home/mzaz021/BIDSProject/dcm2bidsSin:/bids \
/home/mzaz021/dcm2bids_3.2.0.sif \
--auto_extract_entities \
-o /bids \
-d /dicoms \
-c /config.json \
-p 001001 \
-s 01

```
To run an entire project you need to use the following bash script. You need to adjust the `bidsdir` and `sourceDir` as well as the parameters in the `apptainer run`command.

`TODO: explain to store it in a .sh file and provide the command to execute the file in the terminal ! -> one general explanation maybe?`
```
#!/bin/bash
# Define the base directory
bidsdir="</path/to/BIDSProject>"
sourceDir="<path/to/sourcecode/IRTG01>"

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


### 2. BIDS Validation
This tool checks that the dataset complies with the BIDS standard, ensuring that the format and required metadata are correct.

**Process**: `ValidateBIDS`

**Input**:
- BIDS dataset from BIDSing

**Output**:
- Log indicating success or any issues found during validation
<br/><br/>

**Execution**
You can run the tool for one participant or an entiere project.
Before the BIDS validation can be run, the tmp_dcm2bids directory should be removed to prevent any errors. The tmp_dcm2bids folder is created during the BIDSing process and not further needed.


To run it for one participant you will run the container from the terminal with the following command:
 
 ```
singularity run --cleanenv \
  <path/to/container/file.sif> \
  <path/to/output/dir> \
  --verbose > <path/to/output/dir/validation_log.txt> 2>&1
#Creates a log in the output directory
```
Example command:
```
singularity run --cleanenv \
  /home/mzaz021/validator_latest.sif \
  /home/mzaz021/BIDSProject/preprocessingOutputDir/09B0identifier/sub-009002/ \
  --verbose > /home/mzaz021/BIDSProject/bidsValidatorLogs/validation_log.txt 2>&1
#Creates a log in the output directory
```


To run an entire project you need to use the following bash script. You need to adjust the `input_dir` and `output_dir` as well as the parameters in the `singularity run`command.

`TODO: explain to store it in a .sh file and proved the command to execute the file in the terminal ?`
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

`TODO: add common errors and warnings`
**Common Errors and Warnings**
Note that all errors need to be resolved, while warnings do not, though they should be considered.

Common Errors:
- code: 54 - BOLD_NOT_4D
- code: 75 - NIFTI_PIXDIM4
-> This can happen due to incomplete sequences. This necessitates a check whether there were any sessions that were started, but not completed. The DICOM files within the sequence folder should be fewer than the comparable sequences. Incomplete DICOM sequences need to be removed before running the pipeline.

Common Warnings:
- code: 38 - INCONSISTENT_SUBJECTS
- code: 39 - INCONSISTENT_PARAMETERS
- code: 97 - MISSING_SESSION
-> Necessitates a check whether these warnings are congruent with the acquired data or if the subjects/sessions did not get converted correctly.

### 3. Defacing
This tool performs defacing on the anatomical NIfTI files to remove participants' facial features. This step utilizes Pydeface to process the files stored in the anat folder.

**Process**: `PyDeface`

**Input**:
- NIfTI files (from the `anat` folder)

**Output**:
- Defaced NIfTI files (`defaced_*.nii.gz`)

**Execution**
You can run the tool for one participant or an entiere project.

To run it for one participant you will run the container from the terminal with the following command:
```
singularity run \
--bind <path/to/input/dir>:/input \
--bind <path/to/output/dir>:/output \
</path/to/container/file.sif> \
pydeface /input/path/to/.nii.gz \
--outfile /output/file_defaced.nii.gz
```
Example command:
```
singularity run \
--bind /home/mzaz021/BIDSProject/preprocessingOutputDir/09/sub-009002/ses-01/anat:/input \
--bind /home/mzaz021/BIDSProject/newPydeface:/output \
/home/mzaz021/pydeface_latest.sif \
pydeface /input/sub-009002_ses-01_T1w.nii.gz \
--outfile /output/sub-009002_ses-01_T1w_defaced.nii.gz
```

To run an entire project you need to use the following bash script. You need to adjust the `INPUT_BASE`, `OUTPUT_BASE`, and `CONTAINER`.

`TODO: explain to store it in a .sh file and proved the command to execute the file in the terminal ?`
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

### 4. MRIQC

**Input**:
    BIDS-structured dataset 
    
**Output**:
- HTML reports (mriqc_reports/ directory) containing quality metrics and visualizations for each subject and session.
- SVG figures that generate visualizations such as histograms, noise maps, and segmentation plots in SVG format.

**Execution**
You can run the tool for one participant or an entiere project.

To run it for one participant you will run the container from the terminal with the following command:
```
singularity run <path/to/the/container/file.sif> /home/mzaz021/BIDSProject/preprocessingOutputDir/01 /home/mzaz021/BIDSProject/new_mriqcOutput participant \
	--participant-label <lable> \
	--nprocs <number> \
	--omp-nthreads <number> \
	--mem_gb <number> \
	--no-sub \
	-vvv \
	--verbose-reports
```
Example command:
```
singularity run /home/mzaz021/mriqc_24.0.2.sif /home/mzaz021/BIDSProject/preprocessingOutputDir/01 /home/mzaz021/BIDSProject/new_mriqcOutput participant \
	--participant-label 001004 \
	--nprocs 4 \
	--omp-nthreads 4 \
	--mem_gb 8 \
	--no-sub \
	-vvv \
	--verbose-reports
```
To run an entire project you need to use the following bash script. You need to adjust the `input_dir`, `output_dir`, `work_dir`, and `singularity_image`.

`TODO: explain to store it in a .sh file and proved the command to execute the file in the terminal ?`
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

To run it for one participant you will run the container from the terminal with the following command:

`TODO: adjsute the code to a general command`:
```
singularity run --cleanenv \
/home/mzaz021/fmriprep_latest.sif \
/home/mzaz021/BIDSProject/preprocessingOutputDir/09B0identifier \
/home/mzaz021/BIDSProject/fmriPreprocessing/09 \  
participant \
--participant-label <label> \
--fs-license-file <path/to/license.txt> \
--skip_bids_validation \
--omp-nthreads <number> \
--random-seed <number> \ 
--skull-strip-fixed-seed
```
Example command:
```
singularity run --cleanenv /home/mzaz021/fmriprep_latest.sif     /home/mzaz021/BIDSProject/preprocessingOutputDir/09B0identifier     /home/mzaz021/BIDSProject/fmriPreprocessing/09     participant     --participant-label 009004     --fs-license-file /home/mzaz021/freesurfer/license.txt     --skip_bids_validation     --omp-nthreads 1     --random-seed 13     --skull-strip-fixed-seed
```





## Running the pipeline

### General Instructions




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
nextflow run main.nf -profile local
```
-resume: Continue the pipeline from where it left off using cached results.
```
nextflow run main.nf -resume
```
-c: Specify a custom configuration file for resource allocation or tool-specific options
## Running the Pipeline Processes
For each step of the pipeline, different processes (e.g., DCM2BIDS, Pydeface, MRIQC) need to be run using specific command lines. These commands assume you are using Apptainer or Singularity to containerize the execution environment.




```

