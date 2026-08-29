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
    def rawreads_ch = channel.fromPath("${params.samples_path}/samplesinfo.csv")
        .splitCsv(header: false)
        .map { row ->
            def sample_id = row[0]
            tuple(sample_id,
                file("${params.samples_path}/${sample_id}_1.fq.gz"),
                file("${params.samples_path}/${sample_id}_2.fq.gz"))
        }    
    
    // execute flash2
    flash2_process(rawreads_ch)

    // make a channel for the files necessary for BWA to make an index
    def fastaref_ch = channel.of(file("${params.ref_path}/reference_genes.fasta"))

    // make a channel for the border file of polymorphic regions necessary for SMAP
    // def borders_ch = channel
    //     .of(file("${params.ref_path}/borderFile.gff"))
    // def reference_ch = channel
    // .of(file("${params.ref_path}/newref/border10Targets.gff"))


    // create index from reference genes
    bwa_index(fastaref_ch)

    // map the output of flash2 (merged reads of each sample) to the reference
    bwa_mapping(flash2_process.out.merged
        .combine(bwa_index.out.index))
    
    // convert the sam files to bam files
    sam_to_bam(bwa_mapping.out.sam)


    // prepare pairs of flash2 and samtobam outputs per sample, to input in SMAP

    // def alignedreads_ch = channel
    //     .fromPath("${params.samples_path}/samplesinfo.csv")
    //     .splitCsv(header: false)
    //     .map { row ->
    //         def sample_id = row[0]
    //         tuple(sample_id,
    //             flash2_process.out.merged[${sample_id}],
    //             sam_to_bam.out.bam[${sample_id}]
    //             )
    //     }
    // def all_fastqs = flash2_process.out.merged
    //     .map { sample, fq -> fq }
    //     .collect()

    // def all_bams   = sam_to_bam.out.bam
    //     .collect()

    def fqs_bams_joined = flash2_process.out.merged
        .join(sam_to_bam.out.bam)
        .collect()

    def smap_input_ch = fqs_bams_joined.map { rows ->
        def fastqs = rows.collect { [1] }
        def bams   = rows.collect { [2] }
        tuple(
            file("${params.ref_path}/reference_genes.fasta"),
            file("${params.ref_path}/borderFile.gff"),
            bams,
            fastqs
        )
    }


    // def smap_joined = flash2_process.out.merged
    //     .join(sam_to_bam.out.bam)    
    // def smap_input = smap_joined
    //     .map {sample, merged_fq, bam ->
    //         tuple(
    //             file("${params.ref_path}/reference_genes.fasta"),
    //             file("${params.ref_path}/borderFile.gff"),
    //             bam,
    //             merged_fq
    //         )
    //     }

    
    // distinguish haplotypes at each polymorphic locus with SMAP
    smap_haplotype_window(smap_input_ch)

    // // define my custom script as a channel
    // def pyscript_ch = channel.of(file("HaplotypeAnalysis.py"))


    // // define channel with all inputs necessary for the custom python script
    // def samplesinfo_ch = channel.of(file("${params.samples_path}/samplesinfo.csv"))
    // def python_input = smap_haplotype_window.out.smap_freqs
    //     .combine(samplesinfo_ch)
    //     .map { hapfile, samplesinfo ->
    //         tuple(
    //             hapfile,
    //             file("${params.ref_path}/reference_genes.fasta"),
    //             file("${params.ref_path}/borderFile.gff")
    //         )
    //     }

    // // run the custom script
    // haplotype_analysis(python_input)

 }