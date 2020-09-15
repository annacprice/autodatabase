#!/usr/bin/env nextflow

// enable dsl2
nextflow.preview.dsl=2

// import subworkflows
include {prepareNewFasta} from './workflows/prepareNewFasta.nf'
include {selectFasta} from './workflows/selectFasta.nf'
include {krakenBuild} from './workflows/krakenBuild.nf'

// main workflow
workflow {
    // New Assemblies to Edit
    EditFasta = Channel.fromPath( params.addFasta + "/**.f*" ).map{ file -> tuple(file.getParent().getName(), file) }

    if( params.previousDatabase ) {
        // If building from a previous database, create channnel for the assemblies
        OldFasta = Channel.fromPath( params.previousDatabase + "/**.f*" ) 
    }
    else {
        // Else there are no assemblies to add so create empty channel
        OldFasta = Channel.empty()
    }

     main:
       prepareNewFasta(EditFasta)
       AllFasta = prepareNewFasta.out.NewFasta.mix(OldFasta).map{ file -> tuple(file.getName().split("_")[0], file) }.groupTuple(sort: true)
       selectFasta(AllFasta)
       krakenBuild(selectFasta.out.FastaToAdd, prepareNewFasta.out.TaxonomyNames, prepareNewFasta.out.TaxonomyNodes)  
}

