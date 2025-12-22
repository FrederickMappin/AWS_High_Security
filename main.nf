/*
 * Copyright (c) 2013-2018, Centre for Genomic Regulation (CRG) and the authors.
 *
 *   This file is part of 'RNA-Toy'.
 *
 *   RNA-Toy is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   RNA-Toy is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with RNA-Toy.  If not, see <http://www.gnu.org/licenses/>.
 */
 
/* 
 * Proof of concept Nextflow based RNA-Seq pipeline
 * 
 * Authors:
 * Paolo Di Tommaso <paolo.ditommaso@gmail.com>
 * Emilio Palumbo <emiliopalumbo@gmail.com> 
 */ 

nextflow.enable.dsl=2
 
/*
 * Defines some parameters in order to specify the refence genomes
 * and read pairs by using the command line options
 */
params.reads = "$baseDir/data/ggal/*_{1,2}.fq"
params.annot = "$baseDir/data/ggal/ggal_1_48850000_49020000.bed.gff"
params.genome = "$baseDir/data/ggal/ggal_1_48850000_49020000.Ggal71.500bpflank.fa"
params.outdir = 'results'

log.info """\
         R N A T O Y   P I P E L I N E    
         =============================
         genome: ${params.genome}
         annot : ${params.annot}
         reads : ${params.reads}
         outdir: ${params.outdir}
         """
         .stripIndent()
 
/*
 * Step 1. Builds the genome index required by the mapping process
 */
process buildIndex {
    tag "$genome.baseName"
    
    input:
    path genome
     
    output:
    path 'genome.index*'
       
    """
    bowtie2-build --threads ${task.cpus} ${genome} genome.index
    """
}
 
/*
 * Step 2. Maps each read-pair by using Tophat2 mapper tool
 */
process mapping {
    tag "$pair_id"
     
    input:
    path genome
    path annot
    path index
    tuple val(pair_id), path(reads)
 
    output:
    tuple val(pair_id), path("accepted_hits.bam")
 
    """
    tophat2 -p ${task.cpus} --GTF $annot genome.index $reads
    mv tophat_out/accepted_hits.bam .
    """
}
  
/*
 * Step 3. Assembles the transcript by using the "cufflinks" tool
 */
process makeTranscript {
    tag "$pair_id"
    publishDir params.outdir, mode: 'copy'  
       
    input:
    path annot
    tuple val(pair_id), path(bam_file)
     
    output:
    tuple val(pair_id), path('transcript_*.gtf')
 
    """
    cufflinks --no-update-check -q -p $task.cpus -G $annot $bam_file
    mv transcripts.gtf transcript_${pair_id}.gtf
    """
}

workflow {
    // Create channels
    read_pairs_ch = Channel
        .fromFilePairs( params.reads )
        .ifEmpty { error "Cannot find any reads matching: ${params.reads}" }
    
    genome_ch = Channel.fromPath(params.genome)
    annot_ch = Channel.fromPath(params.annot)
    
    // Execute pipeline
    index_ch = buildIndex(genome_ch)
    bam_ch = mapping(genome_ch, annot_ch, index_ch, read_pairs_ch)
    makeTranscript(annot_ch, bam_ch)
}
 
workflow.onComplete { 
	log.info ( workflow.success ? "Done!" : "Oops .. something went wrong" )
}