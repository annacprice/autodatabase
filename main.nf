#!/usr/bin/env nextflow

// enable dsl2
nextflow.preview.dsl=2

//  import modules
include './modules/mash.nf'
include './modules/kraken2.nf'
include './modules/autodatabase.nf'

// define input parameters, e.g. path to new assemblies to be added, path to the current database
params.addFasta = "/home/ubuntu/data/auto_database/new"
//params.currentDatabase = "/home/ubuntu/data/auto_database/current"
params.currentDatabase = null
params.newDatabase = "/home/ubuntu/data/auto_database/database"

// define workflow components
// add taxon to header and calculate mash sketches for new fastas
workflow PrepareNewFasta {
    get:
      EditFasta
    main:
      autodatabase_addtaxon(EditFasta)
      mash_sketch(autodatabase_addtaxon.out)
    emit:
      NewFasta = autodatabase_addtaxon.out
      NewMashSketches = mash_sketch.out
}

// calculate pairwise distance matrix and use to select high quality assemblies
workflow SelectFasta {
    get:
      AllMashSketches
      AllFasta
    main:
      autodatabase_mashdist(AllMashSketches.collect())
      autodatabase_qc(autodatabase_mashdist.out.flatten())
      autodatabase_selectfasta(AllFasta.collect(), autodatabase_qc.out.collect(), AllMashSketches.collect())
    emit:
      FastaToAdd = autodatabase_selectfasta.out[0]
      MashToAdd = autodatabase_selectfasta.out[1]
}

// build kraken2 database
workflow KrakenBuilder {
    get:
      FastaToAdd
    main:
      kraken2_databasebuild(FastaToAdd.collect())
    emit:
      KrakenDatabase = kraken2_databasebuild.out
}

// main workflow

workflow {
    // New Assemblies to Edit
    EditFasta = Channel.fromPath( params.addFasta + "/**.fasta" ).map { file -> tuple(file.getParent().getName(), file)}

    if( params.currentDatabase ) {
        // If building from a previous database, create channnels for the sketches and assemblies
        OldMashSketches = Channel.fromPath( params.currentDatabase + "/**.msh" )
        OldFasta = Channel.fromPath( params.currentDatabase + "/**.fasta" ) 
    }
    else {
        // Else there are no sketches or assemblies to add so create empty channels
        OldMashSketches = Channel.empty()
        OldFasta = Channel.empty()
    }

     main:
       PrepareNewFasta(EditFasta)
       SelectFasta(PrepareNewFasta.out.NewMashSketches.mix(OldMashSketches), PrepareNewFasta.out.NewFasta.mix(OldFasta))
       KrakenBuilder(SelectFasta.out.FastaToAdd)
     publish:
       SelectFasta.out to: params.newDatabase, mode: 'copy', overwrite: true
       KrakenBuilder.out to: params.newDatabase, mode: 'copy', overwrite: true    
}

