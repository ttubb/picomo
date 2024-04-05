#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

// Including dexmex processes
include { P_DEXMEX_DIFFEXP; P_DEXMEX_CONVERTFC; P_DEXMEX_FEATURETOMAG_GFF; P_COLDATA_FROM_SAMPLESHEET } from '../../modules/dexmex/main.nf'

workflow W_LOCAL_DIFFEXP {
    take:
        samplesheet_ch
        binsDirectory_ch
        featureCountsFiles_ch
        gff_ch

    main:
        // Create a coldata file from the input samplesheet
        P_COLDATA_FROM_SAMPLESHEET(
            samplesheet_ch
        )

        // Convert featureCounts files to a compatible count file
        P_DEXMEX_CONVERTFC(
            featureCountsFiles_ch,
            P_COLDATA_FROM_SAMPLESHEET.out.rna_coldata
        )

        // Create a mapping of gff features to MAG bins
        skipBins_ch = Channel.of(['bin.unbinned.fa'])
        geneId_ch = Channel.value("ID")
        P_DEXMEX_FEATURETOMAG_GFF(
            gff_ch,
            binsDirectory_ch,
            skipBins_ch,
            geneId_ch
        )

        // Run local differential expression analysis
        P_DEXMEX_DIFFEXP(
            P_COLDATA_FROM_SAMPLESHEET.out.rna_coldata,
            P_DEXMEX_CONVERTFC.out,
            P_DEXMEX_FEATURETOMAG_GFF.out,
            params.referenceLevel
        )

    emit:
        diffexp = P_DEXMEX_DIFFEXP.out
        combinedCounts = P_DEXMEX_CONVERTFC.out
        featureToMag = P_DEXMEX_FEATURETOMAG_GFF.out
        rna_coldata = P_COLDATA_FROM_SAMPLESHEET.out.rna_coldata
        dna_coldata = P_COLDATA_FROM_SAMPLESHEET.out.dna_coldata
}
