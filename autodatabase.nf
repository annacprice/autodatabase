#!/usr/bin/env nextflow

// enable dsl2
nextflow.preview.dsl=2

//  import modules
include './modules/taxadd.nf'
include './modules/mash.nf'

// define input channels
Channel
    .fromPath( "/home/ubuntu/data/auto_database/new/**.fasta" )
    .map { file -> tuple(file.getParent().getName(), file)}
    .set {InFasta}

workflow {
    TaxAdd(InFasta)
    MashSketch(TaxAdd.out)
}
