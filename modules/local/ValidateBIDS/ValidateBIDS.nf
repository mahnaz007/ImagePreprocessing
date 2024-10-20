process ValidateBIDS {
    input:
        path bids_files  // BIDS dataset path as input

    output:
        path bids_files  

    script:
    """
    echo "Validating BIDS dataset at ${bids_files}..."
    
    # Run BIDS validator and output validation report in JSON format
    bids-validator ${bids_files} --json > validation_report.json || true

    # Check if the validation passed or failed by inspecting the issues in the JSON
    if grep -q '"issues": {}' validation_report.json; then
        echo "BIDS validation successful."
    else
        echo "BIDS validation failed. Check the validation_report.json for details."
        cat validation_report.json
    fi
    """
}
