#!/usr/bin/env nextflow

// enable dsl2
nextflow.preview.dsl=2

//  import modules
include './modules/mash.nf'
include './modules/kraken2.nf'
include './modules/autodatabase.nf'

// define input parameters, e.g. path to new assemblies, current database
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

// calculate pairwise distance matrix and use to select high quality fasta
workflow SelectFasta {
    get:
      AllMashSketches
      AllFasta
    main:
      autodatabase_mashdist(AllMashSketches.collect())
      autodatabase_qc(autodatabase_mashdist.out.flatten())
      autodatabase_selectfasta(AllFasta.collect(), autodatabase_qc.out.collect())
    emit:
      MashDistances = autodatabase_mashdist.out
      FastaSelect = autodatabase_qc.out
      FastaToAdd = autodatabase_selectfasta.out
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
    // Fastas to Edit
    EditFasta = Channel.fromPath( params.addFasta + "/**.fasta" ).map { file -> tuple(file.getParent().getName(), file)}

    if( params.currentDatabase ) {
        // Mash Sketches and Fastas from Current Database 
        OldMashSketches = Channel.fromPath( params.currentDatabase + "/mash/*.msh" )
        OldFasta = Channel.fromPath( params.currentDatabase + "/*.fasta" ) 
    }
    else {
        OldMashSketches = Channel.empty()
        OldFasta = Channel.empty()
    }
     main:
       PrepareNewFasta(EditFasta)
       SelectFasta(PrepareNewFasta.out.NewMashSketches.mix(OldMashSketches), PrepareNewFasta.out.NewFasta.mix(OldFasta))
       KrakenBuilder(SelectFasta.out.FastaToAdd)
     publish:
       KrakenBuilder.out to: params.newDatabase, mode: 'copy'    
}

