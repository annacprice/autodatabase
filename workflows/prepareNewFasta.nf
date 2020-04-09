// enable dsl2
nextflow.preview.dsl = 2

// import modules
include {autoDatabase_addTaxon} from '../modules/autoDatabase.nf' params(params)

// define workflow component
// add taxon to header and filename and for new assemblies
workflow prepareNewFasta {
    take:
      EditFasta
    main:
      autoDatabase_addTaxon(EditFasta)
    emit:
      NewFasta = autoDatabase_addTaxon.out
}
