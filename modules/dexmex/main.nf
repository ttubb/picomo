#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

process P_DEXMEX_DIFFEXP {
    tag "local differential expression"
    publishDir "${projectDir}/${params.outputDirectory}/dexmex", mode: "copy"

    input:
        path    coldata
        path    counts
        path    feature_to_mag
        val     reference_level

    output:
        path    "dexmex_diffexp_out"

    script:
        """
        dexmex localdiffexp \
            --outdir dexmex_diffexp_out \
            --coldata_path ${coldata} \
            --counts_path ${counts} \
            --feature_to_mag_path ${feature_to_mag} \
            --reference_level ${reference_level}
        """
}

process P_DEXMEX_CONVERTFC {
    tag "convert featureCounts output tables to a compatible count file"
    publishDir "${projectDir}/${params.outputDirectory}/dexmex", mode: "copy"

    input:
        path    featureCountsFiles

    output:
        path    "combined_counts.tsv"

    script:
        def featureCountsFilesArg = featureCountsFiles.collect{ "${it}" }.join(' ')
        """
        outpath=combined_counts.tsv
        dexmex convertfc \
            -f ${featureCountsFilesArg} \
            -o \${outpath}
        """
}

process P_DEXMEX_FEATURETOMAG_GFF {
    tag "create a mapping of gff features to MAG bins"
    publishDir "${projectDir}/${params.outputDirectory}/dexmex", mode: "copy"

    input:
        path    gff
        path    binsDirectory
        val     skipBins
        val     geneId

    output:
        path    "feature_to_mag.tsv"

    script:
        def skipBinsArg = skipBins ? "--skip ${skipBins.join(' ')}" : ''
        def geneIdArg = geneId ? "--gene_id ${geneId}" : ''
        """
        outpath=feature_to_mag.tsv
        dexmex featuretomag \
            --output \${outpath} \
            --bins_directory ${binsDirectory} \
            --gff ${gff} \
            ${skipBinsArg} \
            ${geneIdArg}
        """
}

process P_COLDATA_FROM_SAMPLESHEET {
    tag "create a deseq2 coldata file from the input samplesheet"
    publishDir "${projectDir}/${params.outputDirectory}/dexmex", mode: "copy"

    input:
        path   samplesheet

    output:
        path    "coldata.tsv"

    script:
        """
        awk -F '\\t' 'BEGIN {print "sample\\tcondition"} \$1 == "rna" {print \$3"\\t"\$2}' ${samplesheet} > coldata.tsv
        """
}