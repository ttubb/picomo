#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

// subworkflows

// processes

process P_DIAMOND_MAKEDB {
    debug params.debug
    tag "building diamond database for ${params.diamond_db}"

    input:
        path    target
        input   query

    output:

    script:


}

process P_DIAMOND_BLASTP {
    input:
    output:
    script:

}

process P_MERGE_ANNOTATIONS {
    input:
        path    annotationsDir

    output:
        file    "merged_annotations.tsv",
                emit: tab6

    script:
        """
        cat ${annotationsDir}/*.tsv > merged_annotations.tsv
        """

}