#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

process P_BOWTIE_INDEX {
    debug params.debug
    tag "Bowtie2 indexing"
    publishDir "${projectDir}/${params.outputDirectory}/mapping/bowtie_index", mode: "copy"

    input:
        path    (assembly)

    output:
        tuple   val("${assembly}_index"),
                path("index/*"), emit: index
        path    ("./"), emit: everything
        path    "bowtie_index.log",
                emit: log

    script:
        """
        mkdir index
        bowtie2-build \
            --threads ${task.cpus} \
            ${assembly} \
            ./index/${assembly}_index \
            > bowtie_index.log
        """

}

process P_BOWTIE_MAP {
    debug params.debug
    tag "type: ${type} | condition: ${condition} | sample: ${sample}"
    publishDir "${projectDir}/${params.outputDirectory}/mapping/bowtie/${type}_${condition}_${sample}", mode: "copy"

    input:
        tuple   val(indexBase),
                path(indexFiles)
        tuple   val(type),
                val(condition),
                val(sample),
                path(reads1),
                path(reads2)

    output:
        tuple   val(type),
                val(condition),
                val(sample),
                path("${type}_${condition}_${sample}.SAM"),
                emit: sam
        path    ("./"), emit: everything

    script:
        """
        prefix=${type}_${condition}_${sample}
        bowtie2 \
            --threads ${task.cpus} \
            -x ${indexBase} \
            -1 ${reads1} \
            -2 ${reads2} \
            -S \${prefix}.SAM
        """
}