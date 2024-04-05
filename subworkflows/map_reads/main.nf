#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

// processes
include { P_BOWTIE_INDEX; P_BOWTIE_MAP }                                from '../../modules/bowtie2/main.nf'
include { P_SAMTOOLS_SAM_TO_BAM; P_SAMTOOLS_SORT; P_SAMTOOLS_INDEX}     from '../../modules/samtools/main.nf'

workflow W_MAP_READS {
    take:
        assembly_ch
        reads_ch

    main:
        P_BOWTIE_INDEX          ( assembly_ch )
        P_BOWTIE_MAP            ( P_BOWTIE_INDEX.out.index, reads_ch )
        P_SAMTOOLS_SAM_TO_BAM   ( P_BOWTIE_MAP.out.sam )
        P_SAMTOOLS_SORT         ( P_SAMTOOLS_SAM_TO_BAM.out.bam )
        P_SAMTOOLS_INDEX        ( P_SAMTOOLS_SORT.out.bam )

    emit:
        bamWithIndices =        P_SAMTOOLS_INDEX.out.bamWithIndices
}
