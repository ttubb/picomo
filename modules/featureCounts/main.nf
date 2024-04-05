#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

process P_FEATURECOUNTS {
    /*
        Alignments for multi-mapping reads are not counted (=not using option -O)
        Arguments in use:
        -M               #Count all alignments for multi-mapping reads
        --fraction       #Reads overlapping multiple features result in fractional counts
        -p               #Input is paired-end
        --countReadPairs #Count read pairs (fragments) instead of reads
        -T               #threads
        -F               #annotation format
        -t               #feature type
        -g               #attribute type
    */

    debug params.debug
    tag "featureCounts"
    publishDir "${projectDir}/${params.outputDirectory}/readCounting/featureCounts", mode: "copy"

    input:
        tuple   val(type),
                val(condition),
                val(sample),
                path(bam),
                path(bai)
        path    gff

    output:
        tuple   val(type),
                val(condition),
                val(sample),
                path("${type}_${condition}_${sample}_featureCounts.tsv"),
                emit: tsv
        tuple   val(type),
                val(condition),
                val(sample),
                path("${type}_${condition}_${sample}_featureCounts.tsv.summary"),
                emit: summary

    script:
        """
        prefix=${type}_${condition}_${sample}
        featureCounts \
            --fraction \
            -M \
            -p \
            --countReadPairs \
            -T ${task.cpus} \
            -F GTF \
            -t CDS \
            -g ID \
            -a ${gff} \
            -o \${prefix}_featureCounts.tsv \
            ${bam}

        # Sed is used to make column names correspond to sample names
        # instead of whole filenames
        sed -i '2s/${bam.getFileName()}/${sample}/' \${prefix}_featureCounts.tsv
        """
}