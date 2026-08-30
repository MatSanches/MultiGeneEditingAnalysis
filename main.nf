#!/usr/bin/env nextflow

// define parameters
params {
    samples_path = "./data"
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
    // create channel for the samples infosheet   
    def samplesinfo_ch = channel.fromPath("${params.samples_path}/samplesinfo.csv")

    // make the paired end reads data into an input channel for the FLASH
    def rawreads_ch = samplesinfo_ch.splitCsv(header: false)
        .map { row ->
            def sample_id = row[0]
            tuple(sample_id,
                file("${params.samples_path}/${sample_id}_1.fq.gz"),
                file("${params.samples_path}/${sample_id}_2.fq.gz"))
        }    
    
    // execute flash2
    flash2_process(rawreads_ch)

    // make a channel for the fasta reference (either whole genome or just selected regions)
    def fastaref_ch = channel.of(file("${params.ref_path}/reference_genes.fasta"))

    // create index from fasta reference
    bwa_index(fastaref_ch)

    // map the merged reads of each sample (output of flash2) to the indexed reference
    bwa_mapping(flash2_process.out.merged
        .combine(bwa_index.out.index))
    
    // convert the mapped files from sam to bam format
    sam_to_bam(bwa_mapping.out.sam)

    // collect all the flash2 outputs (merged reads) and all the mapping outputs (bam files)
    def all_fastqs = flash2_process.out.merged
        .map { sample , fq -> fq }
        .collect()

    def all_bams   = sam_to_bam.out.bam
        .map { sample , bam -> bam }
        .collect()

    // create a channel for the borderFile (gff) matching the reference
    def borderfile_ch = channel.of(file("${params.ref_path}/borderFile.gff"))
  
    // distinguish haplotypes at each polymorphic locus with SMAP
    smap_haplotype_window(fastaref_ch,borderfile_ch,all_bams,all_fastqs)

    // define the python script as a channel
    def pyscript_ch = channel.of(file("${projectDir}/bin/HaplotypeAnalysis.py"))

    // run the custom script
    haplotype_analysis(smap_haplotype_window.out.smap_freqs,fastaref_ch,borderfile_ch,samplesinfo_ch,pyscript_ch)

 }