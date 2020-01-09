#!/usr/bin/env nextflow

// enable dsl2
nextflow.preview.dsl=2

//  import modules
include './modules/taxadd.nf'
include './modules/mash.nf'

// define input channels
//InFasta = Channel.fromPath( "/home/ubuntu/data/auto_database/new/**.fasta" ).map { file -> tuple(file.getParent().getName(), file)}


// define workflow components
workflow PrepareNewAssemblies {
    get:
      InFasta
    main:
      TaxAdd(InFasta)
      MashSketch(TaxAdd.out)
}

// main workflow
workflow {
    InFasta = Channel.fromPath( "/home/ubuntu/data/auto_database/new/**.fasta" ).map { file -> tuple(file.getParent().getName(), file)}    

    main:
      PrepareNewAssemblies(InFasta)
}
