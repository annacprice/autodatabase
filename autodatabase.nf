#!/usr/bin/env nextflow

// enable dsl2
nextflow.preview.dsl=2

//  import modules
include './modules/taxadd.nf'
include './modules/mash.nf'
include './modules/fastaadd.nf'
include './modules/kraken2.nf'

// define workflow components
workflow PrepareNewAssemblies {
    get:
      EditFasta
    main:
      TaxAdd(EditFasta)
      MashSketch(TaxAdd.out)
    emit:
      NewFasta = TaxAdd.out
      NewMashSketches = MashSketch.out
}

workflow SelectFastas {
    get:
      MashSketches
      AllFasta
    main:
      MashDist(MashSketches.collect())
      MashSort(MashDist.out.flatten())
      FastaAdd(AllFasta.collect(), MashSort.out.collect())
    emit:
      MashDistances = MashDist.out
      FastaSelect = MashSort.out
      FastaToAdd = FastaAdd.out
}

workflow KrakenBuild {
    get:
      FastaAdd
    main:
      KrakenAdd(FastaAdd.flatten())
    emit:
      KrakenLib = KrakenAdd.out
}

// main workflow
workflow {
    EditFasta = Channel.fromPath( "/home/ubuntu/data/auto_database/new/**.fasta" ).map { file -> tuple(file.getParent().getName(), file)} 
    OldMashSketches = Channel.fromPath( "/home/ubuntu/data/auto_database/current/mash/*.msh" )
    OldFasta = Channel.fromPath( "/home/ubuntu/data/auto_database/current/*.fasta" )  

    main:
      PrepareNewAssemblies(EditFasta)
      SelectFastas(PrepareNewAssemblies.out.NewMashSketches.mix(OldMashSketches), PrepareNewAssemblies.out.NewFasta.mix(OldFasta))
      KrakenBuild(SelectFastas.out.FastaToAdd)

    publish:
      PrepareNewAssemblies.out to: "/home/ubuntu/data/auto_database/debug"
      SelectFastas.out to: "/home/ubuntu/data/auto_database/debug"
      KrakenBuild.out to: "/home/ubuntu/data/auto_database/debug"
}
