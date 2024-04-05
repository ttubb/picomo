#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

// processes
include { P_JGI_SUMMARIZE; P_METABAT }          from '../../modules/metabat2/main.nf'

workflow W_BINNING {
    take:
        assembly_ch
        bam_ch

    main:
        P_JGI_SUMMARIZE     ( bam_ch )
        P_METABAT           ( assembly_ch,
                              P_JGI_SUMMARIZE.out.depth )

    emit:
        binsDirectory =     P_METABAT.out.binsDirectory
        bins =              P_METABAT.out.bins.flatten()
        contigsLowDepths =  P_METABAT.out.lowDepth
        contigsTooShort =   P_METABAT.out.tooShort
}