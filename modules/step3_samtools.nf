#!/usr/bin/env nextflow


process sam_to_bam{
    container 'quay.io/biocontainers/samtools:1.17--h00cdaf9_0'
    // container 'samtools.sif'

    publishDir "results/mapping/test/", mode: 'copy', overwrite: true

    input:
    tuple val(sample), path(bwamapping)

    output:
    tuple val(sample), path("${sample}.bam"), emit: bam

    script:
    """
    samtools sort -o ${sample}.bam ${bwamapping}
    """
}


