#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

process P_MEGAHIT {
    debug params.debug
    tag "MEGAHIT co-assembly"
    publishDir "${projectDir}/${params.outputDirectory}/assembly/megahit", mode: "copy"

    input:
        path(reads1)
        path(reads2)

    output:
        path('megahit_out/final.contigs.fa'), emit: contigs
        path("megahit_out"), emit: everything
        path("megahit.log"), emit: log

    script:
        """
        megahit \
            -t ${task.cpus} \
            -1 ${reads1.join(',')} \
            -2 ${reads2.join(',')} \
            > megahit.log
        """
}