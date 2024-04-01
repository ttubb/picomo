#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

pplacerThreads = 4
binFileExtension = 'fa'

process P_CHECKM_QUALITY {
    debug false //creates too much spam even in a "regular" debugging session
    tag "CheckM Quality"
    publishDir "${projectDir}/${params.outputDirectory}/checkm_quality", mode: "copy"

    input:
        path    "binFileDirectory"

    output:
        path    "checkm_quality.tsv",
                emit: table
        path    "checkm_lineage_out",
                emit: outputDirectory

    script:
        """
        OUTFILE=checkm_quality.tsv
        OUTDIR=checkm_lineage_out
        TMPDIR=checkm_tmp
        mkdir \${TMPDIR}
        checkm lineage_wf \
            --threads ${task.cpus} \
            --pplacer_threads ${pplacerThreads} \
            --tmpdir \${TMPDIR} \
            --file \${OUTFILE} \
            --tab_table \
            --extension ${binFileExtension} \
            ${binFileDirectory} \
            \${OUTDIR}
        """
}

process P_CHECKM_COVERAGE {
    debug params.debug
    tag "CheckM Coverage"
    publishDir "${projectDir}/${params.outputDirectory}/bin_abundance/checkm_coverage", mode: "copy"

    input:
        path    binsDirectory
        path    bamFiles
        path    bamIndices
    
    output:
        path    "checkm_coverage.tsv",
                emit: coverage

    script:
        """
        checkm coverage \
            --threads ${task.cpus} \
            --extension ${binFileExtension} \
            ${binsDirectory} \
            checkm_coverage.tsv \
            ${bamFiles.join(' ')}
        """
}

process P_CHECKM_PROFILE {
    debug params.debug
    tag "CheckM Profile"
    publishDir "${projectDir}/${params.outputDirectory}/bin_abundance/checkm_profile", mode: "copy"

    input:
        path    coverage

    output:
        path    "checkm_profile.tsv",
                emit: profile

    script:
        """
        checkm profile \
            --tab_table \
            --file checkm_profile.tsv \
            ${coverage}
        """

}