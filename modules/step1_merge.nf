#!/usr/bin/env nextflow

process flash2_merging {

    container 'quay.io/biocontainers/flash2:2.2.00--h577a1d6_9'
    
    publishDir "${params.outdir}/1-merge/", mode: 'copy', overwrite: true
    tag "$sample"

    input:
    tuple val(sample), path(read1), path(read2)

    output:
    tuple val(sample), path("${sample}.extendedFrags.fastq"), emit: merged
    path("${sample}.histogram")
    path("${sample}.hist")

    script:
    """
    flash2 $read1 $read2 -o $sample -t $task.cpus
    """
}