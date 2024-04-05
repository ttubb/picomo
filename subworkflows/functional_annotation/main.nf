#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

// processes
include { P_DIAMOND_MAKEDB; P_DIAMOND_BLASTP; P_MERGE_ANNOTATIONS }     from '../../modules/diamond/main.nf'

workflow W_FUNCTIONAL_ANNOTATION {
    take:
        queryAA             // query amino acid sequences
        targetAA            // target amino acid sequences

    main:
        // allBam_ch =         bamWithIndices_ch.collect({ it[3] })
        // allBamIndices_ch =  bamWithIndices_ch.collect({ it[4] })
        // P_CHECKM_COVERAGE   ( binsDirectory_ch,
        //                       allBam_ch,
        //                       allBamIndices_ch )
        // P_CHECKM_PROFILE    ( P_CHECKM_COVERAGE.out.coverage )

    emit:
        tab6 =              P_MERGE_ANNOTATIONS.out.tab6
        // coverage =          P_CHECKM_COVERAGE.out.coverage
        // abundance =         P_CHECKM_PROFILE.out.profile
}