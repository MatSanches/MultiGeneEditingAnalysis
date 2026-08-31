#!/usr/bin/env nextflow

process bwa_index{

    container 'quay.io/biocontainers/bwa:0.7.19--h577a1d6_1'
    
    publishDir "${params.outdir}/2-mapping/index/", mode: 'copy', overwrite: true

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

    container 'quay.io/biocontainers/bwa:0.7.19--h577a1d6_1'
    
    publishDir "${params.outdir}/2-mapping/", mode: 'copy', overwrite: true
    tag "$sample"

    input:
    tuple val(sample), path(merged_reads), path(genes), path(index_files)

    output:
    tuple val(sample), path("${sample}.sam"), emit: sam

    script:
    """
    bwa mem $genes $merged_reads > ${sample}.sam
    """

}


process sam_to_bam{
    
    container 'quay.io/biocontainers/samtools:1.17--h00cdaf9_0'

    publishDir "${params.outdir}/2-mapping/", mode: 'copy', overwrite: true
    tag "$sample"

    input:
    tuple val(sample), path(bwamapping)

    output:
    tuple val(sample), path("${sample}.bam"), emit: bam

    script:
    """
    samtools sort -o ${sample}.bam ${bwamapping}
    """
}