<picture>
  <source align="right" width="160" media="(prefers-color-scheme: dark)" srcset="img/logo_dark.png">
  <source align="right" width="160" media="(prefers-color-scheme: light)" srcset="img/logo_light.png">
  <img align="left" alt="Synum Logo" sr c="img/logo_light.png" width="160">
</picture>

**Picomo** is a nextflow pipeline for comparative Metagenomics and -transcriptomics analyses. It is aimed at experimental setups like time series or multi-condition experiments. The workflow can carry out read quality control (fastp), assembly (megahit) and mapping (bowtie2). The pipeline bins contigs (metabat2) and uses prodigal to predict genes on those contigs. Reads are counted using subread featureCounts and [dexmex](https://github.com/dexmex) is employed for taxon-level differential expression analysis. Using CheckM, relative abundances of MAG bins is calculated. Processes run in containers.
 As input, users need to provide `.fastq` files and samplesheet detailing which condition and replicate each file belongs to.

# Samplesheet
The pipeline processes paired-end reads provided as `.fastq` files. The input is a samplesheet which lists the paths of the files as well as metadata:
- the type of the read (`dna` or `rna`)
- the condition (this might be a timepoint or a treatment)
- the sample name (to differentiate between replicates of the same condition)
The column names are `TYPE`, `CONDITION`, `SAMPLE`, `READS1` (forward reads) and `READS2` (reverse reads). A filled out samplesheet might look like this:

| TYPE | CONDITION | SAMPLE     | READS1                 | READS2                 |
|------|-----------|------------|------------------------|------------------------|
| dna  | untreated | sample_u_1 | /path/to/file1_1.fastq | /path/to/file1_2.fastq |
| dna  | untreated | sample_u_2 | /path/to/file2_1.fastq | /path/to/file2_2.fastq |
| dna  | treated   | sample_t_1 | /path/to/file3_1.fastq | /path/to/file3_2.fastq |
| dna  | treated   | sample_t_2 | /path/to/file4_1.fastq | /path/to/file4_2.fastq |
| rna  | untreated | sample_u_1 | /path/to/file5_1.fastq | /path/to/file5_2.fastq |
| rna  | untreated | sample_u_2 | /path/to/file6_1.fastq | /path/to/file6_2.fastq |
| rna  | treated   | sample_t_1 | /path/to/file7_1.fastq | /path/to/file7_2.fastq |
| rna  | treated   | sample_t_2 | /path/to/file8_1.fastq | /path/to/file8_2.fastq |

# Containers
By default, the pipeline uses [Apptainer](https://apptainer.org/) to run processes in several different docker containers. If you want to use another container engine, you can remove the section 
```
apptainer {
    enabled = true
}
```
from the file `conf/main.config`. To run the pipeline using docker, use the `-with-docker` argument when invoking nextflow. Consult the [nextflow documentation](https://www.nextflow.io/docs/latest/container.html#) for instructions on how to use other container engines.
