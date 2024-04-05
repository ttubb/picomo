#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

// processes
include { P_CHECKM_COVERAGE; P_CHECKM_PROFILE }     from '../../modules/checkm/main.nf'

workflow W_GENOMIC_ABUNDANCE {
    take:
        binsDirectory_ch
        bamWithIndices_ch

    main:
        allBam_ch =         bamWithIndices_ch.collect({ it[3] })
        allBamIndices_ch =  bamWithIndices_ch.collect({ it[4] })
        P_CHECKM_COVERAGE   ( binsDirectory_ch,
                              allBam_ch,
                              allBamIndices_ch )
        P_CHECKM_PROFILE    ( P_CHECKM_COVERAGE.out.coverage )

    emit:
        coverage =          P_CHECKM_COVERAGE.out.coverage
        abundance =         P_CHECKM_PROFILE.out.profile
}