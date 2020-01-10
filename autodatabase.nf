#!/usr/bin/env nextflow

// enable dsl2
nextflow.preview.dsl=2

//  import modules
include './modules/taxadd.nf'
include './modules/mash.nf'

// define workflow components
workflow PrepareNewAssemblies {
    get:
      InFasta
    main:
      TaxAdd(InFasta)
      MashSketch(TaxAdd.out)
    emit:
      MashSketch.out
}

workflow SelectFastas {
    get:
      MashSketches
    main:
      MashDist(MashSketches.collect())
      MashSort(MashDist.out.flatten())
}

// main workflow
workflow {
    InFasta = Channel.fromPath( "/home/ubuntu/data/auto_database/new/**.fasta" ).map { file -> tuple(file.getParent().getName(), file)} 
    OldMashSketches = Channel.fromPath( "/home/ubuntu/data/auto_database/current/mash/*.msh" )   

    main:
      PrepareNewAssemblies(InFasta)
      SelectFastas(PrepareNewAssemblies.out.mix(OldMashSketches))
}

