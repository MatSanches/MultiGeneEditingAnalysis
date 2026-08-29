#!/usr/bin/env nextflow

process haplotype_analysis {
    container "python:3.10"

    publishDir "results/analysis/test/", mode: 'copy', overwrite: true

    input:
    tuple path(haplo_file),
          path(reference),
          path(borders),
          path(samplesinfo)
    // path(pyscript)

    output:
    path "plots/*"

    script:
    """
    mkdir -p plots
    python3 HaplotypeAnalysis.py \
        --haplotypes $haplo_file \
        --reference $reference \
        --borders $borders \
        --samples $samplesinfo
    mv *.png plots/ || true
    """
}
