#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

process P_SAMTOOLS_SAM_TO_BAM {
    /*use samtools view to turn a .SAM file into a .BAM*/
    debug params.debug
    tag "type: ${type} | condition: ${condition} | sample: ${sample}"
    publishDir "${projectDir}/${params.outputDirectory}/samtools/samtools_view/${type}_${condition}_${sample}", mode: "copy"

    input:
        tuple   val(type),
                val(condition),
                val(sample),
                path(samfile)

    output:
        tuple   val(type),
                val(condition),
                val(sample),
                path("${type}_${condition}_${sample}.BAM"),
                emit: bam

    script:
    """
    prefix=${type}_${condition}_${sample}
    samtools view \
        --threads ${task.cpus} \
        -b \
        -h \
        ${samfile} \
        > \${prefix}.BAM
    """
}

process P_SAMTOOLS_SORT {
    debug params.debug
    tag "type: ${type} | condition: ${condition} | sample: ${sample}"
    publishDir "${projectDir}/${params.outputDirectory}/samtools/samtools_sort/${type}_${condition}_${sample}", mode: "copy"

    input:
        tuple   val(type),
                val(condition),
                val(sample),
                path(bamfile)

    output:
        tuple   val(type),
                val(condition),
                val(sample),
                path("${type}_${condition}_${sample}_sorted.BAM"),
                emit: bam

    script:
    """
    prefix=${type}_${condition}_${sample}
    samtools sort \
        --threads ${task.cpus} \
        --output-fmt BAM \
        ${bamfile} \
        > \${prefix}_sorted.BAM
    """
}

process P_SAMTOOLS_INDEX {
    debug params.debug
    tag "type: ${type} | condition: ${condition} | sample: ${sample}"
    publishDir "${projectDir}/${params.outputDirectory}/samtools/samtools_index/${type}_${condition}_${sample}", mode: "copy"

    input:
        tuple   val(type),
                val(condition),
                val(sample),
                path(sortedBamfile)

    output:
        tuple   val(type),
                val(condition),
                val(sample),
                path("${sortedBamfile}"),
                path("*.bai"),
                emit: bamWithIndices

    script:
    """
    prefix=${type}_${condition}_${sample}
    samtools index \
        -@ ${task.cpus} \
        -b \
        ${sortedBamfile}
    """
}