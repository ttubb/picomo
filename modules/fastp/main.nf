#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

process P_FASTP {
    /*Filter and trim paired-end reads using fastp*/
    
    debug true
    tag "type: ${type} | condition: ${condition} | sample: ${sample}"
    publishDir "${projectDir}/${params.outputDirectory}/read_prep/fastp", mode: "copy"

    input:
        tuple   val(type),
                val(condition),
                val(sample),
                path(reads1),
                path(reads2)

    output:
        tuple   val(type),            //paired-end reads
                val(condition),
                val(sample),
                path("${type}_${condition}_${sample}_trimmed_1.fastq.gz"),
                path("${type}_${condition}_${sample}_trimmed_2.fastq.gz"),
                emit: readsPaired
        tuple   val(type),            //orphaned reads
                val(condition),
                val(sample),
                path("${type}_${condition}_${sample}_unpaired_trimmed_1.fastq.gz"),
                path("${type}_${condition}_${sample}_unpaired_trimmed_2.fastq.gz"),
                emit: readsOrphaned
        tuple   val(type),            //html report
                val(condition),
                val(sample),
                path("${type}_${condition}_${sample}.fastp.html"),
                emit: html
        tuple   val(type),            //json report
                val(condition),
                val(sample),
                path("${type}_${condition}_${sample}.fastp.json"),
                emit: json
    
    script:
        """
        prefix=${type}_${condition}_${sample}
        fastp \
            --in1 ${reads1} \
            --in2 ${reads2} \
            --out1 \${prefix}_trimmed_1.fastq.gz \
            --out2 \${prefix}_trimmed_2.fastq.gz \
            --unpaired1 \${prefix}_unpaired_trimmed_1.fastq.gz \
            --unpaired2 \${prefix}_unpaired_trimmed_2.fastq.gz \
            --json \${prefix}.fastp.json \
            --html \${prefix}.fastp.html \
            --thread ${task.cpus}
        """
}