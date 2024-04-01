#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

minContigLength = 1500  // 1500 is the minimum length allowed by metabat2

process P_JGI_SUMMARIZE {
    debug params.debug
    tag "Metabat jgi_summarize_bam_contigs_depths"
    publishDir "${projectDir}/${params.outputDirectory}/binning/metabat", mode: "copy"

    input:
        path    bamWithIndices

    output:
        path    "metabatDepth.txt",
                emit: depth
        path    "jgi_summarize.log",
                emit: log

    script:
        """
        jgi_summarize_bam_contig_depths \
            --outputDepth metabatDepth.txt \
            *.BAM \
            > jgi_summarize.log
        """

}

process P_METABAT {
    debug params.debug
    tag "Metabat binning"
    publishDir "${projectDir}/${params.outputDirectory}/binning/metabat", mode: "copy"

    input:
        path    assembly
        path    depth

    output:
        path    "bins",
                emit: binsDirectory
        path    "bins/*.fa",
                emit: bins
        path    "lowDepth.fa",
                emit: lowDepth
        path    "tooShort.fa",
                emit: tooShort

    script:
        """
        BIN_DIR=bins
        mkdir \${BIN_DIR}
        metabat2 \
            --numThreads ${task.cpus} \
            --minContig ${minContigLength} \
            --inFile ${assembly} \
            --outFile "\${BIN_DIR}/bin" \
            --unbinned \
            --abdFile ${depth}
        mv \${BIN_DIR}/bin.lowDepth.fa lowDepth.fa
        mv \${BIN_DIR}/bin.tooShort.fa tooShort.fa
        """

}