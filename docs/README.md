# imagepreprocessing: Documentation

This README explains the preprocessing of neuroimaging data, including DICOM to BIDS conversion, BIDS validation, MRIQC, defacing. 
The following sections explain how to run the pipeline as a whole or individual processes.

## Option 1: Running the Entire Pipeline Using Nextflow

You can run all preprocessing steps (except fMRIPrep) together by executing the Nextflow pipeline. This automates the execution of the entire workflow. For more details, please refer to the [Running the Pipeline](https://github.com/mahnaz007/ImagePreprocessing/blob/main/docs/usage.md#running-the-pipeline) section.

## Option 2: Running Each Process Separately Using Bash Scripts

If you prefer to run each process individually, you can use Bash scripts with Apptainer or Singularity containers. This allows you to manage the execution of each pipeline step (e.g., dcm2Bids, Pydeface, MRIQC) separately. For more details, refer to the [Running the Pipeline](https://github.com/mahnaz007/ImagePreprocessing/blob/main/docs/usage.md#running-the-pipeline) section.

Please ensure that the correct configuration is used for each process. Refer to the specific usage guidelines in this document for process-specific details.

The imagepreprocessing documentation is split into the following pages:
- [Usage](usage.md)
  - An overview of how the pipeline works, how to run it and a description of all of the different command-line flags.
- [Output](output.md)
  - An overview of the different results produced by the pipeline and how to interpret them.
