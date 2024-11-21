## Introduction

This pipeline automates the preprocessing of neuroimaging data, including conversion Dicom data to the BIDS format, validation of the dataset, defacing, MRIQC for quality control, and fMRIPrep for functional MRI preprocessing. It is designed for users working with neuroimaging data who need an efficient and standardized way to manage preprocessing steps before applying further analysis.

![pipeline](docs/images/IRTG%20MRI%20Preprocessing.jpg)

The pipeline consists of five main steps:
- **BIDsing**: Converting raw neuroimaging data (e.g., DICOM) into BIDS format.
- **BIDS Validation**: Validating the converted BIDS dataset to ensure compliance with the BIDS standard.
- **Defacing**: Applying defacing to NIfTI files in the anatomical data by removing facisal features.
- **MRIQC**: Performing quality control checks on the anatomical and functional data.
- **fMRIPrep**: : Preprocessing functional MRI data for subsequent analysis.



## General setup 
> 💡This step is for setting up your compute environment to be able to use any of the preprocessing tools. Please follow the instructions below. This step is only perfomed once in the beginning. After everythin is installed see the [Usage](docs/usage.md) documentation for a detailed describtion on how to use the preprocessing tools. 

### 1. Installation of required programs
You need to have the following programs installed:

- [Nextflow](https://www.nextflow.io/)
- [Apptainer](https://apptainer.org/) and [Singularity](https://sylabs.io/)
- [bids-validator](https://github.com/bids-standard/bids-validator)
- [dcm2bids](https://github.com/UNFmontreal/Dcm2Bids)
- [FSL](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FSL) (for NIfTI file handling)
- [MRIQC](https://github.com/poldracklab/mriqc) (for quality control of MRI data)
- [fMRIPrep](https://fmriprep.org/en/stable/) (for preprocessing functional MRI data)
**Note**: fMRIPrep requires the FreeSurfer license. You can download the FreeSurfer license [here](https://surfer.nmr.mgh.harvard.edu/registration.html).

Make sure these tools are accessible in your environment, with the paths to the necessary containers (e.g., dcm2bids and pydeface) are correctly set up.

### 2. Installation of the required Singularity or Apptainer containers

Additionally, ensure the following Singularity .sif container files are correctly installed and accessible in your environment:

    dcm2bids_3.2.0.sif – Required for DICOM to BIDS conversion.
    mriqc-latest.sif – Required for running MRIQC for quality control.
    fmriprep_latest.sif – Required for fMRI preprocessing.
    pydeface_latest.sif – Used for defacing anatomical data.
    bids_validator_latest.sif – Used for validating BIDS datasets.

**Note**: In this project, all Singularity Image Format (SIF) files, required for running different processes are stored in a specific directory. This ensures everyone can easily access the necessary files.
Location of these files is in the following path:
  ```
/nic/sw/IRTG
  ```

#### Building container images for neuroimaging tool
> 💡If you need to build any of these container images (e.g., if there is an update), you can follow these steps to build them using Singularity or Apptainer.

**dcm2bids_3.2.0.sif**

    Source Code: Dcm2Bids GitHub Repository[https://github.com/UNFmontreal/Dcm2Bids]
    Version: 3.2.0
    Singularity Recipe: 
    Create a Singularity image using the Docker image available on Docker Hub.
    Steps to Build:  
    ```
    singularity build dcm2bids_3.2.0.sif docker://cbedetti/dcm2bids:3.2.0
    ```

**bids_validator_latest.sif**

    Source Code: BIDS Validator GitHub Repository[https://github.com/bids-standard/bids-validator]
    Singularity Recipe:
    The BIDS Validator has an official Docker image.
    Steps to Build:
    bash
    singularity build bids_validator_latest.sif docker://bids/validator:latest

**mriqc-latest.sif**

    Source Code: MRIQC GitHub Repository[https://github.com/nipreps/mriqc]
    Latest Version: Check the GitHub releases for the most recent version.
    Singularity Recipe:
    MRIQC provides Docker images that can be converted into Singularity images.
    Steps to Build:
    bash
    singularity build mriqc-latest.sif docker://nipreps/mriqc:latest

**pydeface_latest.sif**

    Source Code: PyDeface GitHub Repository[https://github.com/poldracklab/pydeface]
    Singularity Recipe:
    Using a community-maintained image
    Steps to Build (using a community Docker image):
    bash
    singularity build pydeface_latest.sif docker://neuroinformatics/pydeface:latest

**fmriprep_latest.sif**

    Source Code: fMRIPrep GitHub Repository[https://github.com/nipreps/fmriprep]
    Latest Version: Refer to the GitHub repository for updates.
    Singularity Recipe:
    fMRIPrep offers Docker images which is suitable for conversion.
    Steps to Build:
    bash
    singularity build fmriprep_latest.sif docker://nipreps/fmriprep:latest

Make sure these .sif container files are downloaded and placed in an accessible directory. If it is needed, you can create them using the appropriate Singularity or Apptainer commands.

After following the instructions your environemnt is set up.

## Usage

The [Usage](docs/usage.md) documentation provides an detaild description on how the tools and pipeline works and how to run it.
