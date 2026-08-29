# RDA_microcredential_nextflow_project
repository to store code for the nextflow project in the context of the VIB reproducible data analysis microcredential, Q2 2026

*Authors*: Matilde Sanches (VIB), Lotte Pohl (UGent)


## Concept

Multiplex genome editing is a technique in which plants are transformed with CRISPR-Cas9 technology targeting multiple editing sites simultaneously.
Because Cas9 remains active during plant growth, it is important to keep track of the mutations that actually happened in the targeted loci.


## Description of the pipeline

The pipeline of this microcredential nextflow project uses DNA-reads of maize (fastq-files) as raw input data.
The goal is to identify the frequency of mutations at 10 loci (10 of the CRISPR targets), in multiple samples at the same tima
The main result after running the pipeline is a plot per sample that shows the edit rate and edit type (SNPs and INDELs) at each locus. 

The pipeline encompasses these main steps:
    
    1. The tool [flash](quay.io/biocontainers/flash2:2.2.00--0)  is implemented to match paired ends of DNA reads (1 pair per sample)

    3. After the matching is completed, the [Burrows-Wheeler Aligner (bwa)](https://hub.docker.com/layers/biocontainers/bwa/v0.7.17_cv1/images/sha256-9479b73e108ded3c12cb88bb4e918a5bf720d7861d6d8cdbb46d78a972b6ff1b) is used to create indices and to map to a reference genome.

    3. Then, samtools is used to convert the output of bwa (.sam) format in mapped files in .bam format - essential for use in the following step.

    4. After aligning, SMAP-haplotype-window is used to differentiate, using the mapping files, the original reads, as well as the reference (.fasta) and a custom file of coordinates (.gff), which reads correspond to the reference (not mutated) DNA sequence, or if it's different (mutated). It outputs a haplotype_frequency.tsv file in which it provides for each plant and locus the amount of Mutated reads (relative to the amount of Reference reads)
    
    5. Finally, a custom .py script is run to get some informative plots (one per sample) on the amount of mutations present at each locus.

   
## Note about SMAP-haplotype-window

This tool was created at ILVO and it is used by some labs in PSB-VIB. However, because the actual version of SMAP that supports the haplotype-window plugin is an older version that is no longer maintained by ILVO, in the local Cluster of PSB we run it inside virtual environments with a lot of older versions of dependencies installed. 
For this project Matilde spent quite some time creating an image of one of those environments (by writing a Dockerfile with all the installations), and uploaded it to docker hub (matsanches/smap_haplotype_window).
Unfortunately, while the pipeline worked locally using that container, on the HPC it constantly fails (and therefore impairs the progression of the pipeline) because of the Numpy version that is installed on the HPC (that doesn't seem to let an image built with an older version of Numpy run).

## Note on the reference genome file

The input fasta file in the `genome_reference` directory consists of a list of the reference sequences of the genes that were targeted for mutation. Because of data confidentiality, we opted to keep them in our git repo instead of putting them in the shared folder on the HPC.

    
### Test dataset

The testdata were put on the shared folder on the UGent hpc: /data/gent/courses/2025/vibrepdata_EXT003/shared/testdata_lotte_and_matilde
- maize .fastq files

Also, because of the crash of the pipeline on SMAP step, we have included a test file of the supposed output of this step inside results/smap, and the corresponding main_bypass.nf script.


### Setup for the HPC (before running the pipeline):
Copy the following lines of code in your terminal of the HPC
```
module load Nextflow/26.04.3

export APPTAINER_CACHEDIR=${VSC_SCRATCH}/.apptainer_cache

export APPTAINER_TMPDIR=${VSC_SCRATCH}/.apptainer_tmp

```


## Contribution

* M, with assistance of L drafted the project idea. M had some test data and a custom script from another project which served as the basis for the developed workflow.

* L drafted the first version of the `README.md`, which was then completed by M with additional, more bioinformatic-specific information.

* L setup the folder structure and created a github repository.

* L drafted a first version of the three original modules (`step1_flah2.nf`, `step2_bwa.nf`, `step5_customscript.nf`). 

* M provided and prepared the input data (in folder `./genome_reference/`)

* M finalised the three initial modules, and during this work realised the need for two additional modules (`step3_samtools.nf`, `step4_smap.nf`) which she drafted and completed.

* M created the image 'smap_hapwindow' from scratch, using docker and writing a recipe, which then she uploaded to Dockerhub (matsanches/smap_hapwindow). L pulled it with apptainer, thus creating the .sif image that was put in the shared folder.

* L drafted the `main.nf` workflow, which M completed during and after the completion of the modules.

* M and L worked in collaboration on providing the apptainer images on the VSC environment. Because of the security issues, the .sif files could not be pulled on the VSC itself but needed to be provided on an agreed shared location. M identified the images that needed to be pulled, L pulled them on her local laptop and copied the .sif files to the VSC.

* L was in E-Mail contact with the VIB trainers.

* M created the module to run the custom python script.

* L made a profile in `nextflow.config`.

* L drafted the contributions section, M completed it.
