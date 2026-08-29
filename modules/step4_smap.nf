#!/usr/bin/env nextflow


process smap_haplotype_window {
    // container 'docker://ilvo/smap:4.6.3'
    container 'quay.io/biocontainers/ngs-smap:5.1.0--pyhdfd78af_0'
    // container 'smap_hapwindow.sif'

    publishDir "results/hapcount/test/", mode: 'copy', overwrite: true

    input:
    tuple path (reference_fasta), path (borders_gff), path (mapped_bams), path (merged_fqs)


    output:
    path "*counts*.tsv", emit: smap_counts
    path "*frequencies*.tsv", emit: smap_freqs

    script:
    """   
    smap haplotype-window \
        ${reference_fasta} 
        ${borders_gff} \
        ${mapped_bams} \
        ${merged_fqs} \
        -f 2 -m 1
    """
    //smap haplotype-window ${reference_fasta} ${borders_gff} ${mapped_bam} ${merged_fq} -f 2 -m 1
    // mkdir bam_dir
    // mkdir fastq_dir

    // cp ${mapped_bams} bam_dir/

    // sample_name=\$(basename ${mapped_bams} .bam)
    // cp ${merged_fqs} fastq_dir/\${sample_name}.fastq


}
