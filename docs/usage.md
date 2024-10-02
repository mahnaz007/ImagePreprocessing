# imagepreprocessing: Usage

> _Documentation of pipeline parameters is generated automatically from the pipeline schema and can no longer be found in markdown files._

## Introduction
# Preprocessing Pipeline for Neuroimaging Data (BIDSing, BIDS-Validation, and Defacing)
This pipeline automates the preprocessing of neuroimaging data, including conversion Dicom data to the BIDS format, validation of the dataset, and defacing for anonymization. It is designed for users working with neuroimaging data who need an efficient and standardized way to manage preprocessing steps before conducting further analysis.

The pipeline consists of three main steps:
- **BIDsing**: Converting raw neuroimaging data (e.g., DICOM) into BIDS format.
- **BIDS Validation**: Validating the converted BIDS dataset to ensure compliance with the BIDS standard.
- **Defacing**: Applying defacing to NIfTI files in the anatomical data to anonymize participants.

This guide will walk you through the setup, usage, and execution of the preprocessing pipeline.

## Prerequisites
Before running this pipeline, ensure you have the following installed:

## Prerequisites
Before running this pipeline, ensure you have the following installed:

- [Nextflow](https://www.nextflow.io/)
- [Apptainer/Singularity](https://apptainer.org/) or [Singularity](https://sylabs.io/)
- [bids-validator](https://github.com/bids-standard/bids-validator)
- [FSL](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FSL) (for NIfTI file handling)

Make sure these tools are accessible in your environment, and that the paths to necessary containers (e.g., dcm2bids and pydeface) are correctly set up.


##Full input directory structure
input/
IRTG01/
├── 01_AAHead_Scout_r1/
├── 02_AAHead_Scout_r1_MPR_sag/
├── 03_AAHead_Scout_r1_MPR_cor/
├── 05_gre_field_mapping_MIST/
└── ... (other DICOM folders)

## Pipeline Workflow

### Step 1: BIDSing (Convert DICOM to BIDS)
The first step of the pipeline is converting raw neuroimaging data, such as DICOM files, into the standardized BIDS format using the `dcm2bids` tool. This ensures that the dataset is structured in a way that is widely accepted and compatible with various neuroimaging analysis tools.

**Process**: `ConvertDicomToBIDS`

**Input**:
- DICOM files (e.g.,  01_AAHead_Scout_r1, 05_gre_field_mapping_MIST, etc.) appears to be organized DICOM data from an MRI scan.
- Configuration file (config.json) is used in the dcm2bids process to map DICOM metadata to the BIDS format.

**Output**:
- NIfTI files (.nii.gz): The actual neuroimaging data converted from DICOM.
- JSON metadata files (.json): Associated metadata for each NIfTI file, providing information about the scan and its parameters.
- Sidecar files: Such as .bvec and .bval files for diffusion-weighted imaging (DWI), if applicable.

##Multiple Session
If the same subject has two sessions (e.g., different MRI scans at different time points), the input data should reflect this, and the pipeline will automatically manage the sessions. Below is an example structure:

##Example of BIDS-compliant output structure:
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








<!-- TODO nf-core: Add documentation about anything specific to running your pipeline. For general topics, please point to (and add to) the main nf-core website. -->

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

The typical command for running the pipeline is as follows:

```bash
nextflow run main.nf --inputDir /path/to/your/data --outputDir /path/to/output --configFile /path/to/config.json --containerPath_dcm2bids /path/to/dcm2bids.sif --containerPath_pydeface /path/to/pydeface.sif```

This will launch the pipeline with the `singularity` and 'apptainer' configuration profile. See below for more information about profiles.

Note that the pipeline will create the following files in your working directory:

```bash
work                # Directory containing the nextflow working files
<OUTDIR>            # Finished results in specified location (defined with --outdir)
.nextflow_log       # Log file from Nextflow
# Other nextflow hidden files, eg. history of pipeline runs and old logs.
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
