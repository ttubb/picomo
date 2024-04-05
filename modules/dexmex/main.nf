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
        path    coldata

    output:
        path    "combined_counts.tsv"

    script:
        def featureCountsFilesArg = featureCountsFiles.collect{ "${it}" }.join(' ')
        """
        outpath=combined_counts.tsv
        dexmex convertfc \
            -f ${featureCountsFilesArg} \
            -o \${outpath} \
            -c ${coldata}
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
        def skipBinsArg = skipBins.join(' ')
        def geneIdArg = geneId ? "--gene_id ${geneId}" : ''
        """
        outpath=feature_to_mag.tsv
        dexmex featuretomag \
            --output \${outpath} \
            --bins_directory ${binsDirectory} \
            --gff ${gff} \
            --skip ${skipBinsArg} \
            ${geneIdArg}
        """
}

process P_COLDATA_FROM_SAMPLESHEET {
    tag "create a deseq2 coldata file from the input samplesheet"
    publishDir "${projectDir}/${params.outputDirectory}/dexmex", mode: "copy"

    input:
        path   samplesheet

    output:
        path    "rna_coldata.tsv",
                emit: rna_coldata
        path    "dna_coldata.tsv",
                emit: dna_coldata

    script:
        """
        #!/usr/bin/env python

        import csv

        header = ['sample', 'condition', 'replicate']
        dna_samples_seen = set()
        rna_samples_seen = set()
        with open('${samplesheet}', 'r') as infile:
            with open('rna_coldata.tsv', 'w', newline='') as rna_outfile:
                with open('dna_coldata.tsv', 'w', newline='') as dna_outfile:
                    reader = csv.DictReader(infile, delimiter='\\t')
                    rna_writer = csv.writer(rna_outfile, delimiter='\\t')
                    dna_writer = csv.writer(dna_outfile, delimiter='\\t')
                    rna_writer.writerow(header)
                    dna_writer.writerow(header)
                    for row in reader:
                        if row['TYPE'] == 'rna' and row['SAMPLE'] not in rna_samples_seen:
                            rna_writer.writerow([row['SAMPLE'], row['CONDITION']])
                            rna_samples_seen.add(row['SAMPLE'])
                        elif row['TYPE'] == 'dna' and row['SAMPLE'] not in dna_samples_seen:
                            dna_writer.writerow([row['SAMPLE'], row['CONDITION']])
                            dna_samples_seen.add(row['SAMPLE'])
                        elif row['TYPE'] not in ['rna', 'dna']:
                            raise ValueError("Invalid sample type:", row['TYPE'])
        """
}
