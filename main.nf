#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

// subworkflows
include { W_PREP_READS }            from './subworkflows/prep_reads/main.nf'
include { W_MAP_READS }             from './subworkflows/map_reads/main.nf'
include { W_BINNING }               from './subworkflows/binning/main.nf'
include { W_GENOMIC_ABUNDANCE }     from './subworkflows/abundance/main.nf'
include { W_LOCAL_DIFFEXP }         from './subworkflows/local_diffexp/main.nf'

// processes
include { P_FASTP }                 from './modules/fastp/main.nf'
include { P_SORTMERNA }             from './modules/sortmerna/main.nf'
include { P_MEGAHIT }               from './modules/megahit/main.nf'
include { P_CHECKM_QUALITY }        from './modules/checkm/main.nf'
include { P_PRODIGAL; P_MERGE_GFF } from './modules/prodigal/main.nf'
include { P_FEATURECOUNTS }         from './modules/featureCounts/main.nf'


workflow {

    // workflow input
    samplesheet_ch = Channel.fromPath(params.samplesheet)
    sortmernaDatabases_ch = Channel.value(      // a list of fastas
        params.db.sortmerna                 
            .findAll()
            .collect({it.value}))

    // read prep & merging
    W_PREP_READS(         samplesheet_ch )

    // read trimming & filtering
    P_FASTP                 ( W_PREP_READS.out )
    pairedReadsDna_ch =     P_FASTP.out.readsPaired
                              .filter( { it[0] == "dna" } )
    pairedReadsRna_ch =     P_FASTP.out.readsPaired
                              .filter( { it[0] == "rna" } )
    P_SORTMERNA             ( pairedReadsRna_ch,
                              sortmernaDatabases_ch )
    pairedReadsBoth_ch =    P_SORTMERNA.out.nonRrnaReads
                              .concat( pairedReadsDna_ch )

    // co-assembly
    P_MEGAHIT               ( pairedReadsDna_ch.collect({ it[3] }),   //forward reads
                              pairedReadsDna_ch.collect({ it[4] }))   //reverse reads

    // mapping
    W_MAP_READS             ( P_MEGAHIT.out.contigs , pairedReadsBoth_ch )

    // binning
    bamDna_ch =             W_MAP_READS.out.bamWithIndices
                              .filter( { it[0] == "dna" } )
                              .collect( { [ it[3], it[4] ] } )
    W_BINNING               ( P_MEGAHIT.out.contigs,
                              bamDna_ch)

    // bin quality
    P_CHECKM_QUALITY        ( W_BINNING.out.binsDirectory )

    // abundance of bins
    W_GENOMIC_ABUNDANCE     ( W_BINNING.out.binsDirectory,
                              W_MAP_READS.out.bamWithIndices )

    // taxonomic annotation
    /*      GTDB TK                     */

    // gene prediction
    /*      PRODIGAL on individual bins     */
    P_PRODIGAL              ( W_BINNING.out.bins )
    /*      merge bin predictions           */
    P_MERGE_GFF             ( P_PRODIGAL.out.gff
                              .collect() )


    // functional annotation
    /*      DIAMOND vsKegg on individual bins   */
    /*      merge bin annotations               */

    // counting
    rnaBamFiles_ch = W_MAP_READS.out.bamWithIndices
                        .filter { it[0] == "rna" }
    mergedGff_ch = P_MERGE_GFF.out.gff
    P_FEATURECOUNTS(rnaBamFiles_ch, mergedGff_ch)

    // modules
    /*      KEMET                       */

    // comparisons
    /*      DESEQ2 DNA MAG-LVL          */
    /*      DESEQ2 RNA MAG-LVL          */
    /*      DESEQ2 DNA GENE-LVL         */
    /*      DESEQ2 RNA GENE-LVL GLOBAL  */
    /*      DESEQ2 RNA GENE-LVL TAXA    */
    featureCountsTsv_ch = P_FEATURECOUNTS.out.tsv
        .map { type, condition, sample, file -> file } // Extract the file path from each tuple
        .collect() // Collect all file paths into a list
    W_LOCAL_DIFFEXP(
        samplesheet_ch,
        W_BINNING.out.binsDirectory,
        featureCountsTsv_ch.collect(),
        mergedGff_ch
    )
    /*      OFFSET FOLD CHANGES DNA     */
    /*      OFFSET FOLD CHANGES RNA     */


}