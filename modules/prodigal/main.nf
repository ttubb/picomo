#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

outputFormat = "gff"
gffAttributeIndex = 8
gffIdIndex = 0
gffAttributeDelimiter = ';'
gffAttributeSeparator = '='
gffIdTag = 'ID='
gffSuffix = '.gff'

process P_PRODIGAL {
    debug params.debug
    tag "Predicting genes for ${genome}"
    publishDir "${projectDir}/${params.outputDirectory}/prodigal/per_bin", mode: "copy"

    input:
        path    genome
    output:
        path    "${genome}_aminoacids.fasta",
                emit: aminoAcids
        path    "${genome}_nucleotide.fasta",
                emit: nucleotides
        path    "${genome}.gff",
                emit: gff
    script:
        """
        PROTEINS=${genome}_aminoacids.fasta
        GENES=${genome}_nucleotide.fasta
        GFF=${genome}.gff
        prodigal \
            -a \${PROTEINS} \
            -d \${GENES} \
            -f ${outputFormat} \
            -i ${genome} \
            -o \${GFF}
        """
}

process P_MERGE_GFF {
    debug params.debug
    tag "Predicting genes for ${genome}"
    publishDir "${projectDir}/${params.outputDirectory}/prodigal", mode: "copy"

    input:
        path    (gffFile, stageAs: "features?.gff")
    output:
        path    "genePredictions.gff",
                emit: gff
    script:
        """
        #!/usr/bin/env python
        import os, csv

        OUTFILE = "./genePredictions.gff"

        allGffs = []
        gffFiles = [x for x in os.listdir('.') if x.endswith('${gffSuffix}')]
        offset = 10**6      # This breaks if any MAG has 10^7 genes
        counter = 0


        for file in gffFiles:
            counter += 1
            filepath = os.path.join('.', file)
            with open(filepath, 'r') as f:
                reader = csv.reader(f, delimiter='\\t')
                for row in reader:
                    row = [x.rstrip('\\r') for x in row]
                    if row[0].startswith('##'):
                        gffVersionHeader = row
                    elif row[0].startswith('#'):
                        allGffs.append(row)
                    else:
                        attributes = row[${gffAttributeIndex}].split('${gffAttributeDelimiter}')
                        geneId = attributes[0].split('${gffAttributeSeparator}')[1]
                        geneId = str(offset*counter) + geneId
                        attributes[${gffIdIndex}] = '${gffIdTag}' + geneId
                        attributes = '${gffAttributeDelimiter}'.join(attributes)
                        row[${gffAttributeIndex}] = attributes
                        allGffs.append(row)
        
        with open(OUTFILE, 'w') as f:
            f.write("\\t".join(gffVersionHeader) + '\\n')
            for line in allGffs:
                f.write("\\t".join(line) + '\\n')
        #with open(OUTFILE, 'w') as f:
        #    writer = csv.writer(f, delimiter='\\t')
        #    writer.writerow(gffVersionHeader)
        #    for row in allGffs:
        #        writer.writerow(row)                     
        """

}