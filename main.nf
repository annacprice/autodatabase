#!/usr/bin/env nextflow

// enable dsl2
nextflow.preview.dsl=2

//  import modules
include {autoDatabase_addTaxon} from './modules/autoDatabase.nf' params(params)
include {autoDatabase_mash} from './modules/autoDatabase.nf' params(params)
include {autoDatabase_qc} from './modules/autoDatabase.nf' params(params)
include {autoDatabase_selectFasta} from './modules/autoDatabase.nf' params(params)
include {autoDatabase_kraken2Build} from './modules/autoDatabase.nf' params(params)


// define workflow components
// add taxon to header and filename and for new assemblies
workflow PrepareNewFasta {
    take:
      EditFasta
    main:
      autoDatabase_addTaxon(EditFasta)
    emit:
      NewFasta = autoDatabase_addTaxon.out
}

// calculate pairwise distance matrix and use to select high quality assemblies; parallelisation is by taxon
workflow SelectFasta {
    take:
      AllFasta
    main:
      autoDatabase_mash(AllFasta)
      autoDatabase_qc(autoDatabase_mash.out)
      autoDatabase_selectFasta(AllFasta, autoDatabase_qc.out.collect().flatten().map{ file -> tuple(file.getName().split("_")[0], file) }.groupTuple(sort: true))
    emit:
      FastaToAdd = autoDatabase_selectFasta.out
}

// build kraken2 database
workflow KrakenBuilder {
    take:
      FastaToAdd
    main:
      autoDatabase_kraken2Build(FastaToAdd.collect())
    emit:
      KrakenDatabase = autoDatabase_kraken2Build.out
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
}

