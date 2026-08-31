# RDA_microcredential_nextflow_project

This repository onsists of a nextflow workflow (retake) project, developed in the context of the VIB reproducible data analysis microcredential, Q2 2026

*Author*: Matilde Sanches (VIB)


## Concept

Multiplex genome editing is a technique in which plants (or other organisms) are transformed with CRISPR-Cas technology targeting multiple editing sites simultaneously.
In most cases, Cas remains active throghout plant growth and is even transmitted to descendency. On the other hand, the actual editing efficiency is often not high (depending on factors such as chromatin accessibility on the target loci, specificity of the cloned gRNAs, editing power of the specific Cas protein used, etc.)
Therefore, the actual editing frequency at the targeted loci is rarely the same between individuals, and can even vary between different tissues of the same individual and throughout its lifespan.
If these edited plants are to be used for any purpose (research, breeding, etc.), it is essential to know their editing state at a given tissue and timepoint. Samples are collected, their DNA extracted, the regions to observe (i.e. the editing targets) are amplified (PCR using specific primers) and sequenced, the final product (and raw input for this pipeline) being fastq files, one pair (paired-end reads) per sample.


## Description of the pipeline

The main goal of this pipeline is to calculate the frequency of mutation at multiple loci (for instance the targets of a multiplex genome editing experiment) simultaneously, and for several samples at the same time. 
The main task of the pipeline (see below) is accomplished by the SMAP_haplotype_window tool.

The pipeline encompasses the following main steps:
    
1. The tool [FLASH2](https://github.com/dstreett/flash2) is implemented to match paired ends of DNA reads (1 pair per sample)

2. The [Burrows-Wheeler Aligner (BWA)](https://bio-bwa.sourceforge.net/) is used to create indices and to map the reads to the reference.

3. Then, [samtools](https://www.htslib.org/doc/samtools-view.html) is used to convert the output of BWA (.sam) format in mapped files in .bam format (bacause .sam cannot be used by the following tool).

4. With the alignment files obtained for all the reads and all the samples, [SMAP-haplotype-window](https://ngs-smap.readthedocs.io/en/latest/window/index.html) compares each haplotype found with the provided reference sequences, and determines if it is unchanged or mutated. It outputs a haplotype_frequency.tsv file in which it provides for each sample and locus the amount of Mutated reads (relative to the amount of Reference reads). The parameters used in this pipeline are -f (minimal haplotype frequency retained)= 2 (2%), and -c (minimal read count per locus and sample)= 50.
    
5. Finally, a custom python script (./bin/HaplotypeAnalysis.py) is run to obtain a more informative version of the haplotype_frequency.tsv ('AllSamples_haplotypes.tsv') including for instance the type of mutation that each mutated haplotype corresponds to (INDEL, SNP), as well as some informative plots (one per sample) on the amount and type of mutations present at each locus.

A diagram showing the complete workflow can be found in this folder as 'DAG-preview.svg'.



## How to run this pipeline

First of all, clone this repository to the desired location on your machine using for example the command:
```bash
git clone https://github.com/MatSanches/MultiGeneEditingAnalysis.git
```

### Necessary inputs
**To be placed under data/ :**
* Zipped fastq DNA-reads files (paired ends, named as sampleX_1.fq.gz and sampleX_2.fq.gz)
* samplesinfo.csv file (see example in test_data), first column must be called sample and indicate all the samples to analyse, nomenclature corresponding to the raw read files (sampleX, sampleY, etc)

**To be placed under genome_reference/ :**
* Reference genome or partial genome (chromosomes, genes...) in FASTA format (extension .fasta)
* Anchor/border file matching the genome reference (see example in test_data) in GFF format (extension .gff)

### Test data
Under test_data some example files for all the inputs are provided. Please make sure that your data follows the same structure (specially the border file).


### Running the pipeline

The pipeline can be run on either a local computer or a HPC environment.
Two container runtimes can be used:

* **Docker** is recommended for local computers (Windows, macOS, Linux). Docker provides the software environment needed by the pipeline without requiring users to manually install any of the pipeline tools or dependencies. 
* **Apptainer** (formerly Singularity) is recommended on HPC systems, where Docker is usually not available because it requires elevated privileges.

**Make sure to have at least one of the above installed and running (DockerDesktop must be opened, for instance).**


On a local machine with Nextflow installed (https://docs.seqera.io/nextflow/install) and all the required inputs correctly placed in the /data and /genome_reference directories, the command to run the pipeline is:
```bash
nextflow run main.nf -profile <docker/apptainer>  ##(chose your preferred container runtime)
```

Otherwise, you can try this pipeline with the provided test data with the following command:
 ```bash
nextflow run main.nf -profile test,<docker/apptainer>  ##(chose your preferred container runtime)
```


On an HPC system, before running the pipeline it is necessary to first load Nextflow:
```bash
module load Nextflow/<your_version>  ##for example Nextflow/26.04.3
```
Then run:
```bash
nextflow run main.nf -profile hpc   ##or -profile test,hpc to run with the provided test data
```

After completion, the pipeline should create output files in the `results/` directory.
To verify if the test run was successful, compare the files in your `results/` with the files inside the `test_results/` directory.




## Acknowledgements

I would like to thank all the trainers from this VIB micro-credential in Reproducible Data Analysis. I consider that I learned a lot, all the expectations were fully met and several doors were opened. 
I am particularly grateful for the opportunity to repeat this final project - my stubbornness to maintain the initial ambitious plan might have not been the easiest option, but I am utterly glad and proud to have made it work in the end! I plan to actually use this pipeline in my current work.
