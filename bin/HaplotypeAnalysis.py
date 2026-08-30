#!/usr/bin/env python3

### Read in libraries ###
import re
import numpy as np
import pandas as pd
from Bio import SeqIO
import itertools
import matplotlib.pyplot as plt


### Input parameters ###
haplotype_file = "results/smap/haplotype_frequencies_test.tsv"
genes = "genome_reference/originalref/reference_genes.fasta"
anchors = "genome_reference/originalref/borderFile.gff"
samplesinfo = "samplesinfo.csv"


### FUNCTIONS ###

def get_ref_dict(gene_fasta, anchor_gff):
    ref_dict = {}
    fasta_dict = SeqIO.to_dict(SeqIO.parse(gene_fasta, "fasta"))
    
    anchors = pd.read_csv(anchor_gff, sep="\t", header=None)
    anchors.columns = [
        "gene_id", "tool", "direction", "start", "stop",
        "dot1", "sense", "dot2", "description"
    ]
    
    anchors["gene_name"] = [i.split(' ')[0][5:] for i in anchors["description"]]
    gene_names = np.unique(anchors["gene_name"])

    for name in gene_names:
        spec_anchor = anchors[anchors["gene_name"] == name]
        gene_id = np.unique(spec_anchor["gene_id"])[0]
        
        start = int(spec_anchor.loc[spec_anchor["direction"] == "border_up", "stop"].iloc[0])
        stop = int(spec_anchor.loc[spec_anchor["direction"] == "border_down", "start"].iloc[0]) - 1
        
        ref_dict[name] = str(fasta_dict[gene_id].seq[start:stop])

    return ref_dict


def get_len_diff(gene_name, haplotype_seq, ref_dict):
    ref_haplotype = ref_dict[gene_name]
    if haplotype_seq == ref_haplotype:
        return "ref"
    else:
        return str(len(haplotype_seq) - len(ref_haplotype))


def edit_to_category(edit):
    if edit == "ref":
        return "REF"
    
    edit = int(edit)
    
    if edit == 0:
        return "SNP"
    else:
        return "INDEL"


### MAIN SCRIPT ###

# Read haplotypes file
haplotypes = pd.read_csv(haplotype_file, sep=" ")

# Wide -> long format
haplotypes_long = haplotypes.melt(
    id_vars=["Reference", "Locus", "Haplotypes"],
    var_name="sample",
    value_name="Freq"
)

# Add reference info
references = get_ref_dict(genes, anchors)

haplotypes_long["Edit"] = haplotypes_long.apply(
    lambda x: get_len_diff(x["Locus"], x["Haplotypes"], references),
    axis=1
)

haplotypes_long["Category"] = haplotypes_long["Edit"].apply(edit_to_category)

# Add sample metadata
info = pd.read_csv(
    samplesinfo,
    sep=",",
    names=["sample", "Species", "PlantID", "Tissue"]
)

haplotypes_long = haplotypes_long.merge(info, on="sample")

# Remove NaN rows
haplotypes_final = haplotypes_long.dropna(axis=0)

# Ensure numeric
haplotypes_final["Freq"] = pd.to_numeric(haplotypes_final["Freq"], errors="coerce")

# Remove REF category
haplotypes_edited = haplotypes_final[
    haplotypes_final["Category"] != "REF"
].copy()

# Create unique sample ID
haplotypes_edited["sample"] = (
    haplotypes_edited["PlantID"].astype(str) + "_" +
    haplotypes_edited["Tissue"].astype(str)
)

# Get all loci
all_loci = sorted(haplotypes_final["Locus"].dropna().unique())


### Plot per sample ###
for sample, subdf in haplotypes_edited.groupby("sample"):

    pivot = (
        subdf
        .groupby(["Locus", "Category"])["Freq"]
        .sum()
        .unstack(fill_value=0)
    )

    pivot = pivot.reindex(all_loci, fill_value=0)

    if pivot.sum().sum() == 0:
        continue

    ax = pivot.plot(
        kind="bar",
        stacked=True,
        figsize=(10, 6)
    )

    ax.set_title(sample)
    ax.set_xlabel("Locus")
    ax.set_ylabel("Freq")
    ax.set_xticklabels(ax.get_xticklabels(), rotation=90)
    ax.set_ylim(0, 100)

    plt.tight_layout()

    filename = f"{sample}.png"
    plt.savefig(filename, dpi=300)
    plt.show()
    plt.close()