#!/usr/bin/env nextflow


process smap_haplotype_window {

    container 'quay.io/biocontainers/ngs-smap:5.1.0--pyhdfd78af_0'

    publishDir "${params.outdir}/3-hapcounts/", mode: 'copy', overwrite: true

    input:
    path (reference_fasta)
    path (borders_gff)
    val (mapped_bams)
    val (merged_fqs)
    

    output:
    path "*counts*.tsv", emit: smap_counts
    path "*frequencies*.tsv", emit: smap_freqs
    

    script:
    """
    mkdir bam_dir
    cp ${mapped_bams.join(' ')} bam_dir/

    mkdir fqs_dir
    for fq in ${merged_fqs.join(' ')}
    do
        sample=\$(basename "\$fq" .extendedFrags.fastq)
        cp "\$fq" "fqs_dir/\${sample}.fastq"
    done

    smap haplotype-window \
        ${reference_fasta} \
        ${borders_gff} \
        bam_dir \
        fqs_dir \
        -f 2 \
        -c 50 \
        -m 1
    """

}
