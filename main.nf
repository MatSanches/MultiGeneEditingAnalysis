#!/usr/bin/env nextflow

// define parameters
params {
    samples_path = "./data"

    // ref_path = "${launchDir}/genome_reference"
    ref_path = "./genome_reference"

    outdir = "./results"

}

// include modules
include { flash2_process } from "./modules/step1_flash2"
include { bwa_index ; bwa_mapping } from "./modules/step2_bwa"
include { sam_to_bam } from "./modules/step3_samtools"
include { smap_haplotype_window } from "./modules/step4_smap"
include { haplotype_analysis } from "./modules/step5_customscript"


workflow {   
    // make the paired end reads data into an input channel for the FLASH
    def samples_ch = channel
        .fromPath("${params.samples_path}/samplesinfo.csv")
        .splitCsv(header: false)
        .map { row ->
            def sample_id = row[0]
            tuple(sample_id,
                file("${params.samples_path}/${sample_id}_1.fq.gz"),
                file("${params.samples_path}/${sample_id}_2.fq.gz"))
        }
    
    // execute flash2
    flash2_process(samples_ch)

    // make a channel for the files necessary for BWA to make an index
    def reference_ch = channel
        .of(file("${params.ref_path}/reference_genes.fasta"))
    // def reference_ch = channel
    // .of(file("${params.ref_path}/newref/GCA_902167145-chromosomes.fasta"))

    // make a channel for the border file of polymorphic regions necessary for SMAP
    def borders_ch = channel
        .of(file("${params.ref_path}/borderFile.gff"))
    // def reference_ch = channel
    // .of(file("${params.ref_path}/newref/border10Targets.gff"))


    // create index from reference genes
    bwa_index(reference_ch)
    // execute bwa on the output of flash2
    bwa_mapping(flash2_process.out.merged
        .combine(bwa_index.out.index))
    // convert the sam files to bam files
    sam_to_bam(bwa_mapping.out.sam)


    // prepare pairs of flash2 and samtobam outputs per sample, to input in SMAP
    def smap_joined = flash2_process.out.merged
        .join(sam_to_bam.out.bam)    
    def smap_input = smap_joined
        .map { sample, merged_fq, bam ->
            tuple(
                file("${params.ref_path}/reference_genes.fasta"),
                file("${params.ref_path}/borderFile.gff"),
                bam,
                merged_fq
            )
        }


    // distinguish haplotypes at each polymorphic locus with SMAP
    smap_haplotype_window(smap_input)


    // define channel with all inputs necessary for the custom python script
    def samplesinfo_ch = channel.of(file("${params.samples_path}/samplesinfo.csv"))
    def python_input = smap_haplotype_window.out.smap_freqs
        .combine(samplesinfo_ch)
        .map { hapfile, samplesinfo ->
            tuple(
                hapfile,
                file("${params.ref_path}/reference_genes.fasta"),
                file("${params.ref_path}/borderFile.gff"),
                samplesinfo
            )
        }


    // run the custom script
    haplotype_analysis(python_input)

 }