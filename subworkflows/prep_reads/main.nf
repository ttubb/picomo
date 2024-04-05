#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

// processes
include { P_MERGE_READS }           from '../../modules/read_merge/main.nf'  
    
workflow W_PREP_READS {
    /* Processes the samplesheet. Merges reads that come from identical samples
    and emits one tuple per sample with the following fields:
    condition, sample, read1, read2 */

    take:
        samplesheet_ch

    main:
        // Make a read channel based on the sample sheet
        reads_ch     =  samplesheet_ch.splitCsv  (sep: '\t', header:true,)
        reads_ch     =  reads_ch.map             ( {row ->  [
                            row.TYPE + '_' + row.CONDITION + "_" + row.SAMPLE,
                            row.TYPE,
                            row.CONDITION,
                            row.SAMPLE,
                            row.READS1,
                            row.READS2 ] } )
        reads_ch = reads_ch.groupTuple          ()

        // Merge reads that come from identical samples
        P_MERGE_READS       ( reads_ch )
        
    emit:
        P_MERGE_READS.out
}