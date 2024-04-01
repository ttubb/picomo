#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

process P_MERGE_READS {
    /*Merge all forward reads and all reverse reads in the input tuple,
    emit a tuple of metadata, forward reads, and reverse reads.
    Assumes that all inputs share the same identifier, type, condition and
    sample*/

    debug true
    tag "type: ${type[0]} | condition: ${condition[0]} | sample: ${sample[0]}"
    publishDir "${projectDir}/${params.outputDirectory}/read_prep/merging", mode: "copy"

    input:
        tuple val(identifier),
              val(type),
              val(condition),
              val(sample),
              path(reads1, stageAs: "forward?.fq.gz"),
              path(reads2, stageAs: "reverse?.fq.gz")

    output:
        tuple val("${type[0]}"),
              val("${condition[0]}"),
              val("${sample[0]}"),
              path("${type[0]}_${condition[0]}_${sample[0]}_1.fq.gz"),
              path("${type[0]}_${condition[0]}_${sample[0]}_2.fq.gz")

    script:
        """
        for file in forward*.fq.gz;
        do
            zcat \${file} \
                >> ${type[0]}_${condition[0]}_${sample[0]}_1.fq
        done
        for file in reverse*.fq.gz;
        do
            zcat \${file} >> ${type[0]}_${condition[0]}_${sample[0]}_2.fq
        done
        pigz ${type[0]}_${condition[0]}_${sample[0]}_{1,2}.fq
        """
}