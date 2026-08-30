#!/usr/bin/env nextflow

process haplotype_analysis {

    container 'jupyter/scipy-notebook:latest'

    publishDir "results/analysis/test/", mode: 'copy', overwrite: true

    input:
    path(haplo_file)
    path(reference)
    path(borders)
    path(samplesinfo)
    path(pyscript)

    output:
    path "plots/*"

    script:
    """
    pip install biopython

    mkdir -p plots
    python3 HaplotypeAnalysis.py \
        --haplotypes $haplo_file \
        --reference $reference \
        --borders $borders \
        --samples $samplesinfo
    mv *.png plots/ || true
    """
}
