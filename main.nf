#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// تعریف پارامترها
params.inputDir = "/home/mzaz021/BIDSProject/sourcecode/IRTG09"
params.outputDir = "/home/mzaz021/BIDSProject/combinedOutput"
params.configFile = "/home/mzaz021/BIDSProject/code/configPHASEDIFF_B0identifier.json"
params.containerPath_dcm2bids = "/home/mzaz021/dcm2bids_3.2.0.sif" // مسیر کانتینر Apptainer برای dcm2bids
params.containerPath_pydeface = "/home/mzaz021/pydeface_latest.sif" // مسیر کانتینر Apptainer برای pydeface
params.defacedOutputDir = "${params.outputDir}/defaced"

// اطمینان از وجود زیرشاخه‌ها
def subDirs = new File(params.inputDir).listFiles().findAll { it.isDirectory() }

if (subDirs.isEmpty()) {
    error "No subdirectories found in the input directory: ${params.inputDir}"
}

// تعریف Workflow
workflow {
    // ایجاد کانال از لیست زیرشاخه‌ها و استخراج participantID و session_id
    subDirChannel = Channel
        .from(subDirs)
        .map { dir ->
            def folderName = dir.name
            // استخراج participant ID از نام پوشه
            def participantIDMatch = folderName =~ /IRTG\d+_(\d+)_/
    
            if (!participantIDMatch) {
                error "Could not extract participant ID from the folder name: ${folderName}"
            }
    
            def participantID = participantIDMatch[0][1]
            // تعیین شماره جلسه
            def session_id = folderName.contains("S1") ? "ses-01" :
                            folderName.contains("S2") ? "ses-02" : "ses-01"
            return tuple(file(dir), participantID, session_id)
        }

    // اجرای فرآیند ConvertDicomToBIDS با کانال
    bidsFiles = subDirChannel | ConvertDicomToBIDS

    // اعتبارسنجی BIDS (اختیاری)
    validatedBids = bidsFiles | ValidateBIDS

    // فیلتر کردن فایل‌های NIfTI 3D
    niiFiles = bidsFiles
        .flatMap { it }
        .filter { it.name.endsWith(".nii.gz") }

    niiFiles3D = niiFiles.filter { file ->
        def is_3d = false
        try {
            def cmd = "fslval ${file} dim4".execute().text.trim()
            is_3d = cmd.toInteger() == 1
        } catch (Exception e) {
            is_3d = false
        }
        return is_3d
    }

    // فیلتر کردن فایل‌های مربوط به پوشه anat
    anatFiles = niiFiles3D.filter { file ->
        file.toString().contains("/anat/")
    }

    // اعمال Deface به فایل‌های anat با استفاده از PyDeface
    defacedFiles = anatFiles | PyDeface
}

// تعریف فرآیند ConvertDicomToBIDS
process ConvertDicomToBIDS {
    tag { participantID }

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
        ${params.containerPath_dcm2bids} \
        --auto_extract_entities \
        --bids_validate \
        -o /bids \
        -d /dicoms \
        -c /config.json \
        -p ${participantID} | tee bids_output/validation_log_${participantID}.txt
    """
}

// تعریف فرآیند ValidateBIDS (اختیاری)
process ValidateBIDS {
    tag "BIDS Validation"

    input:
        path bids_files

    output:
        path bids_files

    script:
    """
    echo "Validating BIDS dataset..."
    bids-validator ${bids_files} --json > validation_report.json || true

    if grep -q '"issues": {}' validation_report.json; then
        echo "BIDS validation successful."
    else
        echo "BIDS validation failed. Check the validation_report.json for details."
        cat validation_report.json
        # ادامه اجرای pipeline حتی در صورت شکست اعتبارسنجی
    fi
    """
}

// تعریف فرآیند PyDeface
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

    # تعریف متغیرها برای ورودی و خروجی
    input_file="!{niiFile.getName()}"
    output_file="defaced_!{niiFile.simpleName}.nii.gz"
    input_dir="$(dirname '!{niiFile}')"
    singularity_img="!{params.containerPath_pydeface}"

    # اجرای pydeface با استفاده از Apptainer
    apptainer run \
        --bind "${input_dir}:/input" \
        "${singularity_img}" \
        pydeface /input/"${input_file}" \
        --outfile "${output_file}"
    '''
}
