#!/usr/bin/env nextflow

// enable dsl2
nextflow.preview.dsl=2

//  import modules
include './modules/autodatabase.nf'

// define input parameters, e.g. path to new assemblies to be added, path to the current database
params.addFasta = "/home/ubuntu/data/auto_database/new"
//params.currentDatabase = "/home/ubuntu/data/auto_database/current"
params.currentDatabase = null
params.newDatabase = "/home/ubuntu/data/auto_database/databasetest"

// define workflow components
// add taxon to header and filename and for new fastas
workflow PrepareNewFasta {
    get:
      EditFasta
    main:
      autodatabase_addtaxon(EditFasta)
    emit:
      NewFasta = autodatabase_addtaxon.out
}

// calculate pairwise distance matrix and use to select high quality assemblies; parallelisation is by taxon
workflow SelectFasta {
    take:
      AllFasta
    main:
      autodatabase_mash(AllFasta)
      autodatabase_qc(autodatabase_mash.out)
      autodatabase_selectfasta(AllFasta, autodatabase_qc.out.collect().flatten().map{ file -> tuple(file.getName().split("_")[0], file) }.groupTuple(sort: true))
    emit:
      FastaToAdd = autodatabase_selectfasta.out
}

// build kraken2 database
workflow KrakenBuilder {
    take:
      FastaToAdd
    main:
      kraken2_databasebuild(FastaToAdd.collect())
    emit:
      KrakenDatabase = kraken2_databasebuild.out
}

// main workflow

workflow {
    // New Assemblies to Edit
    EditFasta = Channel.fromPath( params.addFasta + "/**.f*" ).map { file -> tuple(file.getParent().getName(), file)}

    if( params.currentDatabase ) {
        // If building from a previous database, create channnel for the assemblies
        OldFasta = Channel.fromPath( params.currentDatabase + "/**.f*" ) 
    }
    else {
        // Else there are no assemblies to add so create empty channel
        OldFasta = Channel.empty()
    }

     main:
       PrepareNewFasta(EditFasta)
       AllFasta = PrepareNewFasta.out.NewFasta.mix(OldFasta).map{ file -> tuple(file.getName().split("_")[0], file) }.groupTuple(sort: true)
       SelectFasta(AllFasta)
       KrakenBuilder(SelectFasta.out.FastaToAdd)
     publish:
       SelectFasta.out to: params.newDatabase, mode: 'copy', overwrite: true
       KrakenBuilder.out to: params.newDatabase, mode: 'copy', overwrite: true    
}

