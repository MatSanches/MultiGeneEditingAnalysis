#!/usr/bin/env nextflow

process flash2_process {
    // container "flash2.sif"
    // container 'jsaydo/flash2:v2.2.00'
    // container "${params.images_path}/flash2.sif"
    container 'quay.io/biocontainers/flash2:2.2.00--h577a1d6_9'
    // container "docker-archive:///scratch/gent/516/vsc51676/flash2.tar"
    // container 'https://quay.io/repository/biocontainers/flash2'
    
    // publishDir "${params.outdir}/flash2/", mode: 'copy', overwrite: true
    publishDir "results/flash2/test/", mode: 'copy', overwrite: true
    tag "$sample"

    input:
    tuple val(sample), path(read1), path(read2)

    output:
    tuple val(sample), path("${sample}.extendedFrags.fastq"), emit: merged
    // path("${sample}.extendedFrags.fastq"), emit: merged
    path("${sample}.histogram")
    path("${sample}.hist")

    script:
    """
    flash2 $read1 $read2 -o $sample -t $task.cpus
    """
}