#!/usr/bin/env nextflow

process bwa_index{
    // container "bwa.sif"
    container 'quay.io/biocontainers/bwa:0.7.19--h577a1d6_1'
    // container 'community.wave.seqera.io/library/bwa_htslib_samtools:83b50ff84ead50d0'
    // container 'https://hub.docker.com/r/shinejh0528/bbmerge'
    
    // publishDir "${params.outdir}/bwa/", mode: 'copy', overwrite: true
    publishDir "results/index/test/", mode: 'copy', overwrite: true

    input:
    path(genes)

    output:
    tuple path(genes), path("*"), emit: index

    script:
    """
    bwa index $genes
    """

}


process bwa_mapping{
    // container "bwa.sif"
    container 'quay.io/biocontainers/bwa:0.7.19--h577a1d6_1'
    
    // publishDir "${params.outdir}/bwa/", mode: 'copy', overwrite: true
    publishDir "results/mapping/test/", mode: 'copy', overwrite: true

    input:
    tuple val(sample), path(merged_reads), path(genes), path(index_files)

    output:
    tuple val(sample), path("${sample}.sam"), emit: sam
    // tuple val(sample), path(merged_reads), emit: merged

    script:
    """
    bwa mem $genes $merged_reads > ${sample}.sam
    """

}