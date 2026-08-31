#!/usr/bin/env nextflow

process haplotype_analysis {

    container 'quay.io/jupyter/scipy-notebook:latest'

    publishDir "${params.outdir}/4-analysis/", mode: 'copy', overwrite: true

    input:
    path(haplo_file)
    path(reference)
    path(borders)
    path(samplesinfo)

    output:
    path "plots/*"
    path "AllSamples_haplotypes.tsv"

    script:
    """
    pip install biopython
    python3 ${launchDir}/bin/HaplotypeAnalysis.py \
        --haplotypes $haplo_file \
        --reference $reference \
        --borders $borders \
        --samples $samplesinfo

    mkdir -p plots
    mv *.png plots/ || true
    """

}
