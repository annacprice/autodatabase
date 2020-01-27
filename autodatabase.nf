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

workflow KrakenPrep {
    get:
      FastaAdd
    main:
      KrakenAdd(FastaAdd.collect())
    emit:
      KrakenLib = KrakenAdd.out
}

workflow KrakenBuilder {
    get:
      Database
    main:
      KrakenBuildData(Database.collect())
    emit:
      KrakenDatabase = KrakenBuildData.out
}

// main workflow
workflow {
    // Assemblies to Edit
    EditFasta = Channel.fromPath( "/home/ubuntu/data/auto_database/new/**.fasta" ).map { file -> tuple(file.getParent().getName(), file)}
    // Mash Sketches and Fastas from Current Database 
    OldMashSketches = Channel.fromPath( "/home/ubuntu/data/auto_database/current/mash/*.msh" )
    OldFasta = Channel.fromPath( "/home/ubuntu/data/auto_database/current/*.fasta" )
    // Path for the new database 
    Database = Channel.fromPath( "/home/ubuntu/data/auto_database/database", type: 'dir')  

    main:
      PrepareNewAssemblies(EditFasta)
      SelectFastas(PrepareNewAssemblies.out.NewMashSketches.mix(OldMashSketches), PrepareNewAssemblies.out.NewFasta.mix(OldFasta))
      KrakenPrep(SelectFastas.out.FastaToAdd)
      KrakenBuilder(Database)
}
