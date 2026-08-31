#!/usr/bin/env nextflow


// include modules
include { flash2_merging } from "./modules/step1_merge"
include { bwa_index ; bwa_mapping ; sam_to_bam } from "./modules/step2_map"
include { smap_haplotype_window } from "./modules/step3_haplotype-count"
include { haplotype_analysis } from "./modules/step4_analyse"


// describe workflow
workflow {
    // create channel for the samples infosheet   
    def samplesinfo_ch = channel.fromPath("${params.samples_path}/samplesinfo.csv")

    // make the paired end reads data into an input channel for the FLASH
    def rawreads_ch = samplesinfo_ch.splitCsv(header: true)
        .map { row ->
            def sample_id = row.sample
            tuple(sample_id,
                file("${params.samples_path}/${sample_id}_1.fq.gz"),
                file("${params.samples_path}/${sample_id}_2.fq.gz"))
        }    
    
    // execute flash2
    flash2_merging(rawreads_ch)

    // make a channel for the fasta reference (either whole genome or just selected regions)
    def fastaref_ch = channel.of(file("${params.ref_path}/reference_genes.fasta"))

    // create index from fasta reference
    bwa_index(fastaref_ch)

    // map the merged reads of each sample (output of flash2) to the indexed reference
    bwa_mapping(flash2_merging.out.merged
        .combine(bwa_index.out.index))
    
    // convert the mapped files from sam to bam format
    sam_to_bam(bwa_mapping.out.sam)

    // collect all the flash2 outputs (merged reads) and all the mapping outputs (bam files)
    def all_fastqs = flash2_merging.out.merged
        .map { _sample , fq -> fq }
        .collect()

    def all_bams   = sam_to_bam.out.bam
        .map { _sample , bam -> bam }
        .collect()

    // create a channel for the borderFile (gff) matching the reference
    def borderfile_ch = channel.of(file("${params.ref_path}/borderFile.gff"))
  
    // distinguish haplotypes at each polymorphic locus with SMAP
    smap_haplotype_window(fastaref_ch,borderfile_ch,all_bams,all_fastqs)

    // define the python script as a channel
    def pyscript_ch = channel.of(file("${projectDir}/bin/HaplotypeAnalysis.py"))

    // run the custom script
    haplotype_analysis(smap_haplotype_window.out.smap_freqs,fastaref_ch,borderfile_ch,samplesinfo_ch,pyscript_ch)


    workflow.onComplete = {
        println "Pipeline completed at: ${workflow.complete}"
        println "Time to complete workflow execution: ${workflow.duration}"
        println "Execution status: ${workflow.success ? 'Succesful. All outputs can be found in folder results/ :)' : 'Failed' }"
    }

    workflow.onError = {
        println "Oops... Pipeline execution stopped with the following message: ${workflow.errorMessage}"
    }

 }