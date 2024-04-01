#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

process P_SORTMERNA {
    debug params.debug
    tag "type: ${type} | condition: ${condition} | sample: ${sample}"
    publishDir "${projectDir}/${params.outputDirectory}/read_prep/sortMeRNA", mode: "copy"

    input:
        tuple   val(type),
                val(condition),
                val(sample),
                path(reads1),
                path(reads2)
        path    databaseFastas

    output:
        tuple   val(type),            // reads without rRNA
                val(condition),
                val(sample),
                path("${type}_${condition}_${sample}_trimmed_nonrRNA_1.fastq.gz"),
                path("${type}_${condition}_${sample}_trimmed_nonrRNA_2.fastq.gz"),
                emit: nonRrnaReads
        tuple   val(type),            // rRNA reads
                val(condition),
                val(sample),
                path("${type}_${condition}_${sample}_trimmed_rRNA_1.fastq.gz"),
                path("${type}_${condition}_${sample}_trimmed_rRNA_2.fastq.gz"),
                emit: rrnaReads
        tuple   val(type),            // rRNA reads
                val(condition),
                val(sample),
                path("${type}_${condition}_${sample}.sortmerna.log"),
                emit: log

    when:
        type == "rna"

    script:
        """
        prefix=${type}_${condition}_${sample}
        sortmerna \
            ${'--ref ' + databaseFastas.join(' --ref ')} \
            --reads ${reads1} \
            --reads ${reads2} \
            --threads ${task.cpus} \
            --workdir . \
            --aligned rRNA \
            --other non_rRNA \
            --paired_in \
            --out2 \
            --fastx \
            --no-best \
            --num_alignments 1 \
            > \${prefix}.sortmerna.log
        mv non_rRNA_fwd.fq.gz \${prefix}_trimmed_nonrRNA_1.fastq.gz
        mv non_rRNA_rev.fq.gz \${prefix}_trimmed_nonrRNA_2.fastq.gz
        mv rRNA_fwd.fq.gz \${prefix}_trimmed_rRNA_1.fastq.gz
        mv rRNA_rev.fq.gz \${prefix}_trimmed_rRNA_2.fastq.gz
        """
}
