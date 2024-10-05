include { ConvertDicomToBIDS } from './modules/local/dcm2bids_with_bids_validation.nf'
include { PyDeface } from './modules/local/pydeface.nf'

workflow {
    BIDSing()        
    PyDeface()       
}
