#!/usr/bin/env nextflow

process haplotype_analysis {
    container "python:3.10"

    input:
    tuple path(haplo_file),
          path(reference),
          path(borders),
          path(samplesinfo)

    output:
    path "plots/*"

    script:
    """
    mkdir -p plots
    python3 HaplotypeAnalysis.py \
        --haplotypes $haplo_file \
        --reference $reference \
        --borders $borders \
        --samples $samplesinfo \
        > haplotype_plots.png
    mv *.png plots/ || true
    """
}
